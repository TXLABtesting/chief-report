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

## إضافة تقرير أسبوعي / Add a weekly report

محتوى التقارير كله في ملف واحد: **`server/src/reportsData.js`** (مصدر الحقيقة).
لإضافة أسبوع جديد:

1. افتح `server/src/reportsData.js`.
2. انسخ كائن تقرير موجوداً، وضَع النسخة **في أعلى مصفوفة `REPORTS`** (الأحدث أولاً).
3. عدّل `id` و`label` و`dateIso`، ثم حدّث `projects` و`topPriorities`.
4. انشر (push) — يظهر الأسبوع الجديد تلقائياً في الفلتر ويصبح الافتراضي.

```js
const REPORT_2026_06_19 = {
  id: '2026-06-19', label: 'الجمعة 19 يونيو 2026', dateIso: '2026-06-19',
  topPriorities: ['…', '…', '…'],
  projects: [
    { id: 'tms', section: 'strategic', status: 'progress',
      title: '…', update: '…', next: '…',
      challenges: '…', launch: '…', launchSoon: true,
      needsAttention: true /* requiresApproval, documentUrl, teamGroups, services, stats … */ },
  ],
};
const REPORTS = [REPORT_2026_06_19, REPORT_2026_06_12, REPORT_2026_06_05];
```

**الحالات المتاحة:** `done` مكتمل · `progress` قيد التنفيذ · `ready` جاهز للعرض ·
`approval` بانتظار اعتماد · `inputs` بانتظار مدخلات · `delayed` متأخّر عن الجدول.
ضع `needsAttention: true` لإبراز أي بند يحتاج قراراً أو متابعة من رئيس القطاع.

> المحتوى يُخدَم من ملف البيانات مباشرةً عبر `/api/report` — لا حاجة لأي تحديث على قاعدة
> البيانات. قاعدة Neon اختيارية، والموقع يعمل حتى لو تعذّر الاتصال بها.

---

## واجهة برمجة التطبيقات / API

| Method | Path | Purpose |
|-------|------|---------|
| GET | `/api/health` | liveness probe |
| GET | `/api/report` | كل التقارير الأسبوعية + الأقسام والحالات (ما تعرضه الواجهة) |

`/api/report` يعيد `{ statuses, sections, reports: [{ id, label, dateIso, isLatest, topPriorities, summary, projects }] }` مرتّبة من الأحدث.

---

## الميزات / Features

- **فلتر أسبوعي** — اختيار تاريخ التقرير يحدّث الصفحة بالكامل لذلك الأسبوع.
- **ملخص تنفيذي** أعلى الصفحة: عدد المشاريع (قيد التنفيذ / مكتمل / متأخّر)، أهم 3 أولويات، وبنود تتطلّب قراراً أو متابعة.
- **حالات وألوان واضحة** لكل مشروع (Badges)، مع إبراز البنود التي تحتاج تدخّل رئيس القطاع.
- **بحث وفلترة** بالحالة، و**التحديات** و**الخطوة القادمة** و**موعد الإطلاق المتوقّع** لكل بند.
- **تحميل المستند** و**زر الاعتماد** (مسودة Outlook عبر `mailto`).
- **Accordion** للتفاصيل الطويلة، و**استجابة كاملة** للهاتف واللابتوب والشاشات الكبيرة، **RTL** بالكامل.
