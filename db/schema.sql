-- Chief Report — database schema (PostgreSQL / Neon)
-- Run with: npm run db:migrate

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
  id                 TEXT PRIMARY KEY,
  section_id         TEXT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
  status             TEXT NOT NULL REFERENCES statuses(key),
  title              TEXT NOT NULL,
  update_text        TEXT NOT NULL,
  next_step          TEXT,
  launch             TEXT,
  launch_soon        BOOLEAN NOT NULL DEFAULT FALSE,
  progress           INT,
  priority           BOOLEAN NOT NULL DEFAULT FALSE,
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
  position           INT NOT NULL DEFAULT 0,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_projects_section ON projects(section_id);
CREATE INDEX IF NOT EXISTS idx_projects_status  ON projects(status);
