-- устраеяем возможные проблемы с нулевым временем в датах --

SELECT @@GLOBAL.sql_mode global, @@SESSION.sql_mode session;
SET sql_mode = '';
SET GLOBAL sql_mode = '';

-- создаем бд --
DROP DATABASE mgerm;
CREATE DATABASE IF NOT EXISTS mgerm;
USE mgerm;

-- примечание - многие поля заданы default null потому что бд заполняется таким образом, что все, что нельзя заполнить автоматически, 
-- сгенерировать с помощью скриптов - заполнялось вручную и ненулевое. Затем, оставшиеся поля заполняются рандомно скриптами.

-- таблица с данными по врачам --
DROP TABLE IF EXISTS doctor;
CREATE TABLE doctor (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
middle_name VARCHAR(255) NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
department INT UNSIGNED DEFAULT NULL,
phone  VARCHAR(13) DEFAULT NULL,
spec VARCHAR(255) NOT NULL);

-- таблица с данными по пациентам 
DROP TABLE IF EXISTS patient;
CREATE TABLE patient (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
middle_name VARCHAR(255) NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
income_date DATETIME DEFAULT CURRENT_TIMESTAMP,
out_date DATETIME DEFAULT NULL,
first_hospitalisation BOOL DEFAULT NULL,
phone VARCHAR(13) DEFAULT NULL,
birth_date DATETIME DEFAULT CURRENT_TIMESTAMP,
disabled BOOL DEFAULT NULL,
married BOOL DEFAULT NULL,
doctor INT UNSIGNED DEFAULT NULL,
insurance_number VARCHAR(13) DEFAULT NULL,
diagnosis INT UNSIGNED DEFAULT NULL,
treatment INT UNSIGNED DEFAULT NULL,
sex  VARCHAR(1) DEFAULT NULL);

-- таблица с данными по медикаментозному лечению
DROP TABLE IF EXISTS medication;
CREATE TABLE medication (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
patient_id INT UNSIGNED NOT NULL,
drug_id INT UNSIGNED DEFAULT NULL,
morning_dosage VARCHAR(255) DEFAULT NULL,
day_dosage VARCHAR(255) DEFAULT NULL,
evening_dosage VARCHAR(255) DEFAULT NULL,
stat_date DATETIME DEFAULT CURRENT_TIMESTAMP,
finish_date DATETIME DEFAULT NULL,
change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
doctor_id INT UNSIGNED DEFAULT NULL,
regularity VARCHAR(255) DEFAULT NULL);

-- таблица с данными по лекарствам
DROP TABLE IF EXISTS drugs;
CREATE TABLE drugs (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255) NOT NULL,
units_in_box INT UNSIGNED NOT NULL,
dosage  VARCHAR(255) DEFAULT NULL,
drug_form  VARCHAR(255) NOT NULL,
description TEXT DEFAULT NULL,
prohibited BOOL DEFAULT NULL);

-- таблица с данными по диагнозам
DROP TABLE IF EXISTS diagnoses;
CREATE TABLE diagnoses (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
MKB_10 VARCHAR(255) NOT NULL,
description TEXT DEFAULT NULL);

-- таблица с данными по осмотрам
DROP TABLE IF EXISTS inspection;
CREATE TABLE inspection (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
patient_id INT UNSIGNED NOT NULL,
doctor_id INT UNSIGNED DEFAULT NULL,
inspection_date DATETIME DEFAULT CURRENT_TIMESTAMP,
medication_id INT UNSIGNED DEFAULT NULL,
primary_inspection BOOL DEFAULT NULL);

-- таблица с данными по анамнезу
DROP TABLE IF EXISTS anamnesis;
CREATE TABLE anamnesis (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
patient_id INT UNSIGNED NOT NULL,
doctor_id INT UNSIGNED DEFAULT NULL,
disease VARCHAR(255) DEFAULT NULL,
reason VARCHAR(255) DEFAULT NULL,
chronical_diseases TEXT DEFAULT NULL,
allergy TEXT DEFAULT NULL);

