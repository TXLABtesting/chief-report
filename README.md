# Chief Report — ملخص مشاريع وعمليات مركز التجربة المتكاملة

تقرير تنفيذي أسبوعي **full-stack** — واجهة React عربية (RTL) فوق واجهة برمجية Node.js وقاعدة بيانات PostgreSQL، حاوية Docker، وجاهز للنشر على **Render** مع قاعدة بيانات **Neon**.

A full-stack weekly executive report: an Arabic **RTL React** client (built with **Babel + Webpack**, plain CSS) talking to a **Node.js + Express** API over **PostgreSQL (Neon)**, containerised with **Docker** and deployable on **Render**.

---

## التقنيات / Stack

| Layer | Tech |
|------|------|
| Client | **React 18**, **Babel**, **Webpack**, **vanilla CSS** (no TypeScript, no Tailwind) |
| Server | **Node.js**, **Express**, **pg** |
| Database | **PostgreSQL** — **Neon** in production, Postgres container locally |
| Packaging | **Docker** (multi-stage) + **docker compose** |
| Hosting | **Render** (Docker web service) + **Neon** (managed Postgres) |

The Express server serves both the REST API **and** the compiled React app, so production is a **single web service** plus the external Neon database.

---

## بنية المشروع / Structure

```
chief-report/
├─ Dockerfile              # multi-stage: build client → run server
├─ docker-compose.yml      # local: postgres + app
├─ render.yaml             # Render blueprint
├─ package.json            # root scripts (dev/build/db)
├─ .env.example
├─ db/
│  └─ schema.sql           # tables: sections, statuses, projects
├─ docs/                   # supporting documents (served at /docs)
│  └─ supplier-satisfaction-survey-2025.pdf
├─ server/                 # Node.js + Express API
│  ├─ src/
│  │  ├─ index.js          # app entry (API + static client)
│  │  ├─ db.js             # pg pool (SSL for Neon)
│  │  ├─ mappers.js        # row ⇄ API shape
│  │  └─ routes/           # report, sections, projects, statuses
│  └─ scripts/             # migrate.js, seed.js, seedData.js
└─ client/                 # React (Babel + Webpack)
   ├─ webpack.config.js · .babelrc
   ├─ public/index.html
   └─ src/
      ├─ App.js · api.js · index.js
      ├─ components/        # Hero, ExecutiveSummary, Controls, ReportSection,
      │                     # ProjectCard, StatusBadge, Footer
      └─ styles/styles.css  # navy DLS theme (vanilla CSS)
```

---

## التشغيل محلياً / Run locally

### الأسرع — Docker (option A)

```bash
docker compose up --build
# → http://localhost:3001  (migrates + seeds automatically)
```

### بدون Docker — Node + Postgres (option B)

```bash
cp .env.example .env          # set DATABASE_URL (Neon or local postgres)
npm run install:all           # installs server + client deps
npm run db:setup              # create tables + seed the report
npm run dev                   # API :3001  +  client dev server :3000
# open http://localhost:3000  (proxies /api and /docs to :3001)
```

---

## النشر / Deploy — Neon + Render

### 1) قاعدة بيانات Neon
1. Create a project at **https://neon.tech** → copy the **connection string**
   (`postgres://…@…neon.tech/…?sslmode=require`).
2. Load the schema + seed data into it from your machine:
   ```bash
   DATABASE_URL="postgres://…neon.tech/…?sslmode=require" npm run db:setup
   ```

### 2) النشر على Render
1. Push this repo to GitHub (done).
2. On **https://render.com** → **New → Blueprint**, select the repo.
   Render reads `render.yaml` and creates the Docker web service.
3. In the service’s **Environment**, add **`DATABASE_URL`** = your Neon string.
4. **Deploy.** Render builds the Dockerfile and serves the app; health check is `/api/health`.

> Render injects `PORT` automatically. The image needs no build settings — it’s all in the Dockerfile.

---

## واجهة برمجة التطبيقات / API

Base path `/api`. Full CRUD over the report content.

| Method | Path | Purpose |
|-------|------|---------|
| GET | `/api/health` | liveness probe |
| GET | `/api/report` | sections with nested projects (what the client renders) |
| GET | `/api/statuses` | status vocabulary (filter chips) |
| GET · POST | `/api/sections` · `/api/sections/:id` | list / create |
| PUT · DELETE | `/api/sections/:id` | update / delete (cascades to projects) |
| GET | `/api/projects?section=&status=` | list / filter |
| POST | `/api/projects` | create |
| GET · PUT · DELETE | `/api/projects/:id` | read / update / delete |

Example — update a project’s status:
```bash
curl -X PUT https://<your-app>.onrender.com/api/projects/tms \
  -H 'Content-Type: application/json' \
  -d '{"status":"done"}'
```

---

## الميزات / Features

- **بحث وفلترة** بالحالة (مكتمل · قيد التنفيذ · بانتظار اعتماد · سيتم العرض · بانتظار مدخلات).
- **تحميل المستند** — يظهر فقط للمشاريع التي لها مستند مرفق (`documentUrl`)، ويفتح/ينزّل الملف.
- **زر الاعتماد** — يظهر فقط عند `requiresApproval`، ويفتح مسودة بريد في Outlook عبر `mailto` بقالب جاهز (لا يُرسل تلقائياً).
- **Accordion** للتفاصيل الطويلة (حالة الفرق، قائمة الخدمات، إحصاءات التسجيل).
- **Mobile-first / RTL** بالكامل، خطوط Noto Kufi Arabic و Alexandria، أيقونات Phosphor.

كل المحتوى محفوظ في قاعدة البيانات ويمكن تعديله عبر واجهة الـ API الكاملة (CRUD).
