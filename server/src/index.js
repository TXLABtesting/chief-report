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
app.use('/api/sections', require('./routes/sections'));
app.use('/api/projects', require('./routes/projects'));
app.use('/api/statuses', require('./routes/statuses'));

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
// Ensure the schema exists and seed the report the first time the database is
// empty, so a fresh Neon database never serves a blank page. Idempotent and
// non-destructive (existing rows are preserved). Disable with AUTO_MIGRATE=false.
const db = require('./db');
const { ensureSchema, isEmpty, seed, counts } = require('./seedCore');

async function bootstrap() {
  if (process.env.AUTO_MIGRATE === 'false') return;
  try {
    await ensureSchema(db.pool);
    if (await isEmpty(db.pool)) {
      await seed(db.pool, { reset: false });
      console.log(`[bootstrap] empty database — seeded ${counts.sections} sections / ${counts.projects} projects`);
    } else {
      console.log('[bootstrap] schema ensured; data already present');
    }
  } catch (err) {
    console.error('[bootstrap] skipped (database not reachable yet):', err.message);
  }
}

const PORT = process.env.PORT || 3001;
bootstrap().finally(() => {
  app.listen(PORT, () => console.log(`[chief-report] API listening on :${PORT}`));
});
