'use strict';

const express = require('express');
const { STATUSES, SECTIONS, REPORTS } = require('../reportsData');

const router = express.Router();

// Executive summary computed from a report's projects.
function summarize(projects) {
  const count = (fn) => projects.filter(fn).length;
  const attention = projects
    .filter((p) => p.needsAttention || p.status === 'approval' || p.status === 'delayed')
    .map((p) => ({ id: p.id, title: p.title, status: p.status, section: p.section }));
  return {
    inProgress: count((p) => p.status === 'progress'),
    completed: count((p) => p.status === 'done'),
    delayed: count((p) => p.status === 'delayed'),
    ready: count((p) => p.status === 'ready'),
    attention,
  };
}

// GET /api/report — all weekly reports (newest first) + global sections/statuses.
// The client renders the selected week and switches instantly via the filter.
router.get('/', (_req, res) => {
  const reports = REPORTS.map((r, i) => ({
    id: r.id,
    label: r.label,
    dateIso: r.dateIso,
    isLatest: i === 0,
    topPriorities: r.topPriorities || [],
    summary: summarize(r.projects),
    projects: r.projects,
  }));
  res.json({ statuses: STATUSES, sections: SECTIONS, reports });
});

module.exports = router;
