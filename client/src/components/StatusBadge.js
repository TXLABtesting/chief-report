const CLASS = {
  done: 'st-done',
  progress: 'st-progress',
  ready: 'st-ready',
  approval: 'st-approval',
  inputs: 'st-inputs',
  delayed: 'st-delayed',
};

const LABEL = {
  done: 'مكتمل',
  progress: 'قيد التنفيذ',
  ready: 'جاهز للعرض',
  approval: 'بانتظار اعتماد',
  inputs: 'بانتظار مدخلات',
  delayed: 'متأخّر عن الجدول',
};

export default function StatusBadge({ status }) {
  return (
    <span className={`badge ${CLASS[status] || ''}`}>
      <span className="bd" />
      {LABEL[status] || status}
    </span>
  );
}
