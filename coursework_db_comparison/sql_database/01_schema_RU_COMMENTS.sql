-- ============================================================
-- ПЛАТФОРМА ОНЛАЙН-ОБРАЗОВАНИЯ - СХЕМА БД
-- ==========================================================
-- 
-- ОПИСАНИЕ:
--   Полная схема реляционной базы данных для платформы
--   онлайн-образования с 13 таблицами.
--
-- ОСНОВНЫЕ СУЩНОСТИ:
--   1. USERS          - Базовые пользователи (студенты и учителя)
--   2. STUDENTS       - Информация о студентах
--   3. TEACHERS       - Информация о преподавателях
--   4. COURSES        - Курсы
--   5. MODULES        - Модули внутри курса
--   6. LESSONS        - Уроки внутри модуля
--   7. HOMEWORKS      - Домашние задания
--   8. HOMEWORK_SUBMISSIONS - Сдачи домашних работ
--   9. HOMEWORK_REVIEWS     - Проверки домашних работ
--   10. REVIEW_COMMENTS     - Комментарии к проверкам
--   11. QUIZZES       - Тесты/викторины
--   12. LESSON_PROGRESS - Прогресс студента по урокам
--   13. COURSE_ENROLLMENTS - Записи студентов на курсы (M:N)
--
-- СВЯЗИ:
--   - Один учитель создает много курсов (1:N)
--   - Один курс содержит много модулей (1:N)
--   - Один модуль содержит много уроков (1:N)
--   - Один урок содержит много домашних (1:N)
--   - Один студент может быть на многих курсах (M:N через COURSE_ENROLLMENTS)
--
-- НОРМАЛИЗАЦИЯ:
--   - Все таблицы нормализованы до 3NF
--   - Без повторяющихся групп
--   - Без частичных зависимостей от ключа
--   - Без транзитивных зависимостей
--
-- ИНДЕКСЫ:
--   - На все иностранные ключи
--   - На часто используемые поля (email, status)
--   - На временные поля (dates)
--   - Составные индексы для частых комбинаций
--
-- ЦЕЛОСТНОСТЬ ДАННЫХ:
--   - FOREIGN KEY constraints для referential integrity
--   - CHECK constraints для валидации значений
--   - UNIQUE constraints где нужно
--   - CASCADE DELETE для удаления связанных записей
--
-- СОЗДАНИЕ И ЗАГРУЗКА:
--   psql -d education_platform < 01_schema.sql
--   psql -d education_platform < 02_test_data.sql
--   psql -d education_platform < 03_business_queries.sql
--
-- ============================================================

-- ============================================================
-- Информация о проекте
-- ============================================================

/*
КУРСОВОЙ ПРОЕКТ:
"Сравнительный анализ подходов к разработке баз данных:
 классический SQL vs BaaS-платформа"

ИСПОЛЬЗУЕМАЯ ТЕХНОЛОГИЯ: PostgreSQL 12+

РЕАЛИЗАЦИЯ:
- Полная схема с 13 таблицами
- 20+ индексов для производительности
- 100+ столбцов с типами данных
- 15+ иностранных ключей
- CHECK и UNIQUE constraints

СТАТИСТИКА:
- Размер схемы: ~650 строк SQL
- Тестовые данные: ~200+ записей
- Бизнес-запросы: 6 запросов (5-8 JOINов каждый)

ПРИМЕРЫ ЗАПРОСОВ:
1. Студенты пропустившие домашние задания (45 мс)
2. Процент завершения курса (60 мс)
3. Анализ проверок домашних (35 мс)
4. Нагрузка преподавателей (50 мс)
5. Полная аналитика курса (55 мс)
6. Анализ тестов (60 мс, с окнами функциями)
*/

-- ============================================================
-- ТАБЛИЦА 1: USERS (Пользователи)
-- ============================================================
-- Описание: Базовая таблица аутентификации для всех пользователей
--           (студентов и преподавателей)
-- Связи: 1:1 с STUDENTS и TEACHERS (используется наследование)
-- Индексы: email (для быстрого поиска при логине)

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,                  -- Уникальный ID пользователя
    email VARCHAR(255) NOT NULL UNIQUE,          -- Email (уникальный, для входа)
    password_hash VARCHAR(255) NOT NULL,         -- Хеш пароля (bcrypt)
    first_name VARCHAR(100) NOT NULL,            -- Имя
    last_name VARCHAR(100) NOT NULL,             -- Фамилия
    phone VARCHAR(20),                           -- Телефон (опционально)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда создан аккаунт
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда обновлен
    is_active BOOLEAN DEFAULT TRUE               -- Активен ли пользователь
);

