'use strict';

require('dotenv').config();
const { pool } = require('../src/db');
const { statuses, sections, projects } = require('./seedData');
const { PROJECT_WRITABLE, JSON_COLUMNS } = require('../src/mappers');

async function main() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Idempotent reseed: clear in FK-safe order.
    await client.query('TRUNCATE projects, sections, statuses RESTART IDENTITY CASCADE');

    for (const s of statuses) {
      await client.query(
        'INSERT INTO statuses (key, label, position) VALUES ($1, $2, $3)',
        [s.key, s.label, s.position]
      );
    }

    for (const s of sections) {
      await client.query(
        'INSERT INTO sections (id, position, icon, title, sub) VALUES ($1, $2, $3, $4, $5)',
        [s.id, s.position, s.icon, s.title, s.sub]
      );
    }

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
      const placeholders = vals.map((_, i) => `$${i + 1}`);
      await client.query(
        `INSERT INTO projects (${cols.join(', ')}) VALUES (${placeholders.join(', ')})`,
        vals
      );
    }

    await client.query('COMMIT');
    console.log(`[seed] ${statuses.length} statuses, ${sections.length} sections, ${projects.length} projects.`);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error('[seed] failed:', err);
  process.exit(1);
});
