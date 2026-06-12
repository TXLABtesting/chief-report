import { useEffect, useMemo, useState } from 'react';
import { api } from './api';
import Hero from './components/Hero';
import DateFilter from './components/DateFilter';
import ExecutiveSummary from './components/ExecutiveSummary';
import Controls from './components/Controls';
import ReportSection from './components/ReportSection';
import Footer from './components/Footer';

export default function App() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [selectedId, setSelectedId] = useState(null);
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');

  useEffect(() => {
    api
      .getReport()
      .then((d) => {
        setData(d);
        if (d.reports && d.reports.length) setSelectedId(d.reports[0].id);
      })
      .catch((e) => setError(e.message));
  }, []);

  const sections = data ? data.sections : [];
  const statuses = data ? data.statuses : [];
  const reports = data ? data.reports : [];
  const active = reports.find((r) => r.id === selectedId) || reports[0] || null;

  // Reset filters when switching weeks so the whole page reflects that report.
  useEffect(() => {
    setQuery('');
    setStatus('all');
  }, [selectedId]);

  const grouped = useMemo(() => {
    if (!active) return [];
    const q = query.trim();
    return sections
      .map((section) => ({
        section,
        projects: active.projects.filter(
          (p) =>
            p.section === section.id &&
            (status === 'all' || p.status === status) &&
            (!q ||
              `${p.title} ${p.update} ${p.next || ''} ${p.challenges || ''} ${p.detailText || ''}`.includes(q))
        ),
      }))
      .filter((g) => g.projects.length > 0);
  }, [active, sections, query, status]);

  return (
    <div className="wrap">
      <Hero reportLabel={active && active.label} />
      <main>
        {error && (
          <div className="empty">
            <i className="ph ph-warning-circle" />
            <p>تعذّر تحميل التقرير.<br />{error}</p>
          </div>
        )}

        {active && (
          <>
            <DateFilter reports={reports} selectedId={selectedId} onSelect={setSelectedId} />
            <ExecutiveSummary report={active} sections={sections} />
            <Controls query={query} onQuery={setQuery} status={status} onStatus={setStatus} statuses={statuses} />
            <div id="report">
              {grouped.map(({ section, projects }, i) => (
                <ReportSection
                  key={section.id}
                  section={section}
                  projects={projects}
                  n={String(i + 1).padStart(2, '0')}
                />
              ))}
              {grouped.length === 0 && (
                <div className="empty">
                  <i className="ph ph-funnel-simple" />
                  <p>لا توجد نتائج مطابقة.<br />جرّب تعديل البحث أو الفلتر.</p>
                </div>
              )}
            </div>
          </>
        )}

        {!data && !error && (
          <div className="empty"><i className="ph ph-spinner" /><p>جارٍ التحميل…</p></div>
        )}
      </main>
      <Footer reportLabel={active && active.label} />
    </div>
  );
}
