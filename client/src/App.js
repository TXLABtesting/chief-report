import { useEffect, useMemo, useState } from 'react';
import { api } from './api';
import Hero from './components/Hero';
import ExecutiveSummary from './components/ExecutiveSummary';
import Controls from './components/Controls';
import ReportSection from './components/ReportSection';
import Footer from './components/Footer';

export default function App() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');

  useEffect(() => {
    api.getReport().then(setData).catch((e) => setError(e.message));
  }, []);

  const sections = data ? data.sections : [];
  const statuses = data ? data.statuses : [];

  const filtered = useMemo(() => {
    const q = query.trim();
    return sections
      .map((section) => ({
        section,
        projects: (section.projects || []).filter(
          (p) =>
            (status === 'all' || p.status === status) &&
            (!q || `${p.title} ${p.update} ${p.next || ''} ${p.detailText || ''}`.includes(q))
        ),
      }))
      .filter((g) => g.projects.length > 0);
  }, [sections, query, status]);

  return (
    <div className="wrap">
      <Hero />
      <main>
        {error && (
          <div className="empty">
            <i className="ph ph-warning-circle" />
            <p>تعذّر تحميل التقرير.<br />{error}</p>
          </div>
        )}

        {data && <ExecutiveSummary sections={sections} />}

        <Controls
          query={query}
          onQuery={setQuery}
          status={status}
          onStatus={setStatus}
          statuses={statuses}
        />

        <div id="report">
          {filtered.map(({ section, projects }) => (
            <ReportSection key={section.id} section={section} projects={projects} />
          ))}
          {data && filtered.length === 0 && (
            <div className="empty">
              <i className="ph ph-funnel-simple" />
              <p>لا توجد نتائج مطابقة.<br />جرّب تعديل البحث أو الفلتر.</p>
            </div>
          )}
          {!data && !error && (
            <div className="empty"><i className="ph ph-spinner" /><p>جارٍ التحميل…</p></div>
          )}
        </div>
      </main>
      <Footer />
    </div>
  );
}
