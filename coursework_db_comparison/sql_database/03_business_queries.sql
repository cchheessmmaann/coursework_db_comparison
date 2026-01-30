
-- QUERY 1: Find students not submitting more than 2 homeworks in a course
-- This identifies at-risk students who may need intervention
-- Business requirement: Monitor students who are falling behind on assignments
SELECT 
    s.student_id,
    u.first_name || ' ' || u.last_name AS student_name,
    c.course_id,
    c.title AS course_title,
    COUNT(DISTINCT h.homework_id) AS total_homeworks,
    COUNT(DISTINCT hs.submission_id) AS submitted_homeworks,
    COUNT(DISTINCT h.homework_id) - COUNT(DISTINCT hs.submission_id) AS missing_submissions,
    ROUND(
        COUNT(DISTINCT hs.submission_id) * 100.0 / 
        NULLIF(COUNT(DISTINCT h.homework_id), 0), 2
    ) AS submission_rate
FROM students s
JOIN users u ON s.user_id = u.user_id
JOIN course_enrollments ce ON s.student_id = ce.student_id
JOIN courses c ON ce.course_id = c.course_id
JOIN modules m ON c.course_id = m.course_id
JOIN lessons l ON m.module_id = l.module_id
JOIN homeworks h ON l.lesson_id = h.lesson_id
LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id AND s.student_id = hs.student_id
GROUP BY s.student_id, u.first_name, u.last_name, c.course_id, c.title
HAVING COUNT(DISTINCT h.homework_id) > 0
    AND (COUNT(DISTINCT h.homework_id) - COUNT(DISTINCT hs.submission_id)) > 2
ORDER BY missing_submissions DESC, c.title;

-- QUERY 2: Calculate course completion rate and identify lagging students
-- Shows progress for each student across course structure
-- Business requirement: Track student progress and identify those needing support
SELECT 
    ce.enrollment_id,
    s.student_id,
    u.first_name || ' ' || u.last_name AS student_name,
    c.course_id,
    c.title AS course_title,
    c.difficulty_level,
    COUNT(DISTINCT l.lesson_id) AS total_lessons,
    COUNT(DISTINCT CASE WHEN lp.status = 'Completed' THEN l.lesson_id END) AS completed_lessons,
    COUNT(DISTINCT CASE WHEN lp.status = 'In Progress' THEN l.lesson_id END) AS in_progress_lessons,
    COUNT(DISTINCT CASE WHEN lp.status = 'Not Started' THEN l.lesson_id END) AS not_started_lessons,
    ROUND(
        COUNT(DISTINCT CASE WHEN lp.status = 'Completed' THEN l.lesson_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT l.lesson_id), 0), 2
    ) AS completion_percentage,
    ROUND(AVG(lp.time_spent_minutes), 2) AS avg_time_per_lesson,
    ce.status AS enrollment_status,
    EXTRACT(DAY FROM CURRENT_TIMESTAMP - ce.enrollment_date) AS days_enrolled
FROM course_enrollments ce
JOIN students s ON ce.student_id = s.student_id
JOIN users u ON s.user_id = u.user_id
JOIN courses c ON ce.course_id = c.course_id
JOIN modules m ON c.course_id = m.course_id
JOIN lessons l ON m.module_id = l.lesson_id
LEFT JOIN lesson_progress lp ON l.lesson_id = lp.lesson_id AND s.student_id = lp.student_id
GROUP BY ce.enrollment_id, s.student_id, u.first_name, u.last_name, c.course_id, c.title, c.difficulty_level, ce.status, ce.enrollment_date
ORDER BY c.course_id, completion_percentage, student_name;

-- QUERY 3: Homework review cycle analysis
-- Shows homework submissions and their review status
-- Business requirement: Track homework grading pipeline and feedback cycles
SELECT 
    h.homework_id,
    h.title AS homework_title,
    l.lesson_id,
    l.title AS lesson_title,
    m.title AS module_title,
    c.title AS course_title,
    COUNT(DISTINCT hs.submission_id) AS total_submissions,
    COUNT(DISTINCT CASE WHEN hs.status = 'Submitted' OR hs.status = 'Resubmitted' THEN hs.submission_id END) AS pending_review,
    COUNT(DISTINCT CASE WHEN hs.status = 'Graded' THEN hs.submission_id END) AS graded,
    COUNT(DISTINCT CASE WHEN hs.is_late = TRUE THEN hs.submission_id END) AS late_submissions,
    COUNT(DISTINCT hr.review_id) AS total_reviews,
    COUNT(DISTINCT CASE WHEN hr.status = 'Reviewed' THEN hr.review_id END) AS ongoing_reviews,
    ROUND(
        COUNT(DISTINCT CASE WHEN hs.status = 'Graded' THEN hs.submission_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT hs.submission_id), 0), 2
    ) AS grading_completion_rate,
    ROUND(AVG(hr.score), 2) AS avg_score
FROM homeworks h
JOIN lessons l ON h.lesson_id = l.lesson_id
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id
LEFT JOIN homework_reviews hr ON hs.submission_id = hr.submission_id
GROUP BY h.homework_id, h.title, l.lesson_id, l.title, m.title, c.title
ORDER BY c.course_id, h.homework_id;

