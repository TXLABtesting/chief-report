'use strict';

const crypto = require('crypto');
const express = require('express');
const db = require('../db');
const { mapProject, PROJECT_WRITABLE, JSON_COLUMNS } = require('../mappers');

const router = express.Router();

// Build column/value lists from a request body using the writable allow-list.
// Returns { cols, vals } where JSON columns are stringified for pg.
function extractWritable(body) {
  const cols = [];
  const vals = [];
  for (const [apiKey, column] of Object.entries(PROJECT_WRITABLE)) {
    if (Object.prototype.hasOwnProperty.call(body, apiKey)) {
      cols.push(column);
      const value = body[apiKey];
      vals.push(JSON_COLUMNS.has(column) && value != null ? JSON.stringify(value) : value);
    }
  }
  return { cols, vals };
}

// GET /api/projects?section=&status=
router.get('/', async (req, res, next) => {
  try {
    const where = [];
    const params = [];
    if (req.query.section) { params.push(req.query.section); where.push(`section_id = $${params.length}`); }
    if (req.query.status) { params.push(req.query.status); where.push(`status = $${params.length}`); }
    const sql = `SELECT * FROM projects ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
                 ORDER BY position, created_at`;
    const { rows } = await db.query(sql, params);
    res.json(rows.map(mapProject));
  } catch (err) { next(err); }
});

// GET /api/projects/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM projects WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Project not found' });
    res.json(mapProject(rows[0]));
  } catch (err) { next(err); }
});

// POST /api/projects
router.post('/', async (req, res, next) => {
  try {
    if (!req.body.title || !req.body.section || !req.body.status) {
      return res.status(400).json({ error: 'section, status and title are required' });
    }
    const id = req.body.id || crypto.randomUUID();
    const { cols, vals } = extractWritable(req.body);
    const allCols = ['id', ...cols];
    const allVals = [id, ...vals];
    const placeholders = allVals.map((_, i) => `$${i + 1}`);
    const { rows } = await db.query(
      `INSERT INTO projects (${allCols.join(', ')}) VALUES (${placeholders.join(', ')}) RETURNING *`,
      allVals
    );
    res.status(201).json(mapProject(rows[0]));
  } catch (err) { next(err); }
});

// PUT /api/projects/:id
router.put('/:id', async (req, res, next) => {
  try {
    const { cols, vals } = extractWritable(req.body);
    if (!cols.length) return res.status(400).json({ error: 'No writable fields provided' });
    const sets = cols.map((c, i) => `${c} = $${i + 2}`);
    sets.push('updated_at = now()');
    const { rows } = await db.query(
      `UPDATE projects SET ${sets.join(', ')} WHERE id = $1 RETURNING *`,
      [req.params.id, ...vals]
    );
    if (!rows.length) return res.status(404).json({ error: 'Project not found' });
    res.json(mapProject(rows[0]));
  } catch (err) { next(err); }
});

// DELETE /api/projects/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { rowCount } = await db.query('DELETE FROM projects WHERE id = $1', [req.params.id]);
    if (!rowCount) return res.status(404).json({ error: 'Project not found' });
    res.status(204).end();
  } catch (err) { next(err); }
});

module.exports = router;
