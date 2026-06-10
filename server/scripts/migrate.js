'use strict';

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('../src/db');

async function main() {
  const schema = fs.readFileSync(path.join(__dirname, '..', '..', 'db', 'schema.sql'), 'utf8');
  console.log('[migrate] applying db/schema.sql …');
  await pool.query(schema);
  console.log('[migrate] done.');
  await pool.end();
}

main().catch((err) => {
  console.error('[migrate] failed:', err);
  process.exit(1);
});
