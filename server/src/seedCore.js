'use strict';

const fs = require('fs');
const path = require('path');
const { STATUSES, SECTIONS, REPORTS } = require('./reportsData');
const { PROJECT_COLUMNS, JSON_COLUMNS } = require('./reportShape');

const schemaSQL = fs.readFileSync(path.join(__dirname, '..', '..', 'db', 'schema.sql'), 'utf8');

// Ensure the schema exists. If the legacy (pre-weekly-reports) tables are
// present without the new `reports` table, drop them first so the new schema
// can be created cleanly — a one-time automatic migration.
async function ensureSchema(db) {
  const { rows } = await db.query("SELECT to_regclass('public.reports') AS r");
  if (!rows[0].r) {
    await db.query('DROP TABLE IF EXISTS projects CASCADE');
    await db.query('DROP TABLE IF EXISTS sections CASCADE');
    await db.query('DROP TABLE IF EXISTS statuses CASCADE');
  }
  await db.query(schemaSQL);
  // Lightweight column migrations for already-existing databases.
  try { await db.query('ALTER TABLE projects ADD COLUMN IF NOT EXISTS target INT'); } catch (_) { /* older engines */ }
}

async function isEmpty(db) {
  const { rows } = await db.query('SELECT count(*)::int AS n FROM reports');
  return rows[0].n === 0;
}

// Upsert the whole dataset (reports + sections + statuses + projects) from the
// data file into the database. Idempotent; `reset` clears everything first.
async function sync(db, { reset = false } = {}) {
  if (reset) await db.query('TRUNCATE projects, reports, sections, statuses RESTART IDENTITY CASCADE');

  for (const s of STATUSES) {
    await db.query(
      `INSERT INTO statuses (key, label, position) VALUES ($1, $2, $3)
       ON CONFLICT (key) DO UPDATE SET label = EXCLUDED.label, position = EXCLUDED.position`,
      [s.key, s.label, STATUSES.indexOf(s) + 1]
    );
  }

  for (let i = 0; i < SECTIONS.length; i++) {
    const s = SECTIONS[i];
    await db.query(
      `INSERT INTO sections (id, position, icon, title, sub) VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE SET position = EXCLUDED.position, icon = EXCLUDED.icon,
         title = EXCLUDED.title, sub = EXCLUDED.sub`,
      [s.id, i + 1, s.icon, s.title, s.sub]
    );
  }

  // Keep the database holding exactly the reports defined in the data file.
  const ids = REPORTS.map((r) => r.id);
  await db.query(
    `DELETE FROM reports WHERE NOT (id = ANY($1::text[]))`,
    [ids.length ? ids : ['__none__']]
  );

  for (let i = 0; i < REPORTS.length; i++) {
    const r = REPORTS[i];
    await db.query(
      `INSERT INTO reports (id, label, date_iso, position, top_priorities)
       VALUES ($1, $2, $3, $4, $5::jsonb)
       ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, date_iso = EXCLUDED.date_iso,
         position = EXCLUDED.position, top_priorities = EXCLUDED.top_priorities`,
      [r.id, r.label, r.dateIso, REPORTS.length - i, JSON.stringify(r.topPriorities || [])]
    );

    // Replace this report's projects so removed items don't linger.
    await db.query('DELETE FROM projects WHERE report_id = $1', [r.id]);
    let pos = 0;
    for (const p of r.projects) {
      const cols = ['report_id', 'id', 'position'];
      const vals = [r.id, p.id, pos++];
      for (const [apiKey, column] of Object.entries(PROJECT_COLUMNS)) {
        if (Object.prototype.hasOwnProperty.call(p, apiKey)) {
          cols.push(column);
          const v = p[apiKey];
          vals.push(JSON_COLUMNS.has(column) && v != null ? JSON.stringify(v) : v);
        }
      }
      const ph = vals.map((_, j) => `$${j + 1}`);
      await db.query(`INSERT INTO projects (${cols.join(', ')}) VALUES (${ph.join(', ')})`, vals);
    }
  }
}

const counts = {
  statuses: STATUSES.length,
  sections: SECTIONS.length,
  reports: REPORTS.length,
  projects: REPORTS.reduce((a, r) => a + r.projects.length, 0),
};

module.exports = { ensureSchema, isEmpty, sync, counts };
