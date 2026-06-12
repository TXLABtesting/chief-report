-- Chief Report — full schema + data for Neon / any PostgreSQL (re-runnable).

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
  target             INT,
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
INSERT INTO statuses (key,label,position) VALUES ('delayed','متأخّر عن الجدول الزمني',6);

INSERT INTO sections (id,position,icon,title,sub) VALUES ('strategic',1,'target','المشاريع الاستراتيجية','التحوّل إلى الذكاء الاصطناعي ونُظُم الأداء');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('mocasmart',2,'squares-four','خدمات MOCA Smart','أتمتة الخدمات الذاتية للموظفين');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('oracle',3,'database','مشاريع أوراكل','أنظمة Oracle التشغيلية');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('other',4,'stack','مشاريع أخرى','أنظمة ومنصّات الخدمات المركزية');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('culture',5,'confetti','فريق البيئة المؤسسية','مبادرات شهر يونيو 2026');
INSERT INTO sections (id,position,icon,title,sub) VALUES ('crm',6,'chart-bar','فريق علاقات المتعاملين','الاستبيانات وتسجيل الموردين');

INSERT INTO reports (id,label,date_iso,position,top_priorities) VALUES ('2026-06-12','الجمعة 12 يونيو 2026','2026-06-12',2,'["عرض حزمة خدمات MOCA Smart الجديدة على رئيس القطاع.","متابعة ردّ مكتب الذكاء الاصطناعي على ملاحظات GOV AI واختبار الخطة البديلة (16 يونيو).","اعتماد مبادرة مكافأة الحاصلين على الترقيات الوظيفية."]'::jsonb);
INSERT INTO reports (id,label,date_iso,position,top_priorities) VALUES ('2026-06-05','الجمعة 5 يونيو 2026','2026-06-05',1,'["اعتماد رئيس القطاع للخدمات الثماني الجاهزة في MOCA Smart.","إغلاق مدخلات مشروع التحوّل الذكي للعمليات الداخلية.","اعتماد مبادرة مكافأة الحاصلين على الترقيات."]'::jsonb);

INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,launch,needs_attention,detail_text) VALUES ('2026-06-12','gov-ai',0,'strategic','delayed','البيانات القيادية (GOV AI)','تم اختبار نظام GOV AI وتسليم كافة الملاحظات للأخ صقر بن غالب، حيث إن المخرجات لم تكن حسب المتوقع، وأفاد بأنه سيقوم بمراجعتها ومعالجتها والعودة إلينا. الوضع الحالي: بانتظار مكتب الذكاء الاصطناعي للرد على الملاحظات، وهناك تأخير حيث تم تسليم الملاحظات بتاريخ 22 مايو 2026.','موعد الإطلاق المتوقع: يونيو 2026 (مع وجود تأخير عن الجدول الزمني)',TRUE,'ملاحظة: هناك تجارب إضافية مع الأخ أحمد الحسين لتفعيل المشروع في حال فشل المشروع مع GOV AI، وستكون هناك اختبارات يوم الثلاثاء 16 يونيو 2026.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,priority,team_groups) VALUES ('2026-06-12','agentic-ops',1,'strategic','progress','الذكاء الاصطناعي المساعد (Agentic AI)','تم التوجيه من قبل رئيس القطاع لاستكمال جمع بيانات كافة عمليات قطاع الخدمات المركزية.','استكمال جمع البيانات المطلوبة من جميع الوحدات التنظيمية، وعقد اجتماعات مع الشركات المرشحة لتنفيذ المشروع ورفع التوصيات لرئيس القطاع. وقد تمت مشاركة الملفات مع شركة Inception للاطلاع عليها، وسيتم عقد اجتماع معهم الثلاثاء المقبل لمشاركتنا خطة التنفيذ.','تأخير استلام المتطلبات من الإدارات.',TRUE,'[{"caption":"الوضع الحالي","rows":[{"name":"إدارة الموارد البشرية","note":"تم استكمال التحديثات، وبانتظار مجلد النماذج والقوالب.","state":"pend"},{"name":"إدارة الشؤون المالية","note":"تم تزويدنا بالمدخلات اليوم.","state":"ok"},{"name":"إدارة الفعاليات والمحتوى الإبداعي والاتصال","note":"تم الانتهاء من العمل، وننتظر فقط بعض القوالب المتبقية من آمنة.","state":"pend"},{"name":"إدارة الشؤون القانونية","note":"أفادوا بأنه لا توجد لديهم قوالب (Templates)، وتمت إضافة نقطة الأرشفة فقط.","state":"ok"},{"name":"فريق المراسم والعلاقات الحكومية","note":"قام الفريق بتسليم الملفين بالإضافة إلى التفاصيل الإضافية المتعلقة بالعمليات.","state":"ok"},{"name":"فريق المحتوى المعرفي","note":"قامت مريم بمشاركة القائمة المحدّثة.","state":"ok"},{"name":"فريق الأمن السيبراني","note":"قاموا أيضاً بتسليم المطلوب، ولكن لا توجد لديهم قوالب.","state":"ok"},{"name":"فريق الإعلام","note":"أكد الفريق عدم وجود تحديثات إضافية.","state":"ok"}]},{"caption":"الفرق والإدارات المتبقية","rows":[{"name":"إدارة الخدمات الرقمية","note":"قاموا بتسليم المطلوب، ولدينا اجتماع معهم اليوم لمراجعة المحتوى.","state":"pend"},{"name":"إدارة العقود والمشتريات","note":"لم يتم استلام الرد بعد.","state":"none"},{"name":"إدارة الشؤون الإدارية","note":"لا يزالون يعملون على استكمال المطلوب.","state":"pend"}]}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,services) VALUES ('2026-06-12','agentic-services',2,'strategic','progress','الذكاء الاصطناعي المساعد للخدمات (MOCAsmart)','تم اختيار عدد 11 خدمة لتحويلها لخدمات ذكية.','العمل على تدريب الذكاء الاصطناعي.','انتظار إدارة خدمات الموارد البشرية لتسليم لائحة الموارد البشرية وسياسة السلوك المهني باللغة الإنجليزية، وأيضاً إدارة الفعاليات لتسليم سياسات الفعاليات.','[{"icon":"calendar-blank","label":"Leaves request"},{"icon":"receipt","label":"Payslip request"},{"icon":"user","label":"Personal information"},{"icon":"book-open","label":"Policies and guide"},{"icon":"coins","label":"Reimbursement"},{"icon":"clock","label":"Permission request"},{"icon":"graduation-cap","label":"Education claim"},{"icon":"books","label":"Vendor catalogue"},{"icon":"door-open","label":"Book a meeting room"}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-12','tms',3,'strategic','progress','مشروع تطوير نظام إدارة الأداء (TMS)','تم الاجتماع مع المورد لمناقشة التوجيهات الجديدة من مدير الموارد البشرية والمتعلقة بتعزيز تجربة المستخدم عبر استخدام AI Chat، وتم الاطلاع على التصور الجديد من قبلهم بعد تطوير المتطلبات لتصبح مواءمة مع الذكاء الاصطناعي المساعد وتوجهات حكومة الإمارات.','استلام الـ Wireframe المحدّث بعد التعديلات الجديدة.','موعد استكمال المشروع المتوقع: نوفمبر 2026');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,launch,needs_attention,services) VALUES ('2026-06-12','moca-services',4,'mocasmart','ready','الخدمات التي تم تصميمها','انتظار الأخت موزة المرزوقي لإعداد اجتماع مع سعادة رئيس القطاع لعرض الخدمات الجديدة.','موعد الإطلاق: ديسمبر 2026',TRUE,'[{"icon":"briefcase","label":"خدمات دعم إدارة المشاريع"},{"icon":"car","label":"طلب موقف سيارة"},{"icon":"identification-card","label":"طلب بطاقة (Access Card) جديدة"},{"icon":"camera","label":"طلب مصورين"},{"icon":"envelope-simple","label":"طلب بريد إلكتروني جماعي"},{"icon":"medal","label":"خدمة عرض مزايا الموظف والترقيات"},{"icon":"seal-check","label":"إقرار الموظفين"},{"icon":"airplane-tilt","label":"نظام الإيفاد والمهام الرسمية"},{"icon":"house-line","label":"تحسين خدمة طلب العمل عن بعد"}]'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,needs_attention) VALUES ('2026-06-12','vendor-dashboard',5,'oracle','ready','لوحة تحكم إدارة الموردين','تم الانتهاء من المشروع وسيتم عرضه على رئيس القطاع.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','tasks-delegation',6,'oracle','progress','نظام المهام والتفويض','تم إرسال التصميم لفريق الموارد البشرية واستلام بعض الملاحظات وجارٍ العمل عليها.','الاجتماع مع الفريق التقني لمناقشة رفع الموقع على السيرفر الخاص بالوزارة.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','contract-renewal',7,'oracle','progress','مشروع تجديد عقود الموظفين','تم استلام متطلبات من مدير الموارد البشرية بخصوص تحويل الاعتمادات عبر البريد الإلكتروني لرؤساء القطاعات، وتم الاجتماع مع فريق أوراكل لمناقشة تنفيذ المتطلبات.','سيقوم فريق أوراكل بتنفيذ نموذج أوّلي وعرضه على مدير الموارد البشرية قبل الانتقال إلى المرحلة التالية.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,detail_text) VALUES ('2026-06-12','service-evaluation',8,'other','progress','آلية تقييم الخدمات','سيتم إعداد عرض أفكار تحسينية لطريقة عرض الخدمات، وعقد اجتماع يوم الأربعاء مع الأخ علي عيسى للاعتماد.','يهدف المشروع إلى رفع نسب استجابة المتعاملين ومشاركتهم في تقييم الخدمات المقدّمة من خلال تطوير آليات مبتكرة ومحفّزة.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-12','pm-tracking',9,'other','progress','نظام إدارة ومتابعة المشاريع لرئيس قطاع الخدمات المركزية','تم اعتماد المتطلبات ومشاركة الـ SOW وتم استلام التكلفة.','البدء في التصميم.','موعد الإطلاق النهائي: يُحدد بعد مشاركة المورد خطة العمل');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','ai-radar',10,'other','progress','رادار الذكاء الاصطناعي','تم تصميم موقع إلكتروني باستخدام Claude AI لعرض أبرز مستجدات وأدوات الذكاء الاصطناعي، مع تحديث المحتوى بشكل أسبوعي.','الاجتماع مع الفريق التقني لمناقشة رفع الموقع على السيرفر الخاص بالوزارة.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text) VALUES ('2026-06-12','events-now',11,'other','inputs','منصة الفعاليات (Events Now 2.0)','تم الانتهاء من تصميم المتطلبات وبانتظار استلام متطلبات جديدة من فريق الفعاليات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','ems-photo',12,'other','progress','منصة التصوير الفوتوغرافي والفيديو (EMS)','جارٍ العمل على تصميم الواجهة الخلفية لخدمة طلب مصورين.','سيقوم فريق أوراكل بتنفيذ نموذج أوّلي وعرضه على مدير الموارد البشرية قبل الانتقال إلى المرحلة التالية.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,launch,launch_soon,priority) VALUES ('2026-06-12','attendance',13,'other','done','نظام الحضور والانصراف (خدمات الضيافة)','تم الانتهاء من المشروع واعتماده في متجر التطبيقات، وتمت مراجعة التطبيق من قبل فريق الشبكات تمهيداً لإطلاقه ضمن نطاق شبكة الوزارة، كما تم منح المورد الصلاحيات اللازمة لبدء إجراءات نشر التطبيق.','موعد الإطلاق المتوقع: 16 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-12','khamis',14,'culture','progress','مبادرة «الخميس الونيس»','تم تنفيذ فعالية «ميني ماتشا» وفعالية «تحدي جيوباردي» بنجاح.','العمل على تنفيذ فعالية «كوين ميني برجر» يوم الخميس القادم.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,needs_attention,requires_approval) VALUES ('2026-06-12','promotions',15,'culture','approval','مبادرة للموظفين الحاصلين على الترقيات الوظيفية','بانتظار اعتماد رئيس القطاع للإعلان والمضي قدماً في التنفيذ.',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text) VALUES ('2026-06-12','hajj',16,'culture','inputs','مبادرة الحج','لا نزال بانتظار قائمة الموظفين من محمد جمعة لطلب الأعلام والحلويات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text) VALUES ('2026-06-12','bags',17,'culture','inputs','الحقائب المخصصة','بانتظار المورد مشاركة العينة الخاصة بالحقائب.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,document_name,document_url) VALUES ('2026-06-12','supplier-survey',18,'crm','progress','استبيان رضا الموردين','بناءً على توجيهات رئيس القطاع وبالتنسيق مع مريم البلوشي وخليفة الحبسي، تم إعداد وتحليل نتائج الاستبيان وعرضها على رئيس القطاع.','يعمل الفريق حالياً على تنفيذ الملاحظات والتوصيات الواردة.','استبيان رضا الموردين 2025.pdf','/docs/supplier-satisfaction-survey-2025.pdf');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,progress,target) VALUES ('2026-06-12','employee-survey',19,'crm','progress','استبيان رضا الموظفين','نسبة المشاركة الحالية: 76%، وعدد المشاركين: 105.','تم تمديد فترة الاستبيان اليوم حتى 21 يونيو 2026.',76,80);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,needs_attention,stats) VALUES ('2026-06-12','supplier-reg',20,'crm','progress','تقرير تسجيل الموردين لشهر يونيو (الأسبوع الثاني)','تم استلام 4 طلبات تسجيل جديدة خلال الأسبوع الثاني من شهر يونيو. إجمالي الطلبات قيد المعالجة: 10 طلبات.',TRUE,'{"newRequests":{"n":"4","l":"طلبات تسجيل جديدة (الأسبوع الثاني)"},"inProcess":{"n":"10","l":"إجمالي الطلبات قيد المعالجة"},"breakdown":[{"n":"4","l":"قيد استكمال المتطلبات"},{"n":"2","l":"بانتظار اعتماد رئيس القطاع","amber":true},{"n":"2","l":"قيد المراجعة من قبل إدارة الموردين"},{"n":"1","l":"بانتظار التحقق من الموارد البشرية"},{"n":"1","l":"متوقف بناءً على توجيهات رئيس القطاع","amber":true}]}'::jsonb);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','gov-ai',0,'strategic','progress','توفير البيانات للقيادة عبر منصّة GOV AI','سُلِّمت كل المتطلبات وأُجريت الاختبارات، وشُورِكت الملاحظات مع الأخ صقر بن غالب.','معالجة الملاحظات الواردة من الاختبارات.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,challenges,needs_attention) VALUES ('2026-06-05','internal-transform',1,'strategic','inputs','التحوّل الذكي للعمليات الداخلية','ذُكِّرت جميع الفرق باستكمال البيانات المتبقّية؛ 6 فرق أنجزت و4 لم ترسل بعد.','استلام مدخلات الفرق المتبقّية وإغلاق المتطلبات.','تأخّر بعض الفرق في إرسال البيانات.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,needs_attention,requires_approval) VALUES ('2026-06-05','corporate-ai',2,'strategic','approval','تحويل الخدمات المؤسسية إلى الذكاء الاصطناعي','شورِكت الخطة التنفيذية للموافقة، وأُرسل ملف حالات الاستخدام للمورد.','البدء في تدريب الذكاء الاصطناعي على سيناريوهات المستخدمين.','عرض النموذج: 18 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch) VALUES ('2026-06-05','tms',3,'strategic','progress','تطوير نظام إدارة الأداء (TMS)','روجِعت تعديلات المورد على الـ Wireframes تمهيداً للعرض على الأخ علي.','العرض على الأخ علي للانتقال إلى مرحلة التصميم.','موعد الاستكمال المتوقّع: نوفمبر 2026');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention) VALUES ('2026-06-05','eight-services',4,'mocasmart','ready','8 خدمات جاهزة لاعتماد رئيس القطاع','تصاميم جاهزة للعرض على رئيس القطاع للاعتماد خلال الأسبوع القادم.','العرض والاعتماد ثم الانتقال للتطوير.',TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','ifad',5,'other','approval','نظام الإيفاد عبر MOCA Smart','اعتمد فريق المشتريات التصميم، واكتملت النسخة العربية وشورِكت للمراجعة.','إعداد نطاق العمل ثم تحديد موعد الإطلاق.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step) VALUES ('2026-06-05','vendor-dashboard',6,'oracle','done','لوحة تحكّم إدارة الموردين','اكتمل المشروع بالكامل.','العرض على رئيس القطاع.');
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,priority) VALUES ('2026-06-05','attendance',7,'other','done','نظام الحضور والانصراف (خدمات الضيافة)','اكتمل المشروع ووافق عليه متجر التطبيقات، وهو قيد مراجعة فريق الشبكات.','الإطلاق ضمن نطاق شبكة الوزارة.','الإطلاق المتوقّع: 8 يونيو',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,needs_attention,requires_approval) VALUES ('2026-06-05','promotions',8,'culture','approval','مبادرة مكافأة الحاصلين على الترقيات','المبادرة جاهزة وبانتظار اعتماد رئيس القطاع للإعلان.','الاعتماد للمضيّ قدماً في التنفيذ.',TRUE,TRUE);
INSERT INTO projects (report_id,id,position,section_id,status,title,update_text,next_step,launch,launch_soon,progress) VALUES ('2026-06-05','employee-survey',9,'crm','progress','استبيان رضا الموظفين','بلغت نسبة الاستجابة 46% بمشاركة 105 موظفين.','تمديد فترة الاستبيان حتى 13 يونيو لرفع نسبة المشاركة.','انتهاء الاستبيان: 13 يونيو',TRUE,46);
