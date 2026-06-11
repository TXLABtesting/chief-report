// Week / report-date filter. Selecting a date reloads the whole page data
// for that report.
export default function DateFilter({ reports, selectedId, onSelect }) {
  if (!reports || reports.length === 0) return null;
  return (
    <div className="datefilter">
      <i className="ph-bold ph-calendar-blank" />
      <label htmlFor="reportDate">تقرير الأسبوع</label>
      <div className="select-wrap">
        <select id="reportDate" value={selectedId || ''} onChange={(e) => onSelect(e.target.value)}>
          {reports.map((r) => (
            <option key={r.id} value={r.id}>
              {r.label}{r.isLatest ? ' — الأحدث' : ''}
            </option>
          ))}
        </select>
        <i className="ph-bold ph-caret-down" />
      </div>
    </div>
  );
}
