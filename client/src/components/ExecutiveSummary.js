import StatusBadge from './StatusBadge';

/** «الملخص التنفيذي» — KPIs + top priorities + items needing a decision,
 *  followed by the section quick-nav cards. */
export default function ExecutiveSummary({ report, sections }) {
  const s = report.summary;
  const projects = report.projects;
  const visibleSections = sections.filter((sec) => projects.some((p) => p.section === sec.id));

  return (
    <section className="section exec">
      <div className="eyebrow"><i className="ph-bold ph-gauge" /> الملخص التنفيذي</div>

      {/* KPIs */}
      <div className="kpi-grid">
        <div className="kpi kpi-prog"><b>{s.inProgress}</b><span>قيد التنفيذ</span></div>
        <div className="kpi kpi-done"><b>{s.completed}</b><span>مكتمل</span></div>
        <div className="kpi kpi-late"><b>{s.delayed}</b><span>متأخّر عن الجدول</span></div>
      </div>

      {/* Top 3 priorities for next week */}
      {report.topPriorities && report.topPriorities.length > 0 && (
        <div className="exec-block">
          <div className="exec-h"><i className="ph-fill ph-star" /> أهم 3 أولويات للأسبوع القادم</div>
          <ol className="prio-list">
            {report.topPriorities.map((p, i) => (<li key={i}>{p}</li>))}
          </ol>
        </div>
      )}

      {/* Items requiring a decision or follow-up */}
      {s.attention && s.attention.length > 0 && (
        <div className="exec-block">
          <div className="exec-h">
            <i className="ph-fill ph-flag" /> بنود تتطلّب قراراً أو متابعة
            <span className="n">{s.attention.length}</span>
          </div>
          <div className="att-list">
            {s.attention.map((a) => (
              <a className="att-item" href={`#sec-${a.section}`} key={a.id}>
                <span className="att-t">{a.title}</span>
                <StatusBadge status={a.status} />
              </a>
            ))}
          </div>
        </div>
      )}

      {/* Section quick-nav */}
      <div className="sum-grid">
        {visibleSections.map((sec) => {
          const inSec = projects.filter((p) => p.section === sec.id);
          const count = inSec.length;
          const att = inSec.filter((p) => p.needsAttention).length;
          return (
            <a className="sum-card" href={`#sec-${sec.id}`} key={sec.id}>
              <div className="ic"><i className={`ph-bold ph-${sec.icon}`} /></div>
              <div className="col">
                <h3>{sec.title}</h3>
                <div className="cnt">
                  <b>{count}</b> {count > 10 ? 'بنود' : 'مشاريع'}
                  {att > 0 && <span className="pr"> · {att} للمتابعة</span>}
                </div>
              </div>
            </a>
          );
        })}
      </div>
    </section>
  );
}