-- QUERY 4: Teacher workload analysis
-- Shows teaching load and grading responsibilities
-- Business requirement: Monitor teacher workload and balance course assignments
SELECT 
    t.teacher_id,
    u.first_name || ' ' || u.last_name AS teacher_name,
    t.specialization,
    COUNT(DISTINCT c.course_id) AS courses_teaching,
    COUNT(DISTINCT ce.student_id) AS total_students,
    COUNT(DISTINCT h.homework_id) AS total_homeworks_created,
    COUNT(DISTINCT hs.submission_id) AS submissions_to_review,
    COUNT(DISTINCT CASE WHEN hr.status != 'Approved' THEN hr.review_id END) AS pending_reviews,
    COUNT(DISTINCT CASE WHEN hs.is_late = TRUE THEN hs.submission_id END) AS late_submissions_received,
    ROUND(
        AVG(CASE WHEN hr.score IS NOT NULL THEN hr.score ELSE NULL END), 2
    ) AS avg_grade_given
FROM teachers t
JOIN users u ON t.user_id = u.user_id
JOIN courses c ON t.teacher_id = c.instructor_id
JOIN course_enrollments ce ON c.course_id = ce.course_id
JOIN modules m ON c.course_id = m.course_id
JOIN lessons l ON m.module_id = l.lesson_id
LEFT JOIN homeworks h ON l.lesson_id = h.lesson_id
LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id
LEFT JOIN homework_reviews hr ON hs.submission_id = hr.submission_id AND t.teacher_id = hr.teacher_id
GROUP BY t.teacher_id, u.first_name, u.last_name, t.specialization
ORDER BY courses_teaching DESC, total_students DESC;

-- QUERY 5: Course analytics and performance metrics
-- Provides comprehensive course statistics
-- Business requirement: Monitor course quality and student outcomes
SELECT 
    c.course_id,
    c.title AS course_title,
    t.teacher_id,
    u_teacher.first_name || ' ' || u_teacher.last_name AS instructor_name,
    c.category,
    c.difficulty_level,
    COUNT(DISTINCT ce.student_id) AS enrolled_students,
    COUNT(DISTINCT CASE WHEN ce.status = 'In Progress' THEN ce.student_id END) AS active_students,
    COUNT(DISTINCT CASE WHEN ce.status = 'Completed' THEN ce.student_id END) AS completed,
    COUNT(DISTINCT CASE WHEN ce.status = 'Dropped' THEN ce.student_id END) AS dropped,
    COUNT(DISTINCT m.module_id) AS num_modules,
    COUNT(DISTINCT l.lesson_id) AS num_lessons,
    COUNT(DISTINCT h.homework_id) AS num_homeworks,
    ROUND(
        AVG(CASE WHEN lp.status = 'Completed' THEN 1 ELSE 0 END) * 100, 2
    ) AS avg_lesson_completion_rate,
    ROUND(AVG(ce.grade), 2) AS avg_student_grade,
    ROUND(
        COUNT(DISTINCT CASE WHEN ce.status = 'Completed' THEN ce.student_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT ce.student_id), 0), 2
    ) AS completion_rate,
    c.created_at AS course_created_date,
    EXTRACT(DAY FROM CURRENT_TIMESTAMP - c.created_at) AS days_active
FROM courses c
JOIN teachers t ON c.instructor_id = t.teacher_id
JOIN users u_teacher ON t.user_id = u_teacher.user_id
LEFT JOIN course_enrollments ce ON c.course_id = ce.course_id
LEFT JOIN modules m ON c.course_id = m.course_id
LEFT JOIN lessons l ON m.module_id = l.lesson_id
LEFT JOIN lesson_progress lp ON l.lesson_id = lp.lesson_id
LEFT JOIN homeworks h ON l.lesson_id = h.lesson_id
GROUP BY c.course_id, c.title, t.teacher_id, u_teacher.first_name, u_teacher.last_name, 
         c.category, c.difficulty_level, c.created_at
ORDER BY enrolled_students DESC, c.created_at DESC;

-- QUERY 6: Quiz performance analysis (bonus - extends original 5)
-- Identifies students struggling with assessments
-- Business requirement: Monitor quiz performance to identify knowledge gaps
SELECT 
    q.quiz_id,
    q.title AS quiz_title,
    l.title AS lesson_title,
    m.title AS module_title,
    c.title AS course_title,
    q.passing_score,
    COUNT(DISTINCT lp.student_id) AS students_attempted,
    COUNT(DISTINCT CASE WHEN lp.quiz_score >= q.passing_score THEN lp.student_id END) AS passed,
    COUNT(DISTINCT CASE WHEN lp.quiz_score < q.passing_score THEN lp.student_id END) AS failed,
    ROUND(AVG(lp.quiz_score), 2) AS avg_score,
    ROUND(
        COUNT(DISTINCT CASE WHEN lp.quiz_score >= q.passing_score THEN lp.student_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT lp.student_id), 0), 2
    ) AS pass_rate,
    MIN(lp.quiz_score) AS lowest_score,
    MAX(lp.quiz_score) AS highest_score
FROM quizzes q
JOIN lessons l ON q.lesson_id = l.lesson_id
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
LEFT JOIN lesson_progress lp ON q.lesson_id = lp.lesson_id AND lp.quiz_score IS NOT NULL
GROUP BY q.quiz_id, q.title, l.title, m.title, c.title, q.passing_score
ORDER BY c.course_id, m.order_number, l.order_number, pass_rate;
