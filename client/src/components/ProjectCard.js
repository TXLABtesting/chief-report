import { useState } from 'react';
import StatusBadge from './StatusBadge';

// Outlook-compatible mailto with a ready approval template. Subject/body are
// generated from the project name unless the project supplies overrides.
function buildApprovalMailto(p) {
  const to = p.approvalEmailTo || '';
  const subject = p.approvalSubject || `اعتماد المشروع - ${p.title}`;
  const body =
    p.approvalBody ||
    `السادة الفريق،\r\n\r\nنفيدكم بأنه تم إعتماد المشروع التالي:\r\n\r\nاسم المشروع: ${p.title}\r\n\r\nمع التحية،`;
  return `mailto:${to}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
}

function TeamGroups({ groups }) {
  const dot = { ok: 'team ok', pend: 'team pend', none: 'team none' };
  return groups.map((g, i) => (
    <div key={i}>
      <p className="teams-cap">{g.caption}</p>
      <div className="teams">
        {g.rows.map((r, j) => (
          <div className={dot[r.state]} key={j}>
            <span className="td" />
            <span className="tn">{r.name}</span>
            <span className="ts">{r.note}</span>
          </div>
        ))}
      </div>
    </div>
  ));
}

export default function ProjectCard({ p }) {
  const [open, setOpen] = useState(false);
  const hasDetails = Boolean(p.detailText || p.teamGroups || p.services);

  return (
    <article className={`card${p.priority ? ' prio' : ''}`}>
      <div className="card-top">
        <div>
          <h3>{p.title}</h3>
          {p.priority && (
            <span className="prio-flag"><i className="ph-fill ph-flag" /> يحتاج متابعة</span>
          )}
        </div>
        <StatusBadge status={p.status} />
      </div>

      {p.stats ? (
        <div className="stat-grid">
          {p.stats.map((s, i) => (
            <div className={`stat${s.amber ? ' amber' : ''}`} key={i}>
              <b>{s.n}</b><span>{s.l}</span>
            </div>
          ))}
        </div>
      ) : (
        <div className="meta">
          <div className="meta-row">
            <div className="mic"><i className="ph ph-arrows-clockwise" /></div>
            <div className="mc"><dt>آخر تحديث</dt><dd>{p.update}</dd></div>
          </div>
          {p.next && (
            <div className="meta-row next">
              <div className="mic"><i className="ph-bold ph-arrow-left" /></div>
              <div className="mc"><dt>الخطوة القادمة</dt><dd>{p.next}</dd></div>
            </div>
          )}
        </div>
      )}

      {typeof p.progress === 'number' && (
        <div className="pbar-wrap">
          <div className="pbar-lbl"><span>نسبة الاستجابة</span><b>{p.progress}%</b></div>
          <div className="pbar"><i style={{ width: `${p.progress}%` }} /></div>
        </div>
      )}

      {p.launch && (
        <span className={`launch${p.launchSoon ? ' soon' : ''}`}>
          <i className={`ph-bold ${p.launchSoon ? 'ph-rocket-launch' : 'ph-calendar-blank'}`} /> {p.launch}
        </span>
      )}

      {(p.documentUrl || p.requiresApproval) && (
        <div className="actions">
          {p.documentUrl && (
            <a
              className="btn btn-soft"
              href={p.documentUrl}
              target="_blank"
              rel="noopener noreferrer"
              download={p.documentName}
              title={p.documentName}
            >
              <i className="ph-bold ph-file-pdf" /> تحميل المستند
            </a>
          )}
          {p.requiresApproval && (
            <a className="btn btn-primary" href={buildApprovalMailto(p)}>
              <i className="ph-bold ph-seal-check" /> اعتماد
            </a>
          )}
        </div>
      )}

      {hasDetails && (
        <>
          <button
            className="acc-btn"
            aria-expanded={open}
            onClick={() => setOpen((o) => !o)}
          >
            <span>عرض التفاصيل الكاملة</span>
            <i className="ph-bold ph-caret-down" />
          </button>
          <div className="acc-panel" style={{ maxHeight: open ? '1200px' : 0 }}>
            <div className="acc-inner">
              {p.detailText && <p>{p.detailText}</p>}
              {p.teamGroups && <TeamGroups groups={p.teamGroups} />}
              {p.services && (
                <>
                  <p>الخدمات المدرجة للعرض والاعتماد:</p>
                  <div className="svc-list">
                    {p.services.map((s, i) => (
                      <div className="svc" key={i}>
                        <i className={`ph ph-${s.icon}`} /> {s.label}
                      </div>
                    ))}
                  </div>
                </>
              )}
            </div>
          </div>
        </>
      )}
    </article>
  );
}
