'use strict';

require('dotenv').config();
const { pool } = require('../src/db');
const { ensureSchema, sync, counts } = require('../src/seedCore');

async function main() {
  await ensureSchema(pool);
  await sync(pool, { reset: true });
  console.log(`[seed] ${counts.reports} reports, ${counts.sections} sections, ${counts.statuses} statuses, ${counts.projects} projects.`);
  await pool.end();
}

main().catch((err) => {
  console.error('[seed] failed:', err);
  process.exit(1);
});
