export default function Footer({ reportLabel }) {
  return (
    <footer>
      <div className="frow">
        <div className="fc"><i className="ph-fill ph-bank" /></div>
        <b>مركز التجربة المتكاملة</b>
      </div>
      <p className="meta-foot">تحديث أسبوعي{reportLabel ? ` · آخر تحديث: ${reportLabel}` : ''}</p>
    </footer>
  );
}
