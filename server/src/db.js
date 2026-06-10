'use strict';

const { Pool } = require('pg');

/**
 * Single shared connection pool.
 *
 * Neon requires SSL. We enable it whenever a DATABASE_URL is present and not a
 * plain localhost connection (local Docker Postgres does not use SSL).
 */
const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  // Fail loud and early — a missing DB URL is the most common deploy mistake.
  console.error('[db] DATABASE_URL is not set. Copy .env.example to .env (local) ' +
    'or set it in Render → Environment.');
}

const isLocal = /@(localhost|127\.0\.0\.1|db)[:/]/.test(connectionString || '');

const pool = new Pool({
  connectionString,
  ssl: connectionString && !isLocal ? { rejectUnauthorized: false } : false,
  // Don't let a sleeping/slow database (free Neon suspends when idle) hang a
  // connection forever — fail fast so requests error cleanly instead.
  connectionTimeoutMillis: 15000,
});

pool.on('error', (err) => {
  console.error('[db] unexpected pool error', err);
});

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
};