-- таблица с данными по расписанию врачей
DROP TABLE IF EXISTS schedule;
CREATE TABLE schedule (
sch_date DATETIME DEFAULT CURRENT_TIMESTAMP,
doctor INT UNSIGNED DEFAULT NULL,
time_intervals TEXT NOT NULL,
cabinet INT UNSIGNED DEFAULT NULL,
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
closed BOOL DEFAULT NULL);

-- таблица с данными по отделениям
DROP TABLE IF EXISTS department;
CREATE TABLE department (
name VARCHAR(255) NOT NULL,
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);

-- таблица с данными по анализам
DROP TABLE IF EXISTS analyses;
CREATE TABLE analyses (
name VARCHAR(255) DEFAULT NULL,
patient_id INT UNSIGNED DEFAULT NULL,
cabinet INT UNSIGNED DEFAULT NULL,
results TEXT DEFAULT NULL,
date_made DATETIME DEFAULT CURRENT_TIMESTAMP,
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);

DROP TABLE IF EXISTS treatment;
CREATE TABLE treatment (
name VARCHAR(255) NOT NULL,
procedures TEXT DEFAULT NULL,
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);

ALTER TABLE patient
ADD CONSTRAINT patient_medication_id_fk
	FOREIGN KEY (id) REFERENCES medication (id) ON DELETE CASCADE,
ADD CONSTRAINT patient_doctor_id_fk
	FOREIGN KEY (doctor) REFERENCES doctor (id) ON DELETE CASCADE,
ADD CONSTRAINT patient_diagnosis_id_fk
	FOREIGN KEY (diagnosis) REFERENCES diagnoses (id) ON DELETE CASCADE,
ADD CONSTRAINT patient_treatment_id_fk
	FOREIGN KEY (treatment) REFERENCES treatment (id) ON DELETE CASCADE;

-- связь врачей с отделениями
ALTER TABLE doctor
ADD CONSTRAINT doctor_department_id_fk
	FOREIGN KEY (department) REFERENCES department (id);	

-- связь нализов с пациентами
ALTER TABLE analyses
ADD CONSTRAINT analyses_patient_id_fk
	FOREIGN KEY (patient_id) REFERENCES patient (id);	

-- связь расписания с врачом
ALTER TABLE schedule
ADD CONSTRAINT schedule_doctor_id_fk
	FOREIGN KEY (doctor) REFERENCES doctor (id);

-- связь осмотра с врачом/пациентом/медикаментозным лечением
ALTER TABLE inspection
ADD CONSTRAINT inspection_doctor_id_fk
	FOREIGN KEY (doctor_id) REFERENCES doctor (id),
ADD CONSTRAINT inspection_patient_id_fk
	FOREIGN KEY (patient_id) REFERENCES patient (id),
ADD CONSTRAINT inspection_medication_id_fk
	FOREIGN KEY (medication_id) REFERENCES medication (id);	
     
-- связь анамнеза с доктором, его написавшим/пациентом
ALTER TABLE anamnesis
ADD CONSTRAINT anamnesis_doctor_id_fk
	FOREIGN KEY (doctor_id) REFERENCES doctor (id),
ADD CONSTRAINT anamnesis_patient_id_fk
	FOREIGN KEY (patient_id) REFERENCES patient (id);	
    
-- связь медикаментозного лечения с пациентом/назначившим его врачом/лекарством
ALTER TABLE medication
ADD CONSTRAINT medication_doctor_id_fk
	FOREIGN KEY (doctor_id) REFERENCES doctor (id),
ADD CONSTRAINT medication_patient_id_fk
	FOREIGN KEY (patient_id) REFERENCES patient (id),
ADD CONSTRAINT medication_drug_id_fk
	FOREIGN KEY (drug_id) REFERENCES drugs (id);	

-- ALTER TABLE t
-- DROP FOREIGN KEY patient_doctor_id_fk

-- заполняем информацию по отделениям
INSERT INTO department (name) VALUES ('Дневной стационар'), ('Консультативно-лечебное отделение'), 
('Консультативное отделение'), ('Лаборатория'), ('Междисциплинарный центр медицины сна'), 
('Отделение лучевой диагностики'),('Приемное отделение'), ('Психоневрологическое отделение'), 
('Физиотерапия и восстановительное лечение');

