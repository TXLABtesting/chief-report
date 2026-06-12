-- Chief Report — database schema (PostgreSQL / Neon, portable to any Postgres)
-- Weekly executive report model. Run via `npm run db:migrate` or the server's
-- startup bootstrap. Safe to run repeatedly (CREATE IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS reports (
  id              TEXT PRIMARY KEY,          -- e.g. '2026-06-12'
  label           TEXT NOT NULL,             -- e.g. 'الجمعة 12 يونيو 2026'
  date_iso        TEXT NOT NULL,             -- 'YYYY-MM-DD' (ISO; sorts chronologically)
  position        INT  NOT NULL DEFAULT 0,
  top_priorities  JSONB NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS sections (
  id        TEXT PRIMARY KEY,
  position  INT  NOT NULL,
  icon      TEXT NOT NULL,
  title     TEXT NOT NULL,
  sub       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS statuses (
  key       TEXT PRIMARY KEY,
  label     TEXT NOT NULL,
  position  INT  NOT NULL
);

CREATE TABLE IF NOT EXISTS projects (
  report_id          TEXT NOT NULL REFERENCES reports(id)  ON DELETE CASCADE,
  id                 TEXT NOT NULL,                       -- unique within a report
  position           INT  NOT NULL DEFAULT 0,
  section_id         TEXT NOT NULL REFERENCES sections(id),
  status             TEXT NOT NULL REFERENCES statuses(key),
  title              TEXT NOT NULL,
  update_text        TEXT NOT NULL,
  next_step          TEXT,
  challenges         TEXT,
  launch             TEXT,
  launch_soon        BOOLEAN NOT NULL DEFAULT FALSE,
  progress           INT,
  target             INT,
  priority           BOOLEAN NOT NULL DEFAULT FALSE,
  needs_attention    BOOLEAN NOT NULL DEFAULT FALSE,
  detail_text        TEXT,
  document_name      TEXT,
  document_url       TEXT,
  requires_approval  BOOLEAN NOT NULL DEFAULT FALSE,
  approval_email_to  TEXT,
  approval_subject   TEXT,
  approval_body      TEXT,
  team_groups        JSONB,
  services           JSONB,
  stats              JSONB,
  PRIMARY KEY (report_id, id)
);

CREATE INDEX IF NOT EXISTS idx_projects_report  ON projects(report_id);
CREATE INDEX IF NOT EXISTS idx_projects_section ON projects(section_id);
