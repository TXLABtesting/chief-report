'use strict';

const express = require('express');
const db = require('../db');

const router = express.Router();

// GET /api/statuses — the filter chips / badge vocabulary.
router.get('/', async (_req, res, next) => {
  try {
    const { rows } = await db.query('SELECT key, label, position FROM statuses ORDER BY position');
    res.json(rows);
  } catch (err) { next(err); }
});

module.exports = router;
