import ProjectCard from './ProjectCard';

export default function ReportSection({ section, projects, n }) {
  return (
    <section className="rep-sec" id={`sec-${section.id}`}>
      <div className="sec-head">
        <div className="sec-num">{n}</div>
        <div className="t">
          <h2>{section.title}</h2>
          <p>{section.sub}</p>
        </div>
        <span className="ct">{projects.length}</span>
      </div>
      <div className="cards">
        {projects.map((p) => (
          <ProjectCard key={p.id} p={p} />
        ))}
      </div>
    </section>
  );
}
