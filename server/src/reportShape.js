'use strict';

const { STATUSES, SECTIONS, REPORTS } = require('./reportsData');

// camelCase (data file / API) → snake_case (DB column)
const PROJECT_COLUMNS = {
  section: 'section_id', status: 'status', title: 'title', update: 'update_text',
  next: 'next_step', challenges: 'challenges', launch: 'launch', launchSoon: 'launch_soon',
  progress: 'progress', target: 'target', priority: 'priority', needsAttention: 'needs_attention',
  detailText: 'detail_text', documentName: 'document_name', documentUrl: 'document_url',
  requiresApproval: 'requires_approval', approvalEmailTo: 'approval_email_to',
  approvalSubject: 'approval_subject', approvalBody: 'approval_body',
  teamGroups: 'team_groups', services: 'services', stats: 'stats',
};
const JSON_COLUMNS = new Set(['team_groups', 'services', 'stats']);

// DB row → API project shape (camelCase, nulls/false-defaults trimmed).
function mapProjectRow(row) {
  const out = {
    id: row.id, section: row.section_id, status: row.status, title: row.title,
    update: row.update_text, launchSoon: row.launch_soon, priority: row.priority,
    needsAttention: row.needs_attention,
  };
  if (row.next_step) out.next = row.next_step;
  if (row.challenges) out.challenges = row.challenges;
  if (row.launch) out.launch = row.launch;
  if (row.progress != null) out.progress = row.progress;
  if (row.target != null) out.target = row.target;
  if (row.requires_approval) out.requiresApproval = true;
  if (row.detail_text) out.detailText = row.detail_text;
  if (row.document_name) out.documentName = row.document_name;
  if (row.document_url) out.documentUrl = row.document_url;
  if (row.approval_email_to) out.approvalEmailTo = row.approval_email_to;
  if (row.approval_subject) out.approvalSubject = row.approval_subject;
  if (row.approval_body) out.approvalBody = row.approval_body;
  if (row.team_groups) out.teamGroups = row.team_groups;
  if (row.services) out.services = row.services;
  if (row.stats) out.stats = row.stats;
  return out;
}

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

// Build the API response straight from the data file (fallback when the DB is
// unreachable, and the seed source of truth).
function buildFileResponse() {
  return {
    statuses: STATUSES,
    sections: SECTIONS,
    reports: REPORTS.map((r, i) => ({
      id: r.id, label: r.label, dateIso: r.dateIso, isLatest: i === 0,
      topPriorities: r.topPriorities || [],
      summary: summarize(r.projects),
      projects: r.projects,
    })),
  };
}

// Build the API response from the database.
async function readDbResponse(db) {
  const [statuses, sections, reports, projects] = await Promise.all([
    db.query('SELECT key, label FROM statuses ORDER BY position'),
    db.query('SELECT id, position, icon, title, sub FROM sections ORDER BY position'),
    db.query('SELECT id, label, date_iso, top_priorities FROM reports ORDER BY date_iso DESC'),
    db.query('SELECT * FROM projects ORDER BY position, id'),
  ]);

  const byReport = new Map();
  for (const row of projects.rows) {
    if (!byReport.has(row.report_id)) byReport.set(row.report_id, []);
    byReport.get(row.report_id).push(mapProjectRow(row));
  }

  return {
    statuses: statuses.rows,
    sections: sections.rows.map((s) => ({ id: s.id, icon: s.icon, title: s.title, sub: s.sub })),
    reports: reports.rows.map((r, i) => {
      const ps = byReport.get(r.id) || [];
      return {
        id: r.id, label: r.label, dateIso: r.date_iso, isLatest: i === 0,
        topPriorities: r.top_priorities || [],
        summary: summarize(ps),
        projects: ps,
      };
    }),
  };
}

module.exports = { PROJECT_COLUMNS, JSON_COLUMNS, summarize, buildFileResponse, readDbResponse };
