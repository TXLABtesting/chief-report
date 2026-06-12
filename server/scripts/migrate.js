'use strict';

require('dotenv').config();
const { pool } = require('../src/db');
const { ensureSchema } = require('../src/seedCore');

async function main() {
  console.log('[migrate] ensuring schema …');
  await ensureSchema(pool);
  console.log('[migrate] done.');
  await pool.end();
}

main().catch((err) => {
  console.error('[migrate] failed:', err);
  process.exit(1);
});
