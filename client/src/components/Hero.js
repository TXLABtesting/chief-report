export default function Hero({ reportLabel }) {
  return (
    <header className="hero">
      <div className="hero-top">
        <div className="crest"><i className="ph-fill ph-bank" /></div>
        <div className="crest-txt">
          <b>مركز التجربة المتكاملة</b>
          قطاع الخدمات المركزية
        </div>
      </div>
      <div className="kicker"><span className="ln" /> تحديث أسبوعي</div>
      <h1>ملخص مشاريع وعمليات مركز التجربة المتكاملة</h1>
      <p className="sub">أبرز المشاريع والمبادرات والعمليات القائمة ضمن الفريق — في لمحة سريعة.</p>
      {reportLabel && (
        <span className="date-pill">
          <i className="ph-bold ph-calendar-check" /> {reportLabel}
        </span>
      )}
    </header>
  );
}
