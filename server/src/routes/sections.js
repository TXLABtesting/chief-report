'use strict';

const express = require('express');
const db = require('../db');
const { mapSection } = require('../mappers');

const router = express.Router();

// GET /api/sections
router.get('/', async (_req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM sections ORDER BY position');
    res.json(rows.map(mapSection));
  } catch (err) { next(err); }
});

// GET /api/sections/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query('SELECT * FROM sections WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Section not found' });
    res.json(mapSection(rows[0]));
  } catch (err) { next(err); }
});

// POST /api/sections
router.post('/', async (req, res, next) => {
  try {
    const { id, position, icon, title, sub } = req.body;
    if (!id || !title) return res.status(400).json({ error: 'id and title are required' });
    const { rows } = await db.query(
      `INSERT INTO sections (id, position, icon, title, sub)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [id, position ?? 0, icon ?? 'squares', title, sub ?? '']
    );
    res.status(201).json(mapSection(rows[0]));
  } catch (err) { next(err); }
});

// PUT /api/sections/:id
router.put('/:id', async (req, res, next) => {
  try {
    const { position, icon, title, sub } = req.body;
    const { rows } = await db.query(
      `UPDATE sections SET
         position = COALESCE($2, position),
         icon     = COALESCE($3, icon),
         title    = COALESCE($4, title),
         sub      = COALESCE($5, sub)
       WHERE id = $1 RETURNING *`,
      [req.params.id, position, icon, title, sub]
    );
    if (!rows.length) return res.status(404).json({ error: 'Section not found' });
    res.json(mapSection(rows[0]));
  } catch (err) { next(err); }
});

// DELETE /api/sections/:id  (cascades to its projects)
router.delete('/:id', async (req, res, next) => {
  try {
    const { rowCount } = await db.query('DELETE FROM sections WHERE id = $1', [req.params.id]);
    if (!rowCount) return res.status(404).json({ error: 'Section not found' });
    res.status(204).end();
  } catch (err) { next(err); }
});

module.exports = router;
