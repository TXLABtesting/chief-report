const DOTS = {
  done: 'var(--done-dot)',
  progress: 'var(--prog-dot)',
  approval: 'var(--appr-dot)',
  review: 'var(--revw-dot)',
  inputs: 'var(--inpt-dot)',
};

export default function Controls({ query, onQuery, status, onStatus, statuses }) {
  const chips = [{ key: 'all', label: 'الكل' }, ...statuses];
  return (
    <div className="controls">
      <div className="search">
        <i className="ph ph-magnifying-glass" />
        <input
          type="search"
          value={query}
          onChange={(e) => onQuery(e.target.value)}
          placeholder="ابحث في المشاريع والمبادرات…"
          aria-label="بحث"
        />
      </div>
      <div className="chips">
        {chips.map((c) => (
          <button
            key={c.key}
            className={`chip${status === c.key ? ' active' : ''}`}
            onClick={() => onStatus(c.key)}
          >
            {DOTS[c.key] && <span className="d" style={{ background: DOTS[c.key] }} />}
            {c.label}
          </button>
        ))}
      </div>
    </div>
  );
}
