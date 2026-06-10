'use strict';

// Shared schema + seed logic, used by both the CLI scripts and the server's
// startup bootstrap.
//
// Two kinds of data are treated differently:
//   • "definitions" (statuses, sections) are code-managed — upserted on every
//     boot so titles/labels always match the code.
//   • "projects" are content — seeded only when the table is empty, so edits
//     made through the API are preserved across deploys.

const fs = require('fs');
const path = require('path');
const { statuses, sections, projects } = require('../scripts/seedData');
const { PROJECT_WRITABLE, JSON_COLUMNS } = require('./mappers');

const schemaSQL = fs.readFileSync(path.join(__dirname, '..', '..', 'db', 'schema.sql'), 'utf8');

async function ensureSchema(db) {
  await db.query(schemaSQL);
}

async function isEmpty(db) {
  const { rows } = await db.query('SELECT count(*)::int AS n FROM projects');
  return rows[0].n === 0;
}

// Upsert statuses + sections (DO UPDATE) — keeps titles/labels in sync with the
// code on every deploy. Safe to run repeatedly.
async function syncDefinitions(db) {
  for (const s of statuses) {
    await db.query(
      `INSERT INTO statuses (key, label, position) VALUES ($1, $2, $3)
       ON CONFLICT (key) DO UPDATE SET label = EXCLUDED.label, position = EXCLUDED.position`,
      [s.key, s.label, s.position]
    );
  }
  for (const s of sections) {
    await db.query(
      `INSERT INTO sections (id, position, icon, title, sub) VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE
         SET position = EXCLUDED.position, icon = EXCLUDED.icon,
             title = EXCLUDED.title, sub = EXCLUDED.sub`,
      [s.id, s.position, s.icon, s.title, s.sub]
    );
  }
}

// Insert project rows. With reset, replaces them; otherwise existing rows are
// left untouched (preserves edits made through the API).
async function seedProjects(db, { reset = false } = {}) {
  if (reset) await db.query('TRUNCATE projects RESTART IDENTITY');
  let pos = 0;
  for (const p of projects) {
    const cols = ['id', 'position'];
    const vals = [p.id, pos++];
    for (const [apiKey, column] of Object.entries(PROJECT_WRITABLE)) {
      if (column === 'position') continue;
      if (Object.prototype.hasOwnProperty.call(p, apiKey)) {
        cols.push(column);
        const v = p[apiKey];
        vals.push(JSON_COLUMNS.has(column) && v != null ? JSON.stringify(v) : v);
      }
    }
    const ph = vals.map((_, i) => `$${i + 1}`);
    await db.query(
      `INSERT INTO projects (${cols.join(', ')}) VALUES (${ph.join(', ')}) ON CONFLICT (id) DO NOTHING`,
      vals
    );
  }
}

// Full seed (CLI `db:seed`). reset clears everything first.
async function seed(db, { reset = false } = {}) {
  if (reset) await db.query('TRUNCATE projects, sections, statuses RESTART IDENTITY CASCADE');
  await syncDefinitions(db);
  await seedProjects(db, { reset: false });
}

const counts = { statuses: statuses.length, sections: sections.length, projects: projects.length };

module.exports = { ensureSchema, isEmpty, syncDefinitions, seedProjects, seed, counts };