-- заполняем диагнозы (взяла очень приближенную небольшую выборку)
INSERT INTO diagnoses (description, MKB_10) VALUES ('Деменция при болезни Альцгеймера','F00*G30.-+'), ('Мультиинфарктная деменция','F01.1х'), 
('Шизофрения','F20'), ('Приступообразная шизофрения, шизоаффективный вариант, депрессивный тип','F25.11'), ('Острая интоксикация с делирием','F1х.03х'), 
('Синдром зависимости','F1х.2'),('Синдром отмены кокаина','F14.3х'), ('Неуточненные психические расстройства','F1х.99х'), 
('Мания с психотическими симптомами','F30.2'), ('Маниакально-бредовое состояние с конгруентным аффекту бредом','F30.23'), 
('Биполярное аффективное расстройство','F31'), ('Депрессивный эпизод','F32'), ('Рекуррентное депрессивное расстройство','F33'), 
('Дистимия','F34.1'),('Специфические (изолированные) фобии','F40.2'), ('Смешанное тревожное и депрессивное расстройство','F41.2'), 
('Обсессивно-компульсивное расстройство','F42');

-- заполняем лекарства - тоже взяла небольшую выборку основных используемых для лечения указанных выше болезней
INSERT INTO drugs (name, units_in_box, dosage, drug_form, description , prohibited ) VALUES 
('Галоперидол','20','1 мл','Раствор для в/в и в/м введения','Нейролептик, производное бутирофенона',true), 
('Прозак','14','20 мг','Капсулы','Антидепрессант, производное пропиламина', false), 
('Триседил','50','0,5 мг','Таблетки','Активный нейролептик', true), 
('Стелазин','50','5 мг','Таблетки','Транквилизатор, обладает противотревожным и успокаивающим действием.',false), 
('Пипортил','10','10 мг','Таблетки','антипсихотическое, нейролептическое', false), 
('Клозапин','50','25 мг','Таблетки',' Антипсихотический препарат (нейролептик)', true),
('Герфонал','20','400 мг','Таблетки','Антипсихотический препарат (нейролептик)', true), 
('Оланзапин','50','10 мг','Таблетки','Антипсихотический препарат (нейролептик)', true);

-- заполняем информацию по докторам
INSERT INTO doctor (last_name, first_name,middle_name, spec) VALUES
('Авдеева','Мария','Александровна','Врач-невролог'), 
('Акиньшина','Ольга','Сергеевна','Врач-психиатр'), 
('Александрович','Алла','Владимировна','Врач-психотерапевт'), 
('Аксенова','Наталья','Александровна','Медицинская сестра'), 
('Абдулхакова','Алсу','Ярулловна','Медицинская сестра'), 
('Аркуша','Инна','Анатольевна','Врач-психиатр'), 
('Богин','Юрий','Борисович','Врач-уролог'), 
('Гасташева','Марина','Ануаровна','Врач-кардиолог'), 
('Голубева',' Елена','Кирилловна','Врач-гастроэнтеролог'), 
('Гурова','Татьяна','Васильевна','Старшая медицинская сестра'), 
('Долгов','Сергей','Алексеевич','Врач-психотерапевт'), 
('Денисова','Галина','Викторовна','Медицинский психолог'), 
('Ершов','Александр','Алексеевич','Врач-терапевт'), 
('Журавлёв','Дмитрий','Викторович','Врач-невролог'), 
('Козырев','Кирилл','Сергеевич','Врач - психиатр'), 
('Лобачева','Людмила','Станиславовна','Врач-психотерапевт');

-- генерируем номер телефона (по одной цифре - иначе выходило, что может быть короче желаемого)
UPDATE doctor SET phone = CONCAT(
'89',
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0));

-- генерируем рандомно отделение для докторов
UPDATE doctor SET department = (
SELECT id FROM department ORDER BY RAND () LIMIT 1);


-- примечание: так как подсчет расписания приемов врача и распределение пациентов - достаточно трудоемкая задача, 
-- в данном случае я ей пренебрегу из-за ограничений во времени. Потенциально можно дописать и его

