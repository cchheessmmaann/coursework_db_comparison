-- ============================================================
-- Online Education Platform Database Schema
-- Database: education_platform
-- DBMS: PostgreSQL
-- ============================================================

-- ============================================================
-- 1. USERS (Base table for Students and Teachers)
-- ============================================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_users_email ON users(email);

-- ============================================================
-- 2. STUDENTS
-- ============================================================
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    student_number VARCHAR(50) NOT NULL UNIQUE,
    bio TEXT,
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_students_enrollment_date ON students(enrollment_date);

-- ============================================================
-- 3. TEACHERS
-- ============================================================
CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    employee_number VARCHAR(50) NOT NULL UNIQUE,
    specialization VARCHAR(255),
    bio TEXT,
    hire_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_teachers_specialization ON teachers(specialization);

-- ============================================================
-- 4. COURSES
-- ============================================================
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructor_id INTEGER NOT NULL,
    category VARCHAR(100),
    difficulty_level VARCHAR(50) CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Draft', 'Active', 'Archived')),
    max_students INTEGER,
    FOREIGN KEY (instructor_id) REFERENCES teachers(teacher_id) ON DELETE RESTRICT
);

CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_category ON courses(category);

-- ============================================================
-- 5. COURSE ENROLLMENT (Students enrolling in Courses)
-- ============================================================
CREATE TABLE course_enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP,
    status VARCHAR(50) DEFAULT 'In Progress' CHECK (status IN ('In Progress', 'Completed', 'Dropped', 'Suspended')),
    grade DECIMAL(5,2),
    UNIQUE (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE INDEX idx_enrollments_student ON course_enrollments(student_id);
CREATE INDEX idx_enrollments_course ON course_enrollments(course_id);
CREATE INDEX idx_enrollments_status ON course_enrollments(status);

-- ============================================================
-- 6. MODULES (Course structure level 1)
-- ============================================================
CREATE TABLE modules (
    module_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, order_number),
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE INDEX idx_modules_course ON modules(course_id);

-- ============================================================
-- 7. LESSONS (Course structure level 2)
-- ============================================================
CREATE TABLE lessons (
    lesson_id SERIAL PRIMARY KEY,
    module_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    lesson_type VARCHAR(50) CHECK (lesson_type IN ('Video', 'Text', 'Quiz', 'Interactive')),
    content_url VARCHAR(500),
    duration_minutes INTEGER,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (module_id, order_number),
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE
);

CREATE INDEX idx_lessons_module ON lessons(module_id);
CREATE INDEX idx_lessons_type ON lessons(lesson_type);

-- ============================================================
-- 8. QUIZZES (Tests within lessons)
-- ============================================================
CREATE TABLE quizzes (
    quiz_id SERIAL PRIMARY KEY,
    lesson_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    passing_score DECIMAL(5,2) NOT NULL DEFAULT 70.0,
    total_questions INTEGER NOT NULL,
    time_limit_minutes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_quizzes_lesson ON quizzes(lesson_id);

-- ============================================================
-- 9. LESSON PROGRESS (Student progress per lesson)
-- ============================================================
CREATE TABLE lesson_progress (
    progress_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'In Progress', 'Completed')),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    quiz_score DECIMAL(5,2),
    time_spent_minutes INTEGER DEFAULT 0,
    UNIQUE (student_id, lesson_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_lesson_progress_student ON lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_status ON lesson_progress(status);

-- ============================================================
-- 10. HOMEWORKS (Assignments)
-- ============================================================
CREATE TABLE homeworks (
    homework_id SERIAL PRIMARY KEY,
    lesson_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    instructions TEXT,
    max_score DECIMAL(5,2) NOT NULL DEFAULT 100.0,
    due_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
);

CREATE INDEX idx_homeworks_lesson ON homeworks(lesson_id);
CREATE INDEX idx_homeworks_due_date ON homeworks(due_date);

-- ============================================================
-- 11. HOMEWORK SUBMISSIONS (Student submissions)
-- ============================================================
CREATE TABLE homework_submissions (
    submission_id SERIAL PRIMARY KEY,
    homework_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    submission_text TEXT,
    file_url VARCHAR(500),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Submitted' CHECK (status IN ('Submitted', 'Under Review', 'Graded', 'Resubmitted')),
    is_late BOOLEAN DEFAULT FALSE,
    UNIQUE (homework_id, student_id),
    FOREIGN KEY (homework_id) REFERENCES homeworks(homework_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX idx_submissions_homework ON homework_submissions(homework_id);
CREATE INDEX idx_submissions_student ON homework_submissions(student_id);
CREATE INDEX idx_submissions_status ON homework_submissions(status);

-- ============================================================
-- 12. HOMEWORK REVIEWS (Teacher feedback cycle)
-- ============================================================
CREATE TABLE homework_reviews (
    review_id SERIAL PRIMARY KEY,
    submission_id INTEGER NOT NULL,
    teacher_id INTEGER NOT NULL,
    score DECIMAL(5,2),
    feedback TEXT,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Reviewed', 'Approved')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    review_round INTEGER DEFAULT 1,
    FOREIGN KEY (submission_id) REFERENCES homework_submissions(submission_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE RESTRICT
);

CREATE INDEX idx_reviews_submission ON homework_reviews(submission_id);
CREATE INDEX idx_reviews_teacher ON homework_reviews(teacher_id);
CREATE INDEX idx_reviews_status ON homework_reviews(status);

-- ============================================================
-- 13. REVIEW COMMENTS (Detailed feedback)
-- ============================================================
CREATE TABLE review_comments (
    comment_id SERIAL PRIMARY KEY,
    review_id INTEGER NOT NULL,
    commenter_id INTEGER NOT NULL,
    comment_text TEXT NOT NULL,
    line_number INTEGER,
    comment_type VARCHAR(50) CHECK (comment_type IN ('General', 'Specific', 'Question')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES homework_reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY (commenter_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

CREATE INDEX idx_comments_review ON review_comments(review_id);
CREATE INDEX idx_comments_commenter ON review_comments(commenter_id);

-- ============================================================
-- Views for common business logic
-- ============================================================

-- View: Student Course Progress
CREATE VIEW v_student_course_progress AS
SELECT
    ce.enrollment_id,
    s.student_id,
    u.first_name,
    u.last_name,
    c.course_id,
    c.title AS course_title,
    COUNT(DISTINCT l.lesson_id) AS total_lessons,
    COUNT(DISTINCT lp.lesson_id) FILTER (WHERE lp.status = 'Completed') AS completed_lessons,
    ROUND(
        COUNT(DISTINCT lp.lesson_id) FILTER (WHERE lp.status = 'Completed') * 100.0 / 
        NULLIF(COUNT(DISTINCT l.lesson_id), 0), 2
    ) AS progress_percentage,
    ce.status AS enrollment_status,
    ce.grade
FROM course_enrollments ce
JOIN students s ON ce.student_id = s.student_id
JOIN users u ON s.user_id = u.user_id
JOIN courses c ON ce.course_id = c.course_id
JOIN modules m ON c.course_id = m.course_id
JOIN lessons l ON m.module_id = l.module_id
LEFT JOIN lesson_progress lp ON l.lesson_id = lp.lesson_id AND s.student_id = lp.student_id
GROUP BY ce.enrollment_id, s.student_id, u.first_name, u.last_name, c.course_id, c.title, ce.status, ce.grade;

-- View: Homework Submission Status
CREATE VIEW v_homework_status AS
SELECT
    h.homework_id,
    h.title AS homework_title,
    c.course_id,
    c.title AS course_title,
    COUNT(DISTINCT hs.student_id) AS total_students,
    COUNT(DISTINCT hs.submission_id) FILTER (WHERE hs.status = 'Submitted' OR hs.status = 'Resubmitted') AS submitted,
    COUNT(DISTINCT hs.submission_id) FILTER (WHERE hs.status = 'Graded') AS graded,
    COUNT(DISTINCT hs.student_id) FILTER (WHERE hs.submitted_at > h.due_date) AS late_submissions
FROM homeworks h
JOIN lessons l ON h.lesson_id = l.lesson_id
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
JOIN course_enrollments ce ON c.course_id = ce.course_id
LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id
GROUP BY h.homework_id, h.title, c.course_id, c.title;
