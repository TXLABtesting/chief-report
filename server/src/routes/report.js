'use strict';

const express = require('express');
const db = require('../db');
const { mapProject, mapSection } = require('../mappers');

const router = express.Router();

// GET /api/report — the whole report, sections with nested projects,
// ordered the same way the original report was. This is what the client
// renders on load.
router.get('/', async (_req, res, next) => {
  try {
    const [statuses, sections, projects] = await Promise.all([
      db.query('SELECT key, label FROM statuses ORDER BY position'),
      db.query('SELECT * FROM sections ORDER BY position'),
      db.query('SELECT * FROM projects ORDER BY position, created_at'),
    ]);

    const bySection = new Map();
    for (const row of projects.rows) {
      if (!bySection.has(row.section_id)) bySection.set(row.section_id, []);
      bySection.get(row.section_id).push(mapProject(row));
    }

    res.json({
      statuses: statuses.rows,
      sections: sections.rows.map((s) => ({
        ...mapSection(s),
        projects: bySection.get(s.id) || [],
      })),
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