-- заполняем расписание 
INSERT INTO schedule (time_intervals) VALUES 
('9:00-14:00,15:00-18:00'), ('10:00-15:00,15:00-19:00'), 
('9:00-14:00,15:00-18:00'), ('11:00-14:00,15:00-18:00'), 
('12:00-15:00,15:30-20:00'), ('10:00-15:00,15:00-19:00'),
('9:00-14:00,15:00-18:00'), ('11:00-14:00,15:00-18:00'),
('11:00-14:00,15:00-18:00'), ('12:00-15:00,15:30-20:00'), 
('10:00-15:00,15:00-19:00'), ('9:00-14:00,15:00-18:00'), 
('11:00-14:00,15:00-18:00'), ('12:00-15:00,15:30-20:00'),
('9:00-14:00,15:00-18:00'), ('10:00-15:00,15:00-19:00');

-- заполняем рандомной айдишники докторов для каждой строки в расписании
UPDATE schedule SET doctor = (
SELECT id FROM doctor ORDER BY RAND () LIMIT 1);

-- временная таблица для рандомного заполнения логических значений
CREATE TEMPORARY TABLE logical (value BOOL);
INSERT INTO logical VALUES (true),(false);

-- рандомно заполняем поле открыто/закрыто
UPDATE schedule SET closed = (
SELECT value FROM logical ORDER BY RAND () LIMIT 1);

-- заполняем информацию по пациентам
INSERT INTO patient (last_name, first_name, middle_name, sex, birth_date) VALUES 
('Ярославская','София','Михайловна','f','1998-01-18 00:00:00'),
('Эксюзян','Наринэ','Энриковна','f','1983-10-02 00:00:00'),
('Шорухова','Татьяна','Ивановна','f','1971-05-24 00:00:00'), 
('Царева','Ирина','Анатольевна','f','2011-04-25 00:00:00'),
('Титкова','Ольга','Васильевна','f','1993-12-07 00:00:00'), 
('Фалинская','Ольга','Геннадьевна','f','1981-12-18 00:00:00'),
('Гапоненков','Сергей','Викторович','m','1994-06-11 00:00:00'), 
('Гоголева','Людмила','Николаевна','f','1985-12-19 00:00:00'),
('Долгов','Сергей','Алексеевич','m','1992-08-21 00:00:00'), 
('Сошникова','Людмила','Георгиевна','f','1974-07-04 00:00:00'),
('Гарнова','Марина','Ивановна','f','1972-12-05 00:00:00'), 
('Гайда','Оксана','Ивановна','f','1999-06-17 00:00:00'),
('Лесс','Юлиана','Эдуардовна','f','2000-01-02 00:00:00'), 
('Аносов',' Александр','Юрьевич','m','1990-10-10 00:00:00'),
('Сохакян','Кристина','Александровна','f','1997-04-04 00:00:00'), 
('Акжигитов','Ренат','Гайясович','m','1998-04-08 00:00:00'),
('Королёв','Александр','Львович','m','1976-08-25 00:00:00'), 
('Блохина','Валентина','Владимировна','f','1975-12-10 00:00:00'),
('Варейчук','Наталья','Васильевна','f','2000-01-20 00:00:00'), 
('Шумова','Галина','Ивановна','f','1985-11-20 00:00:00'),
('Рассоха','Ольга','Евгеньевна','f','1992-01-11 00:00:00'), 
('Орлова','Елизавета','Рафаиловна','f','1992-11-18 00:00:00'),
('Бобылева','Олеся','Николаевна','f','1976-07-16 00:00:00'), 
('Козлов','Александр','Васильевич','f','1984-08-20 00:00:00'),
('Лузин','Роман','Владимирович','m','1971-08-11 00:00:00'), 
('Самылина','Татьяна','Михайловна','f','1998-04-08 00:00:00'),
('Волкова','Ольга','Ивановна','f','1992-03-02 00:00:00'), 
('Комиссаренко','Нинель','Николаевна','f','1974-06-27 00:00:00'),
('Борисов','Валентин','Александрович','m','1990-08-30 00:00:00'), 
('Винецкий','Ян','Янович','m','1980-09-05 00:00:00'),
('Боженова','Ольга','Николаевна','f','1997-04-04 00:00:00'), 
('Войнова','Надежда','Васильевна','f','1987-12-23 00:00:00'),
('Лощинина','Людмила','Анатольевна','f','1972-10-28 00:00:00'), 
('Воропаева','Наталья','Ивановна','f','1977-04-09 00:00:00'),
('Юркова','Олеся','Алексеевна','f','1996-05-26 00:00:00'), 
('Вязовецков','Александр','Васильевич','m','1975-06-04 00:00:00');