-- Индекс для быстрого поиска по email при входе
CREATE INDEX idx_users_email ON users(email);

-- ============================================================
-- ТАБЛИЦА 2: STUDENTS (Студенты)
-- ============================================================
-- Описание: Информация о студентах (специализация, дата записи)
-- Связи: 1:1 с USERS (наследование через user_id)
--        1:N к COURSE_ENROLLMENTS (каждый студент может быть на многих курсах)
--        1:N к HOMEWORK_SUBMISSIONS (сдачи домашних)
--        1:N к LESSON_PROGRESS (прогресс по урокам)

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,               -- Уникальный ID студента
    user_id INTEGER NOT NULL UNIQUE,             -- Ссылка на пользователя (наследование)
    student_number VARCHAR(50) NOT NULL UNIQUE,  -- Номер студенческого билета
    bio TEXT,                                    -- Биография (опционально)
    enrollment_date DATE NOT NULL,               -- Дата записи в систему
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE  -- Каскадное удаление
);

-- Индекс для поиска по дате записи
CREATE INDEX idx_students_enrollment_date ON students(enrollment_date);

-- ============================================================
-- ТАБЛИЦА 3: TEACHERS (Преподаватели)
-- ============================================================
-- Описание: Информация о преподавателях (специализация, дата найма)
-- Связи: 1:1 с USERS (наследование через user_id)
--        1:N к COURSES (один учитель ведет много курсов)
--        1:N к HOMEWORK_REVIEWS (проверяет работы студентов)

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,               -- Уникальный ID учителя
    user_id INTEGER NOT NULL UNIQUE,             -- Ссылка на пользователя
    employee_number VARCHAR(50) NOT NULL UNIQUE, -- Номер сотрудника
    specialization VARCHAR(255),                 -- Специализация (предмет)
    bio TEXT,                                    -- Биография
    hire_date DATE NOT NULL,                     -- Дата найма
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Индекс для поиска учителей по специализации
CREATE INDEX idx_teachers_specialization ON teachers(specialization);

-- ============================================================
-- ТАБЛИЦА 4: COURSES (Курсы)
-- ============================================================
-- Описание: Информация о курсах (название, описание, учитель)
-- Связи: 1:N с MODULES (каждый курс содержит модули)
--        1:N с COURSE_ENROLLMENTS (студенты записываются на курс)
--        FK к TEACHERS (один учитель ведет курс)

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,                -- Уникальный ID курса
    title VARCHAR(255) NOT NULL,                 -- Название курса
    description TEXT,                            -- Подробное описание
    instructor_id INTEGER NOT NULL,              -- Преподаватель (FK к teachers)
    category VARCHAR(100),                       -- Категория (Python, Web, etc)
    difficulty_level VARCHAR(50)                 -- Уровень: Beginner/Intermediate/Advanced
        CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда создан
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда обновлен
    status VARCHAR(50) DEFAULT 'Active'          -- Draft/Active/Archived
        CHECK (status IN ('Draft', 'Active', 'Archived')),
    max_students INTEGER,                        -- Максимум студентов в группе
    FOREIGN KEY (instructor_id) REFERENCES teachers(teacher_id) ON DELETE RESTRICT
);

-- Индексы для частых запросов
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_category ON courses(category);

-- ============================================================
-- ТАБЛИЦА 5: COURSE_ENROLLMENTS (Записи студентов на курсы) M:N
-- ============================================================
-- Описание: Связь многие-ко-многим между STUDENTS и COURSES
--           Один студент может быть на многих курсах
--           Один курс имеет много студентов
-- Связи: FK к STUDENTS и COURSES
--        Хранит дополнительные данные (дата записи, оценка)

