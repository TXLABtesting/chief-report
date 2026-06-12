-- Chief Report — full schema + data for Neon / any PostgreSQL.
-- Re-runnable: drops and recreates the report tables, then loads all data.

DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS sections CASCADE;
DROP TABLE IF EXISTS statuses CASCADE;

-- Chief Report — database schema (PostgreSQL / Neon, portable to any Postgres)
-- Weekly executive report model. Run via `npm run db:migrate` or the server's
-- startup bootstrap. Safe to run repeatedly (CREATE IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS reports (
  id              TEXT PRIMARY KEY,          -- e.g. '2026-06-12'
  label           TEXT NOT NULL,             -- e.g. 'الجمعة 12 يونيو 2026'
  date_iso        TEXT NOT NULL,             -- 'YYYY-MM-DD' (ISO; sorts chronologically)
  position        INT  NOT NULL DEFAULT 0,
  top_priorities  JSONB NOT NULL DEFAULT '[]'::jsonb
);

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
  report_id          TEXT NOT NULL REFERENCES reports(id)  ON DELETE CASCADE,
  id                 TEXT NOT NULL,                       -- unique within a report
  position           INT  NOT NULL DEFAULT 0,
  section_id         TEXT NOT NULL REFERENCES sections(id),
  status             TEXT NOT NULL REFERENCES statuses(key),
  title              TEXT NOT NULL,
  update_text        TEXT NOT NULL,
  next_step          TEXT,
  challenges         TEXT,
  launch             TEXT,
  launch_soon        BOOLEAN NOT NULL DEFAULT FALSE,
  progress           INT,
  priority           BOOLEAN NOT NULL DEFAULT FALSE,
  needs_attention    BOOLEAN NOT NULL DEFAULT FALSE,
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
  PRIMARY KEY (report_id, id)
);

CREATE INDEX IF NOT EXISTS idx_projects_report  ON projects(report_id);
CREATE INDEX IF NOT EXISTS idx_projects_section ON projects(section_id);

INSERT INTO statuses (key,label,position) VALUES ('done','مكتمل',1);
INSERT INTO statuses (key,label,position) VALUES ('progress','قيد التنفيذ',2);
INSERT INTO statuses (key,label,position) VALUES ('ready','جاهز للعرض',3);
INSERT INTO statuses (key,label,position) VALUES ('approval','بانتظار اعتماد',4);
INSERT INTO statuses (key,label,position) VALUES ('inputs','بانتظار مدخلات',5);
INSERT INTO statuses (key,label,position) VALUES ('delayed','متأخر عن الجدول الزمني',6);

INSERT INTO sections (id,position,icon,title,sub) VALUES ('strategic',1,'target','المشاريع الاستراتيجية','التحوّل إلى الذكاء الاصطناعي ونُظُم الأداء');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('mocasmart',2,'squares-four','MOCA Smart','أتمتة الخدمات الذاتية للموظفين');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('ops',3,'gear-six','الأنظمة الداخلية','العمليات التشغيلية للخدمات المركزية');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('culture',4,'confetti','البيئة المؤسسية','مبادرات شهر يونيو 2026');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('crm',5,'chart-bar','علاقات المتعاملين','الاستبيانات وتسجيل الموردين');

INSERT INTO reports (id,label,date_iso,position,top_priorities) VALUES ('2026-06-12','الجمعة 12 يونيو 2026','2026-06-12',2,'["اعتماد حزمة خدمات MOCA Smart وتحديد أولوياتها وخارطة التنفيذ.","اعتماد توصية تبنّي Gemini Pro بدلاً من النموذج الحالي في مشاريع التحوّل الذكي.","اعتماد مبادرة مكافأة الحاصلين على الترقيات للإعلان والمضيّ في التنفيذ."]'::jsonb);
INSERT INTO reports (id,label,date_iso,position,top_priorities) VALUES ('2026-06-05','الجمعة 5 يونيو 2026','2026-06-05',1,'["اعتماد رئيس القطاع للخدمات الثماني الجاهزة في MOCA Smart.","إغلاق مدخلات مشروع التحوّل الذكي للعمليات الداخلية.","اعتماد مبادرة مكافأة الحاصلين على الترقيات."]'::jsonb);

INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,needs_attention,detail_text) VALUES ('2026-06-12','ai-transformation',0,'strategic','delayed','مشاريع التحوّل إلى الذكاء الاصطناعي','اكتملت جميع المتطلبات والاختبارات، وستُرفع توصية باعتماد Gemini Pro بدلاً من النموذج الحالي لعدم مواكبته للتطوّرات. الحالة الحالية: بانتظار ردّ مكتب الذكاء الاصطناعي على الملاحظات.','متابعة تنفيذ التحسينات ورفع توصية اعتماد Gemini Pro.','موعد الإطلاق المتوقّع: يونيو 2026 (متأخّر عن الجدول)',TRUE,'أُجريت الاختبارات من قِبل الأخ علي ورئيس القطاع، وشُورِكت الملاحظات مع الأخ صقر بن غالب وتُتابَع التحسينات المطلوبة.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,priority,team_groups) VALUES ('2026-06-12','agentic-ops',1,'strategic','progress','الذكاء الاصطناعي الوكيلي للعمليات (Agentic AI)','بتوجيه رئيس القطاع، يجري جمع بيانات كل عمليات قطاع الخدمات المركزية. عُقد اجتماع مع شركة Inception وشُورِكت معها ملفات عمليات الإدارات.','استكمال جمع البيانات من الوحدات المتبقّية، واجتماع مع Inception يوم الثلاثاء المقبل لاستلام خطة التنفيذ.','تأخّر استلام المتطلبات من بعض الإدارات.',TRUE,'[{"caption":"إدارات سلّمت / حدّثت بياناتها","rows":[{"name":"الموارد البشرية","note":"اكتملت — بانتظار مجلد النماذج","state":"pend"},{"name":"الشؤون المالية","note":"زوّدتنا بالمدخلات اليوم","state":"ok"},{"name":"الفعاليات والمحتوى والاتصال","note":"اكتملت — بانتظار قوالب آمنة","state":"pend"},{"name":"الشؤون القانونية","note":"لا قوالب لديها — أُضيفت الأرشفة","state":"ok"},{"name":"المراسم والعلاقات الحكومية","note":"سلّمت الملفّين والتفاصيل","state":"ok"},{"name":"المحتوى المعرفي","note":"مريم شاركت القائمة المحدّثة","state":"ok"},{"name":"الأمن السيبراني","note":"سلّم المطلوب — لا قوالب","state":"ok"},{"name":"الإعلام","note":"لا تحديثات إضافية","state":"ok"}]},{"caption":"إدارات متبقّية","rows":[{"name":"الخدمات الرقمية","note":"سلّمت — اجتماع مراجعة اليوم","state":"pend"},{"name":"العقود والمشتريات","note":"لم يصل الرد بعد","state":"none"},{"name":"الشؤون الإدارية","note":"لا تزال تعمل على الاستكمال","state":"pend"}]}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,launch,launch_soon) VALUES ('2026-06-12','agentic-services',2,'strategic','progress','الذكاء الاصطناعي الوكيلي للخدمات (Agentic AI)','أُعِدّ ملف حالات الاستخدام وأُرسل للمورد لتدريب الذكاء الاصطناعي على سيناريوهات المستخدمين، واكتمل جزء كبير من الخدمات الأوّلية.','البدء في تدريب الذكاء الاصطناعي.','بانتظار استلام ملفات الفعاليات والموارد البشرية باللغة الإنجليزية من الإدارات.','عرض النموذج المبدئي: 18 يونيو',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-12','tms',3,'strategic','progress','تطوير نظام إدارة الأداء (TMS)','عُقد اجتماع مع المورد لمناقشة توجيهات مدير الموارد البشرية بتعزيز تجربة المستخدم عبر AI Chat.','استلام الـ Wireframe المحدّث من المورد.','موعد الاستكمال المتوقّع: نوفمبر 2026');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention,services) VALUES ('2026-06-12','moca-services',4,'mocasmart','progress','حزمة خدمات قيد التصميم','مجموعة خدمات ذاتية قيد التصميم ضمن منصّة MOCA Smart.','عرض الخدمات على رئيس القطاع لتحديد الأولويات واعتماد خارطة التنفيذ.',TRUE,'[{"icon":"briefcase","label":"دعم إدارة المشاريع"},{"icon":"car","label":"طلب موقف سيارة"},{"icon":"identification-card","label":"بطاقة دخول (Access Card)"},{"icon":"camera","label":"طلب مصوّرين"},{"icon":"envelope-simple","label":"بريد إلكتروني جماعي"},{"icon":"medal","label":"مزايا الموظف والترقيات"},{"icon":"seal-check","label":"إقرار الموظفين"},{"icon":"airplane-tilt","label":"الإيفاد والمهام الرسمية"},{"icon":"house-line","label":"تحسين العمل عن بُعد"}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-12','ifad',5,'ops','progress','نظام الإيفاد عبر MOCA Smart','تم التواصل مع الأخت موزة المرزوقي لتنسيق اجتماع لعرض التصميم على رئيس القطاع، ويجري استكمال الـ SOW لبدء التنفيذ.','استكمال الـ SOW والبدء في التنفيذ.','موعد الإطلاق: ديسمبر 2026');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-12','pm-tracking',6,'ops','progress','نظام إدارة ومتابعة المشاريع لرئيس القطاع','اعتُمدت المتطلبات وشُورِك الـ SOW واستُلمت التكلفة.','البدء في مرحلة التصميم.','موعد الإطلاق النهائي: يُحدَّد بعد خطة عمل المورد');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention) VALUES ('2026-06-12','vendor-dashboard',7,'ops','ready','لوحة تحكّم إدارة الموردين','اكتمل المشروع بالكامل وأصبح جاهزاً للعرض.','العرض على رئيس القطاع.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','ai-radar',8,'ops','progress','رادار الذكاء الاصطناعي','موقع إلكتروني صُمِّم باستخدام Claude AI لعرض أبرز مستجدّات وأدوات الذكاء الاصطناعي، مع تحديث المحتوى أسبوعياً.','اجتماع الفريق التقني لمناقشة رفع الموقع على سيرفر الوزارة.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','tasks-delegation',9,'ops','progress','نظام المهام والتفويض','أُرسل التصميم لفريق الموارد البشرية واستُلمت ملاحظاتهم.','استكمال معالجة الملاحظات الواردة من فريق الموارد البشرية.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','contract-renewal',10,'ops','progress','تجديد عقود الموظفين','استُلمت متطلبات مدير الموارد البشرية بشأن تحويل الاعتمادات عبر البريد الإلكتروني لرؤساء القطاعات، وعُقد اجتماع مع فريق Oracle لمناقشة التنفيذ.','ينفّذ فريق Oracle نموذجاً أوّلياً ويعرضه على مدير الموارد البشرية قبل الانتقال للمرحلة التالية.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','events-now',11,'ops','inputs','منصّة الفعاليات (Events Now 2.0)','اكتمل تصميم المتطلبات.','استلام متطلبات جديدة من فريق الفعاليات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','ems-photo',12,'ops','progress','منصّة التصوير الفوتوغرافي والفيديو (EMS)','يجري العمل على تصميم الواجهة الخلفية لخدمة طلب المصوّرين.','استكمال تصميم الواجهة الخلفية ضمن Events Now.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,priority) VALUES ('2026-06-12','attendance',13,'ops','done','نظام الحضور والانصراف (خدمات الضيافة)','اكتمل المشروع واعتُمد في متجر التطبيقات، وراجعه فريق الشبكات تمهيداً للإطلاق ضمن شبكة الوزارة، ومُنِح المورد الصلاحيات اللازمة للنشر.','إطلاق التطبيق ضمن نطاق شبكة الوزارة.','موعد الإطلاق المتوقّع: 16 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon) VALUES ('2026-06-12','khamis',14,'culture','progress','مبادرة «الخميس الونيس»','نُفِّذت فعاليتا «ميني ماتشا» و«تحدّي جيوباردي» بنجاح.','تنفيذ فعالية «كوين ميني برجر» الخميس القادم.','الفعالية القادمة: الخميس المقبل',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention,requires_approval) VALUES ('2026-06-12','promotions',15,'culture','approval','مبادرة مكافأة الحاصلين على الترقيات الوظيفية','المبادرة جاهزة وبانتظار اعتماد رئيس القطاع للإعلان والمضيّ في التنفيذ.','الحصول على اعتماد رئيس القطاع.',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','hajj',16,'culture','inputs','مبادرة الحج','بانتظار قائمة الموظفين من الأخ محمد جمعة لطلب الأعلام والحلويات.','استلام القائمة ثم طلب الأعلام والحلويات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','bags',17,'culture','inputs','الحقائب المخصّصة للموظفات','بانتظار مشاركة المورد عيّنة الحقائب.','استلام العيّنة من المورد لاعتمادها.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,document_name,document_url) VALUES ('2026-06-12','supplier-survey',18,'crm','progress','استبيان رضا الموردين','بتوجيه رئيس القطاع وبالتنسيق مع مريم البلوشي وخليفة الحبسي، أُعِدّت نتائج الاستبيان وحُلِّلت وعُرِضت على رئيس القطاع.','تنفيذ الملاحظات والتوصيات الواردة.','استبيان رضا الموردين 2025.pdf','/docs/supplier-satisfaction-survey-2025.pdf');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,progress) VALUES ('2026-06-12','employee-survey',19,'crm','progress','استبيان رضا الموظفين','بلغت نسبة المشاركة 69% بمشاركة 105 موظفين.','تمديد فترة الاستبيان حتى 13 يونيو 2026 لرفع نسبة المشاركة.','انتهاء الاستبيان: 13 يونيو',TRUE,69);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention,stats) VALUES ('2026-06-12','supplier-reg',20,'crm','progress','تقرير تسجيل الموردين — يونيو (الأسبوع الثاني)','استُلمت 4 طلبات تسجيل جديدة خلال الأسبوع الثاني؛ إجمالي الطلبات قيد المعالجة: 10.','متابعة الطلبات العالقة، وأبرزها طلبان بانتظار توقيع رئيس القطاع.',TRUE,'[{"n":"4","l":"طلبات جديدة (الأسبوع الثاني)"},{"n":"10","l":"قيد المعالجة"},{"n":"4","l":"لدى الموردين لاستكمال المتطلبات"},{"n":"2","l":"بانتظار توقيع رئيس القطاع","amber":true},{"n":"2","l":"قيد مراجعة إدارة الموردين"},{"n":"1","l":"بانتظار تحقّق الموارد البشرية"},{"n":"1","l":"متوقّف بتوجيه رئيس القطاع","amber":true}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','gov-ai',0,'strategic','progress','توفير البيانات للقيادة عبر منصّة GOV AI','سُلِّمت كل المتطلبات وأُجريت الاختبارات، وشُورِكت الملاحظات مع الأخ صقر بن غالب.','معالجة الملاحظات الواردة من الاختبارات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,needs_attention) VALUES ('2026-06-05','internal-transform',1,'strategic','inputs','التحوّل الذكي للعمليات الداخلية','ذُكِّرت جميع الفرق باستكمال البيانات المتبقّية؛ 6 فرق أنجزت و4 لم ترسل بعد.','استلام مدخلات الفرق المتبقّية وإغلاق المتطلبات.','تأخّر بعض الفرق في إرسال البيانات.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,needs_attention,requires_approval) VALUES ('2026-06-05','corporate-ai',2,'strategic','approval','تحويل الخدمات المؤسسية إلى الذكاء الاصطناعي','شورِكت الخطة التنفيذية للموافقة، وأُرسل ملف حالات الاستخدام للمورد.','البدء في تدريب الذكاء الاصطناعي على سيناريوهات المستخدمين.','عرض النموذج: 18 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-05','tms',3,'strategic','progress','تطوير نظام إدارة الأداء (TMS)','روجِعت تعديلات المورد على الـ Wireframes تمهيداً للعرض على الأخ علي.','العرض على الأخ علي للانتقال إلى مرحلة التصميم.','موعد الاستكمال المتوقّع: نوفمبر 2026');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention) VALUES ('2026-06-05','eight-services',4,'mocasmart','ready','8 خدمات جاهزة لاعتماد رئيس القطاع','تصاميم جاهزة للعرض على رئيس القطاع للاعتماد خلال الأسبوع القادم.','العرض والاعتماد ثم الانتقال للتطوير.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','ifad',5,'ops','approval','نظام الإيفاد عبر MOCA Smart','اعتمد فريق المشتريات التصميم، واكتملت النسخة العربية وشورِكت للمراجعة.','إعداد نطاق العمل ثم تحديد موعد الإطلاق.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','vendor-dashboard',6,'ops','done','لوحة تحكّم إدارة الموردين','اكتمل المشروع بالكامل.','العرض على رئيس القطاع.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,priority) VALUES ('2026-06-05','attendance',7,'ops','done','نظام الحضور والانصراف (خدمات الضيافة)','اكتمل المشروع ووافق عليه متجر التطبيقات، وهو قيد مراجعة فريق الشبكات.','الإطلاق ضمن نطاق شبكة الوزارة.','الإطلاق المتوقّع: 8 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention,requires_approval) VALUES ('2026-06-05','promotions',8,'culture','approval','مبادرة مكافأة الحاصلين على الترقيات','المبادرة جاهزة وبانتظار اعتماد رئيس القطاع للإعلان.','الاعتماد للمضيّ قدماً في التنفيذ.',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,progress) VALUES ('2026-06-05','employee-survey',9,'crm','progress','استبيان رضا الموظفين','بلغت نسبة الاستجابة 46% بمشاركة 105 موظفين.','تمديد فترة الاستبيان حتى 13 يونيو لرفع نسبة المشاركة.','انتهاء الاستبيان: 13 يونيو',TRUE,46);
