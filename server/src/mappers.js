'use strict';

// Maps a `projects` table row (snake_case) to the camelCase shape the
// React client consumes. Null/empty optional fields are omitted to keep
// payloads small.

function mapProject(row) {
  const out = {
    id: row.id,
    section: row.section_id,
    status: row.status,
    title: row.title,
    update: row.update_text,
    launchSoon: row.launch_soon,
    priority: row.priority,
    requiresApproval: row.requires_approval,
    position: row.position,
  };
  if (row.next_step) out.next = row.next_step;
  if (row.launch) out.launch = row.launch;
  if (row.progress != null) out.progress = row.progress;
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

function mapSection(row) {
  return {
    id: row.id,
    n: String(row.position).padStart(2, '0'),
    icon: row.icon,
    title: row.title,
    sub: row.sub,
  };
}

// Columns that can be written via the projects API, mapped to DB column names.
const PROJECT_WRITABLE = {
  section: 'section_id',
  status: 'status',
  title: 'title',
  update: 'update_text',
  next: 'next_step',
  launch: 'launch',
  launchSoon: 'launch_soon',
  progress: 'progress',
  priority: 'priority',
  detailText: 'detail_text',
  documentName: 'document_name',
  documentUrl: 'document_url',
  requiresApproval: 'requires_approval',
  approvalEmailTo: 'approval_email_to',
  approvalSubject: 'approval_subject',
  approvalBody: 'approval_body',
  teamGroups: 'team_groups',
  services: 'services',
  stats: 'stats',
  position: 'position',
};

const JSON_COLUMNS = new Set(['team_groups', 'services', 'stats']);

module.exports = { mapProject, mapSection, PROJECT_WRITABLE, JSON_COLUMNS };
