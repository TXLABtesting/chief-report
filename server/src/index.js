'use strict';

require('dotenv').config();

const path = require('path');
const fs = require('fs');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// ── API ──────────────────────────────────────────────────────────────────
app.get('/api/health', (_req, res) => res.json({ ok: true, service: 'chief-report' }));
app.use('/api/report', require('./routes/report'));

// Uploaded supporting documents (PDFs, etc.)
app.use('/docs', express.static(path.join(__dirname, '..', '..', 'docs')));

// ── Static client (production build) ─────────────────────────────────────
// In production the multi-stage Docker build copies the compiled React app
// into client/dist; Express serves it and falls back to index.html (SPA).
const clientDist = path.join(__dirname, '..', '..', 'client', 'dist');
if (fs.existsSync(clientDist)) {
  app.use(express.static(clientDist));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api/')) return next();
    res.sendFile(path.join(clientDist, 'index.html'));
  });
}

// ── Errors ───────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ error: 'Not found', path: req.path }));
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error('[error]', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Startup bootstrap ────────────────────────────────────────────────────
// Ensure the schema exists and sync the data file into the database so the
// content lives in Neon (ready for IT to migrate to internal DBs). Runs in the
// background so a slow/idle database never blocks startup or the health check.
// Set AUTO_SYNC=false to stop overwriting the DB from code (e.g. once IT owns it).
const db = require('./db');
const { ensureSchema, sync, counts } = require('./seedCore');

async function bootstrap() {
  if (process.env.AUTO_SYNC === 'false') return;
  try {
    await ensureSchema(db.pool);
    await sync(db.pool, { reset: false });
    console.log(`[bootstrap] synced to database — ${counts.reports} reports, ${counts.projects} projects`);
  } catch (err) {
    console.error('[bootstrap] DB sync skipped (database slow/unreachable):', err.message);
  }
}

// Start listening immediately so the server is healthy even if the database is
// slow to wake (free Neon suspends when idle).
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`[chief-report] API listening on :${PORT}`);
  bootstrap();
});