-- рандомно заполняем первая ли это госпитализация у пациента 
UPDATE patient SET first_hospitalisation = (
SELECT value FROM logical ORDER BY RAND () LIMIT 1);

-- рандомно заполняем поле, есть ли у пациента инвалидность
UPDATE patient SET disabled = (
SELECT value FROM logical ORDER BY RAND () LIMIT 1);

-- рандомно назначаем врача
UPDATE patient SET doctor = (
SELECT id FROM doctor ORDER BY RAND () LIMIT 1);

-- рандомно даем пациентам диагноз 
UPDATE patient SET diagnosis = (
SELECT id FROM diagnoses ORDER BY RAND () LIMIT 1);

-- по такому же как и раньше принципу, генерируем телефон 
UPDATE patient SET phone = CONCAT(
'89', 
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0));

-- генерируем номер страховки
UPDATE patient SET insurance_number = CONCAT( 
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0),
ROUND((RAND()* 9),0));

-- дату поступления генерируем из расчета что это происходит с декабря по май
UPDATE patient SET income_date = CONCAT(
'2020-',
FLOOR(RAND()*(5-1)+1),'-',
FLOOR(RAND()*(30-1)+1), ' 13:35:08');

-- дату выписки генерируем тоже из расчета что это будет в мае (чтобы была хорошая выборка по выписанным)
UPDATE patient SET out_date = CONCAT(
'2020-05-',
FLOOR(RAND()*(30-10)+10), ' 13:35:08');

-- типы лечений 
CREATE TEMPORARY TABLE treatment_types (name CHAR(255));
INSERT INTO treatment_types VALUES ('Медикаментозное'), ('Комбинированное'), ('Процедуры');

-- процедуры
CREATE TEMPORARY TABLE procedures (name CHAR(255));
INSERT INTO procedures VALUES 
('Гимнастика'), ('Массаж'),('Психолог'),('ЛФК') ,
('Диета'),('ДЛГ'),('Трудотерапия'), ('Трудотерапия'), ('Арт терапия');

-- заполняем лечение (по количеству пациентов, но не обязательно - просто накидываем строки в таблицу)
INSERT INTO treatment (id) SELECT id FROM patient;

-- рандомно назначаем лечение пациенту 
UPDATE patient SET treatment = (
SELECT id FROM treatment ORDER BY RAND () LIMIT 1);

 -- заполняем информацию по лечению
UPDATE treatment SET procedures = (SELECT name FROM procedures ORDER BY RAND () LIMIT 1);
UPDATE treatment SET name = (SELECT name FROM treatment_types ORDER BY RAND () LIMIT 1);

-- накидываем в таблицу медикаментозного лечения дважды количество строк, равное количеству пациентов - у каждого пациента условно по два препарата
INSERT INTO medication (patient_id) SELECT id FROM patient;
INSERT INTO medication (patient_id) SELECT id FROM patient;

-- заполняем в таблице лечения лекарство
UPDATE medication SET drug_id = (SELECT id FROM drugs ORDER BY RAND () LIMIT 1);

-- рандомно заполняем дозировку - это доза одной упаковки или таблетки, умноженная на число от 1 до 5  - не придумала ничего интереснее
UPDATE medication SET morning_dosage = 
CONCAT(
(SELECT dosage FROM drugs 
WHERE drugs.id = medication.drug_id ), 
' x',
(FLOOR(RAND()*(5-1)+1))
);

-- дневную дозировку заполняем так же
UPDATE medication SET day_dosage = 
CONCAT(
(SELECT dosage FROM drugs 
WHERE drugs.id = medication.drug_id ), 
' x',
(FLOOR(RAND()*(5-2)+2))
);

