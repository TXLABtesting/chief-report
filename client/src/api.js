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
  getReport: () => request('/report'),
  // Full CRUD is available too, e.g.:
  //   api.createProject(body) / api.updateProject(id, body) / api.deleteProject(id)
  createProject: (body) => request('/projects', { method: 'POST', body: JSON.stringify(body) }),
  updateProject: (id, body) => request(`/projects/${id}`, { method: 'PUT', body: JSON.stringify(body) }),
  deleteProject: (id) => request(`/projects/${id}`, { method: 'DELETE' }),
};
