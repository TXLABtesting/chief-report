-- Chief Report — paste into Neon Console -> SQL Editor -> Run
-- Creates tables if missing and loads all report data. Safe to re-run.

-- Chief Report — database schema (PostgreSQL / Neon)
-- Run with: npm run db:migrate

CREATE TABLE IF NOT EXISTS sections (
  id        TEXT PRIMARY KEY,
  position  INT  NOT NULL,
  icon      TEXT NOT NULL,
  title     TEXT NOT NULL,
  sub       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS statuses (
  key       TEXT PRIMARY KEY,
  label     TEXT NOT NULL,
  position  INT  NOT NULL
);

CREATE TABLE IF NOT EXISTS projects (
  id                 TEXT PRIMARY KEY,
  section_id         TEXT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
  status             TEXT NOT NULL REFERENCES statuses(key),
  title              TEXT NOT NULL,
  update_text        TEXT NOT NULL,
  next_step          TEXT,
  launch             TEXT,
  launch_soon        BOOLEAN NOT NULL DEFAULT FALSE,
  progress           INT,
  priority           BOOLEAN NOT NULL DEFAULT FALSE,
  detail_text        TEXT,
  document_name      TEXT,
  document_url       TEXT,
  requires_approval  BOOLEAN NOT NULL DEFAULT FALSE,
  approval_email_to  TEXT,
  approval_subject   TEXT,
  approval_body      TEXT,
  team_groups        JSONB,
  services           JSONB,
  stats              JSONB,
  position           INT NOT NULL DEFAULT 0,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_projects_section ON projects(section_id);
CREATE INDEX IF NOT EXISTS idx_projects_status  ON projects(status);

INSERT INTO statuses (key,label,position) VALUES ('done','مكتمل',1) ON CONFLICT (key) DO NOTHING;
INSERT INTO statuses (key,label,position) VALUES ('progress','قيد التنفيذ',2) ON CONFLICT (key) DO NOTHING;
INSERT INTO statuses (key,label,position) VALUES ('approval','بانتظار اعتماد',3) ON CONFLICT (key) DO NOTHING;
INSERT INTO statuses (key,label,position) VALUES ('review','سيتم العرض',4) ON CONFLICT (key) DO NOTHING;
INSERT INTO statuses (key,label,position) VALUES ('inputs','بانتظار مدخلات',5) ON CONFLICT (key) DO NOTHING;

INSERT INTO sections (id,position,icon,title,sub) VALUES ('strategic',1,'target','المشاريع الاستراتيجية','التحول إلى الذكاء الاصطناعي ونظم الأداء') ON CONFLICT (id) DO NOTHING;
INSERT INTO sections (id,position,icon,title,sub) VALUES ('mocasmart',2,'squares-four','أتمتة الخدمات — MOCAsmart','خدمات ذاتية للموظفين') ON CONFLICT (id) DO NOTHING;
INSERT INTO sections (id,position,icon,title,sub) VALUES ('ops',3,'gear-six','الأنظمة التشغيلية','الخدمات المركزية') ON CONFLICT (id) DO NOTHING;
INSERT INTO sections (id,position,icon,title,sub) VALUES ('culture',4,'confetti','البيئة المؤسسية','مبادرات شهر يونيو 2026') ON CONFLICT (id) DO NOTHING;
INSERT INTO sections (id,position,icon,title,sub) VALUES ('crm',5,'chart-bar','علاقات المتعاملين','استبيانات وتسجيل الموردين') ON CONFLICT (id) DO NOTHING;

INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,detail_text) VALUES ('gov-ai',0,'strategic','progress','توفير البيانات للقيادة عبر منصة GOV AI','تم تسليم كل المتطلبات وإجراء الاختبارات، ومشاركة الملاحظات مع الأخ صقر بن غالب.','معالجة الملاحظات الواردة من الاختبارات.','تم تسليم كامل المتطلبات وإجراء الاختبارات من قبل الأخ علي ورئيس القطاع، وتمت مشاركة الملاحظات مع الأخ صقر بن غالب لاستكمالها.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,priority,team_groups) VALUES ('internal-transform',1,'strategic','inputs','التحول الذكي للعمليات الداخلية','تم تذكير جميع الفرق لاستكمال البيانات المتبقية؛ 6 فرق أنجزت و4 لم ترسل بعد.','استلام مدخلات الفرق المتبقية وإغلاق المتطلبات.',TRUE,'[{"caption":"فرق أنجزت / حدّثت بياناتها","rows":[{"name":"المالية","note":"تزويد المدخلات اليوم","state":"ok"},{"name":"البروتوكول","note":"أكمل — بانتظار اعتماد عبدالله علي","state":"pend"},{"name":"المحتوى","note":"مريم شاركت القائمة المحدّثة","state":"ok"},{"name":"الإعلام","note":"لا تحديثات إضافية","state":"ok"},{"name":"الموارد البشرية","note":"مكتمل — بانتظار مجلد النماذج","state":"pend"},{"name":"الفعاليات والتصوير","note":"حُدّثت — بانتظار الملفات فقط","state":"pend"}]},{"caption":"فرق وإدارات متبقية","rows":[{"name":"الأمن السيبراني","note":"جارٍ العمل","state":"pend"},{"name":"تقنية المعلومات","note":"لا تحديثات","state":"none"},{"name":"الشؤون القانونية","note":"لم يصل رد","state":"none"},{"name":"إدارة المشاريع","note":"المشاركة الاثنين","state":"pend"},{"name":"التحول الرقمي (TX)","note":"إغلاق المتطلبات اليوم","state":"pend"},{"name":"المشتريات","note":"لم يصل رد","state":"none"}]}]'::jsonb) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,priority,detail_text,requires_approval) VALUES ('corporate-ai',2,'strategic','approval','تحويل الخدمات المؤسسية إلى الذكاء الاصطناعي','مشاركة الخطة التنفيذية للموافقة، وإرسال ملف حالات الاستخدام للمورد لتدريب الذكاء الاصطناعي.','البدء في تدريب الذكاء الاصطناعي على سيناريوهات المستخدمين.','عرض النموذج 18 يونيو',TRUE,'تمت مشاركة الخطة التنفيذية مع الأخ علي عيسى للموافقة. أُعدّ وأُرسل ملف حالات الاستخدام للمورد، واكتمل جزء كبير من الخدمات الأولية، على أن يُعرض نموذج الذكاء الاصطناعي بتاريخ 18 يونيو.',TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,priority,detail_text) VALUES ('tms',3,'strategic','progress','تطوير نظام إدارة الأداء (TMS)','تمت مراجعة تعديلات المورد على الـ Wireframes تمهيداً للعرض على الأخ علي.','العرض على الأخ علي للانتقال إلى مرحلة التصميم.','الاستكمال المتوقع: نوفمبر 2026',TRUE,'راجع الفريق التعديلات التي أجراها المورد على الـ Wireframes، وسيُعرض على الأخ علي للمضي قدماً في مرحلة التصميم. الموعد المتوقع لاستكمال المشروع نوفمبر 2026.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('pm-support',4,'mocasmart','progress','خدمات دعم إدارة المشاريع','الخدمة قيد التصميم ضمن منصة MOCAsmart.','استكمال التصميم تمهيداً للعرض.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,priority,services) VALUES ('eight-services',5,'mocasmart','review','8 خدمات جاهزة لاعتماد رئيس القطاع','تصاميم جاهزة سيتم عرضها على رئيس القطاع للاعتماد خلال الأسبوع القادم.','العرض والاعتماد ثم الانتقال للتطوير.',TRUE,'[{"icon":"car","label":"طلب موقف سيارة"},{"icon":"identification-card","label":"بطاقة دخول (Access Card)"},{"icon":"camera","label":"طلب مصوّرين"},{"icon":"envelope-simple","label":"بريد إلكتروني جماعي"},{"icon":"medal","label":"مزايا الموظف والترقيات"},{"icon":"seal-check","label":"إقرار الموظفين"},{"icon":"airplane-tilt","label":"الإيفاد والمهام الرسمية"},{"icon":"house-line","label":"تحسين العمل عن بُعد"}]'::jsonb) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,detail_text,requires_approval) VALUES ('ifad',6,'ops','approval','نظام الإيفاد عبر MOCAsmart','التصميم معتمد من فريق المشتريات واكتملت النسخة العربية وشورِكت للمراجعة.','إعداد نطاق العمل ثم تحديد موعد الإطلاق.','الإطلاق: بعد إعداد نطاق العمل','تم التواصل مع الأخت موزة المرزوقي لتنسيق اجتماع عرض مع رئيس القطاع. اعتمد فريق المشتريات التصميم، وبانتظار مشاركة نطاق العمل. اكتمل تصميم النسخة العربية وشورِك للمراجعة من فريق المشتريات.',TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch) VALUES ('pm-tracking',7,'ops','progress','نظام إدارة ومتابعة المشاريع لرئيس القطاع','اعتُمدت المتطلبات وشورِك الـ SOW مع المورد بخصوص التكلفة.','البدء في مرحلة التصميم.','الإطلاق: بعد خطة عمل المورد') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('vendor-dashboard',8,'ops','done','لوحة تحكم إدارة الموردين','تم الانتهاء من المشروع بالكامل.','العرض على رئيس القطاع.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('ai-radar',9,'ops','progress','رادار الذكاء الاصطناعي','تصميم موقع إلكتروني باستخدام Claude AI لعرض أبرز مستجدات وأدوات الذكاء الاصطناعي.','تحديث المحتوى أسبوعياً ومشاركة الرابط مع رئيس القطاع.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('secondment',10,'ops','review','نظام الانتداب والتكليف','أُعدّ التصميم الأولي باستخدام Claude AI.','العرض على فريق الموارد البشرية لمراجعة المدخلات والملاحظات.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('contract-renewal',11,'ops','review','تجديد عقود الموظفين','النظام جاهز للإطلاق، وجارٍ تنسيق اجتماع عرض الدليل والنظام.','عرض النظام على رئيسة القطاع — بتنسيق موزة المرزوقي.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('events-now',12,'ops','progress','منصة الفعاليات (Events Now 2.0)','اكتمل التصميم وفق متطلبات فريق الفعاليات وعُرض عليهم.','إجراء بعض التعديلات المطلوبة.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('ems-photo',13,'ops','progress','منصة الفعاليات (EMS — التصوير الفوتوغرافي والفيديو)','العمل جارٍ على تصميم الواجهة الخلفية لخدمة طلب المصوّرين.','استكمال تصميم الواجهة الخلفية على Events Now.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,launch_soon,priority) VALUES ('attendance',14,'ops','done','نظام الحضور والانصراف (خدمات البانتري)','اكتمل المشروع ووافق متجر التطبيقات عليه، وهو قيد مراجعة فريق الشبكات.','الإطلاق ضمن نطاق شبكة الوزارة.','الإطلاق المتوقع: 8 يونيو',TRUE,TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('yahala',15,'culture','done','مبادرة «ياهلا الجديد»','اكتمل المشروع، والاستمرار مع شركة Entertainer مع استقبال عروض إضافية.','مراجعة عروض Entertainer وفيصل ورياض.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,launch_soon) VALUES ('khamis',16,'culture','progress','مبادرة «الخميس الونيس»','اعتُمد جدول شهر يونيو من رئيس القطاع.','تنفيذ فعالية «ميني ماتشا».','الخميس 8 يونيو',TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,priority,requires_approval) VALUES ('promotions',17,'culture','approval','مبادرة مكافأة الحاصلين على الترقيات','المبادرة جاهزة وبانتظار اعتماد رئيس القطاع للإعلان.','الاعتماد للمضي قدماً في التنفيذ.',TRUE,TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step) VALUES ('hajj',18,'culture','inputs','مبادرة الحج','بانتظار قائمة الموظفين من الأخ محمد جمعة.','طلب الأعلام والحلويات بعد استلام القائمة.') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,priority,requires_approval) VALUES ('bags',19,'culture','approval','الحقائب المخصصة للموظفات','تصميم مجموعة حقائب تحمل أسماء الموظفات، وجارٍ إعداد نموذج أولي.','الحصول على الموافقة النهائية من رئيس القطاع.',TRUE,TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,detail_text,document_name,document_url) VALUES ('supplier-survey',20,'crm','progress','استبيان رضا الموردين','أُعدّت التحليلات بناءً على النتائج وعُرضت على رئيس القطاع.','تنفيذ ملاحظات رئيس القطاع.','بتوجيه من رئيس القطاع وبالتنسيق مع الأخت مريم البلوشي والأخ خليفة الحبسي، أُعدّت التحليلات بناءً على النتائج وعُرضت، ويجري حالياً تنفيذ الملاحظات.','استبيان رضا الموردين 2025.pdf','/docs/supplier-satisfaction-survey-2025.pdf') ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,next_step,launch,launch_soon,progress) VALUES ('employee-survey',21,'crm','progress','استبيان رضا الموظفين','بلغت نسبة الاستجابة 46% بمشاركة 105 موظفين.','تمديد فترة الاستبيان حتى 13 يونيو لرفع نسبة المشاركة.','انتهاء الاستبيان: 13 يونيو',TRUE,46) ON CONFLICT (id) DO NOTHING;
INSERT INTO projects (id,position,section_id,status,title,update_text,stats) VALUES ('supplier-reg',22,'crm','review','تقرير تسجيل الموردين — يونيو','حالة طلبات تسجيل الموردين لشهر يونيو.','[{"n":"3","l":"إجمالي الطلبات"},{"n":"0","l":"مكتملة"},{"n":"8","l":"قيد التسجيل"},{"n":"4","l":"بانتظار المورد"},{"n":"1","l":"بانتظار الموارد البشرية"},{"n":"2","l":"اعتماد على النظام","amber":true},{"n":"1","l":"اعتماد على النموذج","amber":true}]'::jsonb) ON CONFLICT (id) DO NOTHING;