-- вечернюю дозировку тоже заполняем
UPDATE medication SET evening_dosage = 
CONCAT(
(SELECT dosage FROM drugs 
WHERE drugs.id = medication.drug_id ), 
' x',
(FLOOR(RAND()*(5-2)+2))
);

-- заполняем врача, который назначил лекарство - выбираем по пациенту лечащего врача и ставим его.
UPDATE medication SET doctor_id = 
(SELECT doctor FROM patient 
WHERE patient.id = medication.patient_id);

-- регулярность приема - временная таблица
CREATE TEMPORARY TABLE regularity_types (name CHAR(255));
INSERT INTO regularity_types VALUES 
('ежедневно'), ('через день'),('раз в неделю'),('раз в два дня') ,
('раз в три дня');

-- расставляем регулярность применения лекарств
UPDATE medication SET regularity = ( 
SELECT name FROM regularity_types ORDER BY RAND () LIMIT 1);

-- добавляем в анализы айдишники пациентов. трижды - потому что ДОПУСТИМ у каждого пациента по три анализа.
INSERT INTO analyses (patient_id) SELECT id FROM patient;
INSERT INTO analyses (patient_id) SELECT id FROM patient;
INSERT INTO analyses (patient_id) SELECT id FROM patient;

-- типы анализов - временная таблица
CREATE TEMPORARY TABLE analyses_types (name CHAR(255));
INSERT INTO analyses_types VALUES 
('ЭКГ'), ('Биохимия крови'),('Флюорография'),('Общий анализ крови') ,
('ЭЭГ'), ('Гормоны'),('Моча'),('Артериальное давление'),
('Иммунология'),('УЗИ');

-- распределяем названия анализов
UPDATE analyses SET name = ( 
SELECT name FROM analyses_types ORDER BY RAND () LIMIT 1);


-- примечание: тут тоже пришлось применять упрощение, потому что на деле можно очень много писать про анализы, для каждого вида - много уникальных полей, но это не целесообразно сейчас
-- потому я условно поделила результаты на два типа - нормальные и с отклонениями от нормы.

-- типы результатов - временная таблица
CREATE TEMPORARY TABLE result_types (name CHAR(255));
INSERT INTO result_types VALUES 
('В норме'), ('Отклонения');

-- распределяем результаты анализов
UPDATE analyses SET results = ( 
SELECT name FROM result_types ORDER BY RAND () LIMIT 1);

-- добавляем таблицу с анамнезом столбцов по количеству пациентов
INSERT INTO anamnesis (patient_id) SELECT id FROM patient;

-- доктора, составлявшего анамнез так же заполним исходя из лечащего врача пациента
UPDATE anamnesis SET doctor_id = 
(SELECT doctor FROM patient 
WHERE patient.id = anamnesis.patient_id);

-- болезни в анамнезе возьмем рандомно из таблицы с заболеваниями
UPDATE anamnesis SET disease = 
(SELECT description FROM diagnoses ORDER BY RAND () LIMIT 1);

-- причины заболеваний - временная таблица - были выбраны из справочника
CREATE TEMPORARY TABLE disease_reason_types (name CHAR(255));
INSERT INTO disease_reason_types VALUES 
('наследственность'), ('ошибки схемы лечения'),('злоупотребление психоактивными веществами'),('социальные факторы') ,
('патологии мозга'), ('Другое');

-- заполняем происхождение заболевания
UPDATE anamnesis SET reason = 
(SELECT name FROM disease_reason_types ORDER BY RAND () LIMIT 1);

-- создаем временную таблицу по аллергиям
CREATE TEMPORARY TABLE allergy_types (name CHAR(255));
INSERT INTO allergy_types VALUES 
('Нет'), ('Пенициллины'),('Пчелиный яд'),('Морепродукты') ,
('Цитрусовые'), ('Другое');

-- распределяем пациентам рандомные виды аллергии
UPDATE anamnesis SET allergy = 
(SELECT name FROM allergy_types ORDER BY RAND () LIMIT 1);

-- хронические болезни - временная таблица
CREATE TEMPORARY TABLE chronical_diseases (name CHAR(255));
INSERT INTO chronical_diseases VALUES 
('Нет'), ('Диабет'),('Рассеянный склероз'),('Хронических психоз') ,
('Гастрит'), ('Другое');

