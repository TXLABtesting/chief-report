'use strict';

require('dotenv').config();
const { pool } = require('../src/db');
const { ensureSchema, seed, counts } = require('../src/seedCore');

async function main() {
  await ensureSchema(pool);              // safe if migrate already ran
  await seed(pool, { reset: true });     // CLI seed replaces existing rows
  console.log(`[seed] ${counts.statuses} statuses, ${counts.sections} sections, ${counts.projects} projects.`);
  await pool.end();
}

main().catch((err) => {
  console.error('[seed] failed:', err);
  process.exit(1);
});
