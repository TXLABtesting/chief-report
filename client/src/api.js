// Tiny API helper. Same-origin in production; proxied to the Express server
// in dev (see webpack devServer.proxy).

const BASE = '/api';

async function request(path, options) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const detail = await res.json().catch(() => ({}));
    throw new Error(detail.error || `Request failed: ${res.status}`);
  }
  return res.status === 204 ? null : res.json();
}

export const api = {
  // Returns { statuses, sections, reports:[{ id, label, dateIso, isLatest,
  //          topPriorities, summary, projects }] } newest report first.
  getReport: () => request('/report'),
};