-- распределяем хронические болезни по анамнезам пациентов
UPDATE anamnesis SET chronical_diseases = 
(SELECT name FROM chronical_diseases ORDER BY RAND () LIMIT 1);

-- добавляем в осмотры айди пациентов (пусть будет по одному осмотру)
INSERT INTO inspection (patient_id) SELECT id FROM patient;

-- доктор = лечащий врач пациента, у которого проводится осмотр
UPDATE inspection SET doctor_id = 
(SELECT doctor FROM patient 
WHERE patient.id = inspection.patient_id);

-- лечение медикаментозное - лечение, назначенное пациенту
UPDATE inspection SET medication_id = 
(SELECT id FROM medication 
WHERE inspection.patient_id = medication.patient_id LIMIT 1);

-- рандомно даем булево значение - первичный осмотр или нет
UPDATE inspection SET primary_inspection = 
(SELECT value FROM logical ORDER BY RAND () LIMIT 1);

-- процедура - выбор общей информации по пациенту
DROP PROCEDURE IF EXISTS patient_info;
DELIMITER -
CREATE PROCEDURE patient_info (IN patient_id_patameter INT)
  BEGIN 
    (
      SELECT last_name, first_name, middle_name, diagnosis, chronical_diseases, allergy
        FROM patient 
          JOIN anamnesis
            ON patient.id = anamnesis.patient_id
        WHERE patient.id = patient_id_patameter
    )
ORDER BY income_date ASC
LIMIT 100;
END; -
DELIMITER ;

-- вызов процедуры для выбранного id пациента
CALL patient_info(3);

 -- триггер - не обслуживаем пациентов младше 18
DELIMITER //
CREATE TRIGGER validate_patient_age BEFORE INSERT ON patient
FOR EACH ROW BEGIN
  IF year(NEW.birth_date) - YEAR(current_timestamp()) < 18  THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'patient is underage! we cant proceed him';
  END IF;
END//

-- представление - лечение пациента - фио пациента и его назначения
CREATE OR REPLACE VIEW patients_medication AS
SELECT
  p.last_name AS last_name,
  p.first_name AS first_name,
  m.stat_date AS start_date,
  d.name AS drug
FROM
  patient AS p
JOIN
  medication AS m
ON
  p.id = m.patient_id
JOIN
  drugs AS d
ON
  m.drug_id = d.id;
  
-- представление - количество пациентов по врачам
CREATE OR REPLACE VIEW patients_count_by_doctor AS
SELECT
  d.last_name AS last_name,
  d.first_name AS first_name,
  COUNT(p.id) AS patients
FROM
  patient AS p
JOIN
  doctor AS d
ON p.doctor = d.id
GROUP BY d.id;

-- представление - количество пациентов по отделениям
CREATE OR REPLACE VIEW patients_count_by_department AS
SELECT
  dep.name AS department,
  COUNT(p.id) AS patients
FROM
  patient AS p
JOIN
  doctor AS d
ON p.doctor = d.id
JOIN 
	department AS dep
ON d.department = dep.id
GROUP BY dep.id;

-- выборка - количество пациентов, которые выпишутся в определенную дату   (ниже доьавила комментарий для подставления текущей даты - так тоже может бть удобно)
SELECT 
	CONCAT(p.last_name,' ', p.first_name, ' ',p.middle_name) 
    AS patient_FIO, 
	p.income_date, p.insurance_number, di.description, 
	CONCAT(d.last_name,' ', d.first_name, ' ',d.middle_name)  
    AS doctor_FIO
FROM
  patient AS p
JOIN
  doctor AS d
ON d.id = p.doctor
JOIN diagnoses as di
ON  di.id = p.diagnosis
WHERE DATE(out_date) = '2020-05-10';
-- DATE(current_timestamp()); 

-- пациенты по болезням
SELECT diagnoses.description, 
(SELECT COUNT(*) 
FROM patient 
WHERE patient.diagnosis = diagnoses.id 
GROUP BY patient.diagnosis) 
as patients_num 
FROM diagnoses

