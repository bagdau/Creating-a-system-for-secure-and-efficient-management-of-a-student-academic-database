USE hospital_db;

DROP VIEW IF EXISTS public_student_grades;
DROP VIEW IF EXISTS teacher_average_grades;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    age TINYINT NULL,
    group_name VARCHAR(20) NULL,
    course TINYINT NULL,
    email VARCHAR(100) NULL
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    credits TINYINT NOT NULL,
    semester TINYINT NOT NULL,
    teacher_name VARCHAR(100) NOT NULL
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    grade_value INT NOT NULL,
    graded_at DATE NOT NULL,
    CONSTRAINT fk_grades_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_grades_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

INSERT INTO students(student_id, last_name, first_name, age, group_name, course, email)
VALUES
(1, 'Akhmetov', 'Dias', 19, 'IP-26-1', 2, 'dias.akhmetov@mail.com'),
(2, 'Sarsenova', 'Aigerim', 20, 'IP-26-1', 2, 'aigerim.sarsenova@mail.com'),
(3, 'Bekova', 'Aruzhan', 20, 'IP-26-2', 2, 'aruzhan.bekova@mail.com');

INSERT INTO subjects(subject_id, subject_name, credits, semester, teacher_name)
VALUES
(1, 'Databases', 5, 3, 'A. Saparov'),
(2, 'Programming', 5, 3, 'B. Nurgaliyev'),
(3, 'Networks', 4, 3, 'C. Orazova');

INSERT INTO grades(grade_id, student_id, subject_id, grade_value, graded_at)
VALUES
(1, 1, 1, 90, '2026-10-01'),
(2, 1, 2, 85, '2026-10-01'),
(3, 2, 1, 90, '2026-10-02'),
(4, 2, 2, 78, '2026-10-02'),
(5, 3, 3, 95, '2026-10-03');

SHOW TABLES;
SELECT COUNT(*) AS total_rows FROM grades;
SELECT * FROM grades WHERE grade_value = 90;
EXPLAIN SELECT * FROM grades WHERE grade_value = 90;

CREATE INDEX idx_grade_value ON grades(grade_value);
SHOW INDEX FROM grades;
EXPLAIN SELECT * FROM grades WHERE grade_value = 90;

CREATE INDEX idx_student_subject ON grades(student_id, subject_id);
EXPLAIN SELECT * FROM grades WHERE student_id = 1 AND subject_id = 2;

CREATE INDEX idx_subject_name ON subjects(subject_name);
EXPLAIN SELECT * FROM subjects WHERE subject_name = 'Databases';

SELECT @@transaction_isolation;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;

START TRANSACTION;
UPDATE grades SET grade_value = 70 WHERE grade_id = 1;
SELECT * FROM grades WHERE grade_id = 1;
ROLLBACK;
SELECT * FROM grades WHERE grade_id = 1;

CREATE VIEW public_student_grades AS
SELECT s.student_id, s.last_name, s.first_name, sub.subject_name, g.grade_value
FROM students s
JOIN grades g ON s.student_id = g.student_id
JOIN subjects sub ON g.subject_id = sub.subject_id;

CREATE VIEW teacher_average_grades AS
SELECT s.student_id, s.last_name, s.first_name, ROUND(AVG(g.grade_value), 2) AS average_grade
FROM students s
JOIN grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.last_name, s.first_name;

SELECT * FROM public_student_grades;
SELECT * FROM teacher_average_grades;

CREATE USER IF NOT EXISTS 'student_user'@'localhost' IDENTIFIED BY 'Student123!';
GRANT SELECT ON hospital_db.* TO 'student_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';
GRANT UPDATE ON hospital_db.grades TO 'student_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';
REVOKE UPDATE ON hospital_db.grades FROM 'student_user'@'localhost';
REVOKE SELECT ON hospital_db.* FROM 'student_user'@'localhost';
GRANT SELECT ON hospital_db.public_student_grades TO 'student_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';

CREATE USER IF NOT EXISTS 'teacher_user'@'localhost' IDENTIFIED BY 'Teacher123!';
GRANT SELECT ON hospital_db.students TO 'teacher_user'@'localhost';
GRANT SELECT, UPDATE ON hospital_db.grades TO 'teacher_user'@'localhost';
GRANT SELECT ON hospital_db.teacher_average_grades TO 'teacher_user'@'localhost';
SHOW GRANTS FOR 'teacher_user'@'localhost';

START TRANSACTION;
SELECT * FROM grades WHERE grade_id = 1 FOR UPDATE;
UPDATE grades SET grade_value = 88 WHERE grade_id = 1;
SELECT * FROM grades WHERE grade_id = 1;
COMMIT;

START TRANSACTION;
UPDATE grades SET grade_value = 99 WHERE grade_id = 1;
COMMIT;

SHOW INDEX FROM grades;
DROP INDEX idx_grade_value ON grades;
SHOW INDEX FROM grades;
EXPLAIN SELECT * FROM grades WHERE grade_value = 90;
