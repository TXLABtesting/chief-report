'use strict';

const express = require('express');
const db = require('../db');
const { readDbResponse, buildFileResponse } = require('../reportShape');

const router = express.Router();

// GET /api/report — read all weekly reports from the database. Falls back to
// the bundled data file if the database is unreachable or not yet seeded, so
// the site never serves an empty page during a cold start.
router.get('/', async (_req, res) => {
  try {
    const data = await readDbResponse(db);
    if (data.reports.length > 0) {
      res.set('X-Report-Source', 'database');
      return res.json(data);
    }
    console.warn('[report] database has no reports — serving data file');
  } catch (err) {
    console.error('[report] database read failed, serving data file:', err.message);
  }
  res.set('X-Report-Source', 'file');
  res.json(buildFileResponse());
});

module.exports = router;
