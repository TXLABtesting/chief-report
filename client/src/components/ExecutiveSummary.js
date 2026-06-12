/** Section quick-nav cards — kept first at the top of the page. */
export default function ExecutiveSummary({ report, sections }) {
  const projects = report.projects;
  return (
    <section className="section exec">
      <div className="sum-grid">
        {sections.map((sec) => {
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