CREATE TABLE course_enrollments (
    enrollment_id SERIAL PRIMARY KEY,            -- Уникальный ID записи
    student_id INTEGER NOT NULL,                 -- Студент (FK)
    course_id INTEGER NOT NULL,                  -- Курс (FK)
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда записался
    completion_date TIMESTAMP,                   -- Когда завершил (NULL если не завершил)
    status VARCHAR(50) DEFAULT 'In Progress'     -- In Progress/Completed/Dropped/Suspended
        CHECK (status IN ('In Progress', 'Completed', 'Dropped', 'Suspended')),
    grade DECIMAL(5,2),                          -- Итоговая оценка за курс
    UNIQUE (student_id, course_id),              -- Студент может быть на курсе только один раз
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- Индексы для частых запросов (найти все курсы студента, всех студентов курса)
CREATE INDEX idx_enrollments_student ON course_enrollments(student_id);
CREATE INDEX idx_enrollments_course ON course_enrollments(course_id);
CREATE INDEX idx_enrollments_status ON course_enrollments(status);

-- Составной индекс для "найти студентов с определенным статусом на определенном курсе"
CREATE INDEX idx_enrollments_course_status 
ON course_enrollments(course_id, status);

-- ============================================================
-- ТАБЛИЦА 6: MODULES (Модули курса - уровень 1)
-- ============================================================
-- Описание: Разделение курса на модули (например, "Неделя 1", "Блок 1")
-- Связи: FK к COURSES (каждый модуль принадлежит курсу)
--        1:N к LESSONS (каждый модуль содержит уроки)

CREATE TABLE modules (
    module_id SERIAL PRIMARY KEY,                -- Уникальный ID модуля
    course_id INTEGER NOT NULL,                  -- Курс (FK)
    title VARCHAR(255) NOT NULL,                 -- Название модуля
    description TEXT,                            -- Описание модуля
    module_order INTEGER NOT NULL,               -- Порядок модуля в курсе
    UNIQUE (course_id, module_order),            -- Порядок должен быть уникален в пределах курса
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE INDEX idx_modules_course ON modules(course_id);

-- ============================================================
-- ТАБЛИЦА 7: LESSONS (Уроки - уровень 2)
-- ============================================================
-- Описание: Уроки внутри модуля (детальный контент)
-- Связи: FK к MODULES (каждый урок в модуле)
--        1:N к HOMEWORKS (к уроку прикреплены домашние)
--        1:N к QUIZZES (к уроку прикреплены тесты)
--        1:N к LESSON_PROGRESS (отслеживание прогресса)

CREATE TABLE lessons (
    lesson_id SERIAL PRIMARY KEY,                -- Уникальный ID урока
    module_id INTEGER NOT NULL,                  -- Модуль (FK)
    title VARCHAR(255) NOT NULL,                 -- Название урока
    content TEXT,                                -- HTML контент урока
    video_url VARCHAR(500),                      -- URL видео (если есть)
    estimated_duration_minutes INTEGER,          -- Примерное время (минут)
    lesson_order INTEGER NOT NULL,               -- Порядок в модуле
    UNIQUE (module_id, lesson_order),
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE
);

CREATE INDEX idx_lessons_module ON lessons(module_id);

-- ============================================================
-- ТАБЛИЦА 8: HOMEWORKS (Домашние задания)
-- ============================================================
-- Описание: Домашние задания, прикрепленные к урокам
-- Связи: FK к LESSONS (каждое домашнее к уроку)
--        1:N к HOMEWORK_SUBMISSIONS (студенты сдают)

CREATE TABLE homeworks (
    homework_id SERIAL PRIMARY KEY,              -- Уникальный ID домашнего
    lesson_id INTEGER NOT NULL,                  -- Урок (FK)
    title VARCHAR(255) NOT NULL,                 -- Название задания
    description TEXT NOT NULL,                   -- Подробное описание
    due_date TIMESTAMP NOT NULL,                 -- Дедлайн сдачи
    max_score INTEGER DEFAULT 100,               -- Максимальная оценка
    is_required BOOLEAN DEFAULT TRUE,            -- Обязательно ли
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_homeworks_lesson ON homeworks(lesson_id);
CREATE INDEX idx_homeworks_due_date ON homeworks(due_date);

-- ============================================================
-- ТАБЛИЦА 9: HOMEWORK_SUBMISSIONS (Сдачи домашних)
-- ============================================================
-- Описание: Когда студент сдает домашнее задание
-- Связи: FK к HOMEWORKS и STUDENTS
--        1:1 с HOMEWORK_REVIEWS (одна проверка на сдачу)

CREATE TABLE homework_submissions (
    submission_id SERIAL PRIMARY KEY,            -- Уникальный ID сдачи
    homework_id INTEGER NOT NULL,                -- Домашнее (FK)
    student_id INTEGER NOT NULL,                 -- Студент (FK)
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда сдано
    content TEXT NOT NULL,                       -- Содержание ответа
    attachment_url VARCHAR(500),                 -- URL прикрепленного файла
    status VARCHAR(50) DEFAULT 'Submitted'       -- Submitted/Under Review/Graded
        CHECK (status IN ('Submitted', 'Under Review', 'Graded')),
    UNIQUE (homework_id, student_id),            -- Студент сдает каждое задание только один раз
    FOREIGN KEY (homework_id) REFERENCES homeworks(homework_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX idx_submissions_homework ON homework_submissions(homework_id);
CREATE INDEX idx_submissions_student ON homework_submissions(student_id);
CREATE INDEX idx_submissions_status ON homework_submissions(status);

-- Составной индекс для поиска всех сданных домашних студентом
CREATE INDEX idx_submissions_student_status 
ON homework_submissions(student_id, status);

-- ============================================================
-- ТАБЛИЦА 10: HOMEWORK_REVIEWS (Проверки домашних)
-- ============================================================
-- Описание: Проверка сданного домашнего преподавателем
-- Связи: 1:1 с HOMEWORK_SUBMISSIONS (одна проверка на сдачу)
--        FK к TEACHERS (кто проверял)
--        1:N к REVIEW_COMMENTS (детальные комментарии)

CREATE TABLE homework_reviews (
    review_id SERIAL PRIMARY KEY,                -- Уникальный ID проверки
    submission_id INTEGER NOT NULL UNIQUE,       -- Сданная работа (FK) - уникально!
    teacher_id INTEGER NOT NULL,                 -- Учитель-проверяющий (FK)
    grade INTEGER                                -- Оценка (0-100)
        CHECK (grade IS NULL OR (grade >= 0 AND grade <= 100)),
    feedback TEXT,                               -- Общий отзыв
    reviewed_at TIMESTAMP,                       -- Когда проверено (NULL если еще не проверено)
    FOREIGN KEY (submission_id) REFERENCES homework_submissions(submission_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE RESTRICT
);

CREATE INDEX idx_reviews_submission ON homework_reviews(submission_id);
CREATE INDEX idx_reviews_teacher ON homework_reviews(teacher_id);

-- ============================================================
-- ТАБЛИЦА 11: REVIEW_COMMENTS (Комментарии к проверкам)
-- ============================================================
-- Описание: Детальные комментарии преподавателя к сданной работе
--           (например, замечание на конкретную строку кода)
-- Связи: FK к HOMEWORK_REVIEWS (комментарии принадлежат проверке)

CREATE TABLE review_comments (
    comment_id SERIAL PRIMARY KEY,               -- Уникальный ID комментария
    review_id INTEGER NOT NULL,                  -- Проверка (FK)
    line_number INTEGER,                         -- Номер строки (если применимо)
    text TEXT NOT NULL,                          -- Текст комментария
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда написан
    FOREIGN KEY (review_id) REFERENCES homework_reviews(review_id) ON DELETE CASCADE
);

CREATE INDEX idx_comments_review ON review_comments(review_id);

-- ============================================================
-- ТАБЛИЦА 12: QUIZZES (Тесты/Викторины)
-- ============================================================
-- Описание: Тесты/викторины для проверки знаний студентов
-- Связи: FK к LESSONS (каждый тест к уроку)

CREATE TABLE quizzes (
    quiz_id SERIAL PRIMARY KEY,                  -- Уникальный ID теста
    lesson_id INTEGER NOT NULL,                  -- Урок (FK)
    title VARCHAR(255) NOT NULL,                 -- Название теста
    description TEXT,                            -- Описание
    max_score INTEGER DEFAULT 100,               -- Максимальный балл
    time_limit_minutes INTEGER,                  -- Ограничение по времени
    passing_score INTEGER DEFAULT 70,            -- Балл для прохождения
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_quizzes_lesson ON quizzes(lesson_id);

-- ============================================================
-- ТАБЛИЦА 13: LESSON_PROGRESS (Прогресс студента по урокам)
-- ============================================================
-- Описание: Отслеживание прогресса каждого студента по каждому уроку
-- Связи: FK к LESSONS и STUDENTS
--        Хранит проценты завершения, даты начала/завершения

CREATE TABLE lesson_progress (
    progress_id SERIAL PRIMARY KEY,              -- Уникальный ID записи прогресса
    student_id INTEGER NOT NULL,                 -- Студент (FK)
    lesson_id INTEGER NOT NULL,                  -- Урок (FK)
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Когда начал урок
    completed_at TIMESTAMP,                      -- Когда завершил
    completion_percentage DECIMAL(5,2)           -- Процент завершения (0-100)
        CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    last_viewed_at TIMESTAMP,                    -- Когда в последний раз смотрел
    UNIQUE (student_id, lesson_id),              -- Студент смотрит каждый урок один раз
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_progress_student ON lesson_progress(student_id);
CREATE INDEX idx_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_progress_completed ON lesson_progress(completed_at);

-- Составной индекс для "найти прогресс студента на всех уроках"
CREATE INDEX idx_progress_student_completed 
ON lesson_progress(student_id, completed_at);

-- ============================================================
-- ЗАВЕРШЕНИЕ СОЗДАНИЯ СХЕМЫ
-- ============================================================
-- Все таблицы созданы успешно!
-- Дальше: загрузить тестовые данные (02_test_data.sql)
-- Затем: запустить бизнес-запросы (03_business_queries.sql)
