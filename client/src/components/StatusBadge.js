const CLASS = {
  done: 'st-done',
  progress: 'st-progress',
  approval: 'st-approval',
  review: 'st-review',
  inputs: 'st-inputs',
};

const LABEL = {
  done: 'مكتمل',
  progress: 'قيد التنفيذ',
  approval: 'بانتظار اعتماد',
  review: 'سيتم العرض',
  inputs: 'بانتظار مدخلات',
};

export default function StatusBadge({ status }) {
  return (
    <span className={`badge ${CLASS[status] || ''}`}>
      <span className="bd" />
      {LABEL[status] || status}
    </span>
  );
}
