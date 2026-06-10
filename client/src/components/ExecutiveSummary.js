export default function ExecutiveSummary({ sections }) {
  return (
    <section className="section">
      <div className="eyebrow"><i className="ph-bold ph-squares-four" /> الملخص التنفيذي</div>
      <div className="sum-grid">
        {sections.map((s) => {
          const count = (s.projects || []).length;
          const prio = (s.projects || []).filter((p) => p.priority).length;
          return (
            <a className="sum-card" href={`#sec-${s.id}`} key={s.id}>
              <div className="ic"><i className={`ph-bold ph-${s.icon}`} /></div>
              <div className="col">
                <h3>{s.title}</h3>
                <div className="cnt">
                  <b>{count}</b> {count > 10 ? 'بنود' : 'مشاريع'}
                  {prio > 0 && <span className="pr"> · {prio} للمتابعة</span>}
                </div>
              </div>
            </a>
          );
        })}
      </div>
    </section>
  );
}
