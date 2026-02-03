-- ============================================================
-- 1. Insert Users
-- ============================================================

-- Teachers
INSERT INTO users (email, password_hash, first_name, last_name, phone, is_active)
VALUES
    ('dr.smith@edu.com', 'hash_123', 'John', 'Smith', '+1234567890', TRUE),
    ('prof.johnson@edu.com', 'hash_456', 'Sarah', 'Johnson', '+1234567891', TRUE),
    ('dr.williams@edu.com', 'hash_789', 'Michael', 'Williams', '+1234567892', TRUE),
    ('prof.brown@edu.com', 'hash_012', 'Emily', 'Brown', '+1234567893', TRUE),
    ('dr.davis@edu.com', 'hash_345', 'Robert', 'Davis', '+1234567894', TRUE),
    -- Students
    ('student1@edu.com', 'hash_100', 'Alice', 'Anderson', '+9876543210', TRUE),
    ('student2@edu.com', 'hash_101', 'Bob', 'Baker', '+9876543211', TRUE),
    ('student3@edu.com', 'hash_102', 'Carol', 'Clark', '+9876543212', TRUE),
    ('student4@edu.com', 'hash_103', 'David', 'Miller', '+9876543213', TRUE),
    ('student5@edu.com', 'hash_104', 'Emma', 'Wilson', '+9876543214', TRUE),
    ('student6@edu.com', 'hash_105', 'Frank', 'Moore', '+9876543215', TRUE),
    ('student7@edu.com', 'hash_106', 'Grace', 'Taylor', '+9876543216', TRUE),
    ('student8@edu.com', 'hash_107', 'Henry', 'Anderson', '+9876543217', TRUE),
    ('student9@edu.com', 'hash_108', 'Ivy', 'Thomas', '+9876543218', TRUE),
    ('student10@edu.com', 'hash_109', 'Jack', 'Jackson', '+9876543219', TRUE),
    ('student11@edu.com', 'hash_110', 'Kelly', 'White', '+9876543220', TRUE),
    ('student12@edu.com', 'hash_111', 'Leo', 'Harris', '+9876543221', TRUE),
    ('student13@edu.com', 'hash_112', 'Mia', 'Martin', '+9876543222', TRUE),
    ('student14@edu.com', 'hash_113', 'Noah', 'Thompson', '+9876543223', TRUE),
    ('student15@edu.com', 'hash_114', 'Olivia', 'Garcia', '+9876543224', TRUE),
    ('student16@edu.com', 'hash_115', 'Peter', 'Martinez', '+9876543225', TRUE),
    ('student17@edu.com', 'hash_116', 'Quinn', 'Robinson', '+9876543226', TRUE),
    ('student18@edu.com', 'hash_117', 'Rachel', 'Clark', '+9876543227', TRUE),
    ('student19@edu.com', 'hash_118', 'Sam', 'Lewis', '+9876543228', TRUE),
    ('student20@edu.com', 'hash_119', 'Tina', 'Lee', '+9876543229', TRUE);

-- ============================================================
-- 2. Insert Teachers
-- ============================================================
INSERT INTO teachers (user_id, employee_number, specialization, hire_date)
VALUES
    (1, 'T001', 'Computer Science', '2018-01-15'),
    (2, 'T002', 'Mathematics', '2019-03-20'),
    (3, 'T003', 'Physics', '2017-09-10'),
    (4, 'T004', 'Chemistry', '2020-01-05'),
    (5, 'T005', 'Biology', '2019-06-15');

-- ============================================================
-- 3. Insert Students
-- ============================================================
INSERT INTO students (user_id, student_number, enrollment_date)
VALUES
    (6, 'S001', '2023-09-01'),
    (7, 'S002', '2023-09-01'),
    (8, 'S003', '2023-09-01'),
    (9, 'S004', '2023-09-01'),
    (10, 'S005', '2023-09-15'),
    (11, 'S006', '2023-09-15'),
    (12, 'S007', '2023-10-01'),
    (13, 'S008', '2023-10-01'),
    (14, 'S009', '2023-10-15'),
    (15, 'S010', '2023-10-15'),
    (16, 'S011', '2024-01-10'),
    (17, 'S012', '2024-01-10'),
    (18, 'S013', '2024-01-15'),
    (19, 'S014', '2024-01-15'),
    (20, 'S015', '2024-02-01'),
    (21, 'S016', '2024-02-01'),
    (22, 'S017', '2024-02-15'),
    (23, 'S018', '2024-02-15'),
    (24, 'S019', '2024-03-01'),
    (25, 'S020', '2024-03-01');

-- ============================================================
-- 4. Insert Courses
-- ============================================================
INSERT INTO courses (title, description, instructor_id, category, difficulty_level, status, max_students)
VALUES
    ('Introduction to Python Programming', 'Learn Python basics from scratch', 1, 'Programming', 'Beginner', 'Active', 50),
    ('Advanced SQL for Data Analysis', 'Master complex queries and optimization', 1, 'Databases', 'Advanced', 'Active', 30),
    ('Calculus I: Limits and Derivatives', 'Fundamentals of single-variable calculus', 2, 'Mathematics', 'Beginner', 'Active', 40),
    ('Linear Algebra and Applications', 'Vectors, matrices, and transformations', 2, 'Mathematics', 'Intermediate', 'Active', 35),
    ('Physics: Classical Mechanics', 'Motion, forces, and energy conservation', 3, 'Physics', 'Intermediate', 'Active', 40),
    ('Organic Chemistry Fundamentals', 'Structure, bonding, and reactions', 4, 'Chemistry', 'Intermediate', 'Active', 30),
    ('Molecular Biology', 'Cells, DNA, proteins, and genetics', 5, 'Biology', 'Intermediate', 'Active', 35),
    ('Web Development with JavaScript', 'Frontend basics and DOM manipulation', 1, 'Programming', 'Beginner', 'Active', 45);

-- ============================================================
-- 5. Insert Course Enrollments
-- ============================================================
INSERT INTO course_enrollments (student_id, course_id, enrollment_date, status)
VALUES
    -- Course 1: Python Programming (10 students)
    (1, 1, '2024-01-15 10:00:00', 'In Progress'),
    (2, 1, '2024-01-15 10:30:00', 'In Progress'),
    (3, 1, '2024-01-16 09:00:00', 'In Progress'),
    (4, 1, '2024-01-16 14:00:00', 'In Progress'),
    (5, 1, '2024-01-17 11:00:00', 'In Progress'),
    (6, 1, '2024-01-18 10:00:00', 'Completed'),
    (7, 1, '2024-01-18 15:00:00', 'In Progress'),
    (8, 1, '2024-01-19 09:30:00', 'Dropped'),
    (9, 1, '2024-01-20 13:00:00', 'In Progress'),
    (10, 1, '2024-01-21 10:00:00', 'In Progress'),
    -- Course 2: Advanced SQL (8 students)
    (2, 2, '2024-02-01 10:00:00', 'In Progress'),
    (4, 2, '2024-02-01 10:30:00', 'In Progress'),
    (6, 2, '2024-02-02 09:00:00', 'In Progress'),
    (8, 2, '2024-02-02 14:00:00', 'In Progress'),
    (10, 2, '2024-02-03 11:00:00', 'Completed'),
    (12, 2, '2024-02-03 10:00:00', 'In Progress'),
    (14, 2, '2024-02-04 15:00:00', 'In Progress'),
    (16, 2, '2024-02-05 09:30:00', 'In Progress'),
    -- Course 3: Calculus (12 students)
    (1, 3, '2024-01-10 10:00:00', 'In Progress'),
    (3, 3, '2024-01-10 10:30:00', 'In Progress'),
    (5, 3, '2024-01-11 09:00:00', 'In Progress'),
    (7, 3, '2024-01-11 14:00:00', 'In Progress'),
    (9, 3, '2024-01-12 11:00:00', 'In Progress'),
    (11, 3, '2024-01-12 10:00:00', 'In Progress'),
    (13, 3, '2024-01-13 15:00:00', 'In Progress'),
    (15, 3, '2024-01-14 09:30:00', 'Completed'),
    (17, 3, '2024-01-15 13:00:00', 'In Progress'),
    (18, 3, '2024-01-15 14:00:00', 'In Progress'),
    (19, 3, '2024-01-16 10:00:00', 'In Progress'),
    (20, 3, '2024-01-16 11:00:00', 'In Progress'),
    -- Course 4: Linear Algebra (9 students)
    (2, 4, '2024-01-20 10:00:00', 'In Progress'),
    (4, 4, '2024-01-20 10:30:00', 'In Progress'),
    (6, 4, '2024-01-21 09:00:00', 'In Progress'),
    (8, 4, '2024-01-22 14:00:00', 'Dropped'),
    (10, 4, '2024-01-22 11:00:00', 'In Progress'),
    (12, 4, '2024-01-23 10:00:00', 'In Progress'),
    (14, 4, '2024-01-24 15:00:00', 'In Progress'),
    (16, 4, '2024-01-25 09:30:00', 'In Progress'),
    (18, 4, '2024-01-26 13:00:00', 'In Progress'),
    -- Course 5: Physics (10 students)
    (1, 5, '2024-02-01 10:00:00', 'In Progress'),
    (3, 5, '2024-02-01 10:30:00', 'In Progress'),
    (5, 5, '2024-02-02 09:00:00', 'In Progress'),
    (7, 5, '2024-02-02 14:00:00', 'In Progress'),
    (9, 5, '2024-02-03 11:00:00', 'In Progress'),
    (11, 5, '2024-02-04 10:00:00', 'In Progress'),
    (13, 5, '2024-02-05 15:00:00', 'In Progress'),
    (15, 5, '2024-02-06 09:30:00', 'In Progress'),
    (17, 5, '2024-02-07 13:00:00', 'In Progress'),
    (19, 5, '2024-02-08 14:00:00', 'In Progress'),
    -- Course 6: Chemistry (8 students)
    (2, 6, '2024-02-10 10:00:00', 'In Progress'),
    (4, 6, '2024-02-10 10:30:00', 'In Progress'),
    (6, 6, '2024-02-11 09:00:00', 'In Progress'),
    (8, 6, '2024-02-12 14:00:00', 'In Progress'),
    (10, 6, '2024-02-13 11:00:00', 'Completed'),
    (12, 6, '2024-02-13 10:00:00', 'In Progress'),
    (14, 6, '2024-02-14 15:00:00', 'Dropped'),
    (16, 6, '2024-02-15 09:30:00', 'In Progress'),
    -- Course 7: Biology (10 students)
    (1, 7, '2024-02-20 10:00:00', 'In Progress'),
    (3, 7, '2024-02-20 10:30:00', 'In Progress'),
    (5, 7, '2024-02-21 09:00:00', 'In Progress'),
    (7, 7, '2024-02-22 14:00:00', 'In Progress'),
    (9, 7, '2024-02-23 11:00:00', 'In Progress'),
    (11, 7, '2024-02-24 10:00:00', 'In Progress'),
    (13, 7, '2024-02-25 15:00:00', 'In Progress'),
    (15, 7, '2024-02-26 09:30:00', 'In Progress'),
    (17, 7, '2024-02-27 13:00:00', 'In Progress'),
    (20, 7, '2024-02-28 14:00:00', 'In Progress');

-- ============================================================
-- 6. Insert Modules
-- ============================================================
INSERT INTO modules (course_id, title, description, order_number)
VALUES
    -- Course 1: Python Programming
    (1, 'Module 1: Getting Started', 'Introduction to Python and setup', 1),
    (1, 'Module 2: Basic Syntax', 'Variables, data types, operators', 2),
    (1, 'Module 3: Control Flow', 'If statements, loops', 3),
    (1, 'Module 4: Functions', 'Defining and using functions', 4),
    -- Course 2: Advanced SQL
    (2, 'Module 1: Query Optimization', 'Indexes and execution plans', 1),
    (2, 'Module 2: Complex Joins', 'Advanced JOIN techniques', 2),
    (2, 'Module 3: Window Functions', 'Analytics and aggregations', 3),
    -- Course 3: Calculus
    (3, 'Module 1: Limits', 'Understanding limits and continuity', 1),
    (3, 'Module 2: Derivatives', 'Definition and applications', 2),
    (3, 'Module 3: Integration Basics', 'Antiderivatives and integrals', 3),
    -- Course 4: Linear Algebra
    (4, 'Module 1: Vectors and Matrices', 'Basic concepts', 1),
    (4, 'Module 2: Matrix Operations', 'Addition, multiplication, inversion', 2),
    (4, 'Module 3: Eigenvalues', 'Advanced topics', 3),
    -- Course 5: Physics
    (5, 'Module 1: Kinematics', 'Motion and reference frames', 1),
    (5, 'Module 2: Dynamics', 'Forces and Newton\'s laws', 2),
    (5, 'Module 3: Energy', 'Work and energy conservation', 3),
    -- Course 6: Chemistry
    (6, 'Module 1: Atomic Structure', 'Atoms and electrons', 1),
    (6, 'Module 2: Bonding', 'Chemical bonds', 2),
    (6, 'Module 3: Reactions', 'Chemical equations', 3),
    -- Course 7: Biology
    (7, 'Module 1: Cell Biology', 'Cell structure and function', 1),
    (7, 'Module 2: Genetics', 'DNA, genes, inheritance', 2),
    (7, 'Module 3: Evolution', 'Natural selection', 3),
    -- Course 8: JavaScript
    (8, 'Module 1: JavaScript Basics', 'Syntax and fundamentals', 1),
    (8, 'Module 2: DOM Manipulation', 'Working with HTML elements', 2),
    (8, 'Module 3: Events', 'Event handling and listeners', 3);

-- ============================================================
-- 7. Insert Lessons
-- ============================================================
INSERT INTO lessons (module_id, title, lesson_type, duration_minutes, order_number)
VALUES
    -- Course 1, Module 1
    (1, 'Why Python?', 'Video', 15, 1),
    (1, 'Installation and Setup', 'Video', 20, 2),
    (1, 'Your First Program', 'Interactive', 25, 3),
    -- Course 1, Module 2
    (2, 'Variables and Data Types', 'Text', 30, 1),
    (2, 'Operators', 'Video', 25, 2),
    (2, 'Type Conversion', 'Quiz', 20, 3),
    -- Course 1, Module 3
    (3, 'If Statements', 'Video', 20, 1),
    (3, 'For Loops', 'Video', 25, 2),
    (3, 'While Loops', 'Interactive', 30, 3),
    -- Course 1, Module 4
    (4, 'Defining Functions', 'Text', 25, 1),
    (4, 'Parameters and Return', 'Video', 20, 2),
    (4, 'Scope and Namespaces', 'Text', 20, 3),
    -- Course 2, Module 1
    (5, 'Understanding Indexes', 'Video', 30, 1),
    (5, 'Query Execution Plans', 'Video', 35, 2),
    (5, 'Index Strategies', 'Interactive', 40, 3),
    -- Course 2, Module 2
    (6, 'INNER JOIN', 'Text', 25, 1),
    (6, 'OUTER JOINS', 'Video', 30, 2),
    (6, 'Self Joins and Cross Joins', 'Interactive', 35, 3),
    -- Course 2, Module 3
    (7, 'ROW_NUMBER and RANK', 'Video', 30, 1),
    (7, 'Aggregate Window Functions', 'Video', 35, 2),
    -- Course 3, Module 1
    (8, 'What are Limits?', 'Video', 25, 1),
    (8, 'Limit Properties', 'Text', 20, 2),
    (8, 'Continuity', 'Video', 25, 3),
    -- Course 3, Module 2
    (9, 'The Derivative', 'Video', 30, 1),
    (9, 'Differentiation Rules', 'Text', 25, 2),
    (9, 'Applications', 'Interactive', 30, 3),
    -- Course 3, Module 3
    (10, 'Antiderivatives', 'Video', 25, 1),
    (10, 'Definite Integrals', 'Text', 30, 2),
    (10, 'Fundamental Theorem', 'Video', 25, 3),
    -- Course 4, Module 1
    (11, 'Vectors in 2D and 3D', 'Video', 30, 1),
    (11, 'Matrix Notation', 'Text', 25, 2),
    -- Course 4, Module 2
    (12, 'Matrix Addition and Subtraction', 'Text', 20, 1),
    (12, 'Matrix Multiplication', 'Video', 35, 2),
    (12, 'Matrix Inversion', 'Interactive', 40, 3),
    -- Course 4, Module 3
    (13, 'Eigenvalues and Eigenvectors', 'Video', 40, 1),
    (13, 'Diagonalization', 'Text', 30, 2),
    -- Course 5, Module 1
    (14, 'Position and Displacement', 'Video', 25, 1),
    (14, 'Velocity and Acceleration', 'Video', 30, 2),
    (14, 'Kinematic Equations', 'Interactive', 35, 3),
    -- Course 5, Module 2
    (15, 'Forces and Newton\'s First Law', 'Video', 25, 1),
    (15, 'Newton\'s Second Law', 'Video', 30, 2),
    (15, 'Newton\'s Third Law', 'Text', 20, 3),
    -- Course 5, Module 3
    (16, 'Work and Energy', 'Video', 30, 1),
    (16, 'Energy Conservation', 'Interactive', 35, 2),
    -- Course 6, Module 1
    (17, 'Atomic Structure', 'Video', 30, 1),
    (17, 'Electron Configuration', 'Text', 25, 2),
    -- Course 6, Module 2
    (18, 'Ionic Bonds', 'Video', 25, 1),
    (18, 'Covalent Bonds', 'Video', 30, 2),
    (18, 'Metallic Bonds', 'Text', 20, 3),
    -- Course 6, Module 3
    (19, 'Balancing Equations', 'Video', 25, 1),
    (19, 'Types of Reactions', 'Text', 30, 2),
    -- Course 7, Module 1
    (20, 'Cell Structure', 'Video', 30, 1),
    (20, 'Organelles and Their Functions', 'Interactive', 35, 2),
    -- Course 7, Module 2
    (21, 'DNA Structure', 'Video', 30, 1),
    (21, 'Gene Expression', 'Video', 35, 2),
    (21, 'Inheritance Patterns', 'Text', 30, 3),
    -- Course 7, Module 3
    (22, 'Natural Selection', 'Video', 30, 1),
    (22, 'Speciation', 'Text', 25, 2),
    -- Course 8, Module 1
    (23, 'JavaScript Syntax', 'Video', 25, 1),
    (23, 'Variables and Scope', 'Text', 20, 2),
    -- Course 8, Module 2
    (24, 'Selecting Elements', 'Video', 20, 1),
    (24, 'Modifying DOM', 'Interactive', 30, 2),
    -- Course 8, Module 3
    (25, 'Event Listeners', 'Video', 25, 1),
    (25, 'Event Handling', 'Interactive', 30, 2);

-- ============================================================
-- 8. Insert Quizzes
-- ============================================================
INSERT INTO quizzes (lesson_id, title, passing_score, total_questions, time_limit_minutes)
VALUES
    (3, 'Module 1 Review Quiz', 70.0, 5, 15),
    (6, 'Data Types Quiz', 70.0, 8, 20),
    (9, 'Loop Fundamentals', 75.0, 6, 15),
    (12, 'Functions Quiz', 70.0, 7, 20),
    (15, 'Query Optimization Quiz', 80.0, 10, 30),
    (18, 'JOIN Types Quiz', 75.0, 8, 25),
    (22, 'Limits and Continuity', 75.0, 6, 20),
    (25, 'Derivatives Quiz', 80.0, 8, 30),
    (27, 'Integration Basics', 75.0, 7, 25),
    (30, 'Vectors Quiz', 70.0, 6, 20),
    (33, 'Matrix Operations', 75.0, 8, 25),
    (36, 'Kinematics Quiz', 80.0, 7, 25),
    (39, 'Newton\'s Laws', 75.0, 8, 25),
    (42, 'Bonding Types Quiz', 70.0, 6, 20),
    (44, 'Cell Biology Quiz', 75.0, 8, 25),
    (48, 'Inheritance Patterns', 80.0, 8, 25),
    (50, 'Evolution Quiz', 70.0, 6, 20),
    (53, 'DOM Manipulation', 75.0, 8, 25);

-- ============================================================
-- 9. Insert Homeworks
-- ============================================================
INSERT INTO homeworks (lesson_id, title, description, max_score, due_date)
VALUES
    (3, 'HW1: Hello World Program', 'Write a program that prints your name', 100.0, '2024-01-25 23:59:59'),
    (6, 'HW2: Type Conversion', 'Convert between different data types', 100.0, '2024-02-01 23:59:59'),
    (9, 'HW3: Loop Exercises', 'Write programs using for and while loops', 100.0, '2024-02-08 23:59:59'),
    (12, 'HW4: Function Implementation', 'Create utility functions', 100.0, '2024-02-15 23:59:59'),
    (15, 'HW5: Index Design', 'Design indexes for given queries', 100.0, '2024-02-20 23:59:59'),
    (18, 'HW6: Complex Joins', 'Write queries with multiple joins', 100.0, '2024-02-27 23:59:59'),
    (22, 'HW7: Limit Proofs', 'Prove limits using epsilon-delta', 100.0, '2024-01-30 23:59:59'),
    (25, 'HW8: Derivatives', 'Calculate derivatives of functions', 100.0, '2024-02-06 23:59:59'),
    (27, 'HW9: Integration', 'Solve integration problems', 100.0, '2024-02-13 23:59:59'),
    (30, 'HW10: Vector Operations', 'Vector addition and dot products', 100.0, '2024-02-10 23:59:59'),
    (33, 'HW11: Matrix Multiplication', 'Calculate matrix products', 100.0, '2024-02-17 23:59:59'),
    (36, 'HW12: Kinematics Problems', 'Solve motion equations', 100.0, '2024-02-15 23:59:59'),
    (39, 'HW13: Force Analysis', 'Apply Newton\'s laws to scenarios', 100.0, '2024-02-22 23:59:59'),
    (42, 'HW14: Bond Types', 'Classify chemical bonds', 100.0, '2024-02-25 23:59:59'),
    (44, 'HW15: Cell Labeling', 'Label cell diagram components', 100.0, '2024-03-03 23:59:59'),
    (48, 'HW16: Genetics Problems', 'Punnett squares and predictions', 100.0, '2024-03-10 23:59:59'),
    (53, 'HW17: DOM Projects', 'Create interactive web elements', 100.0, '2024-02-28 23:59:59');

-- ============================================================
-- 10. Insert Homework Submissions
-- ============================================================
INSERT INTO homework_submissions (homework_id, student_id, submission_text, status, is_late)
VALUES
    -- HW1: Hello World (from Python course students)
    (1, 1, 'print("Hello, Alice!")', 'Graded', FALSE),
    (1, 2, 'print("Hello, Bob!")', 'Graded', FALSE),
    (1, 3, 'print("Hello, Carol!")', 'Graded', TRUE),
    (1, 4, 'name = "David"\nprint(f"Hello, {name}!")', 'Graded', FALSE),
    (1, 5, 'print("Hello, Emma!")', 'Under Review', FALSE),
    (1, 6, NULL, 'Submitted', FALSE),
    (1, 7, 'print("Hello, Grace!")', 'Graded', FALSE),
    -- HW2: Type Conversion
    (2, 1, 'int("123")\nfloat("3.14")\nstr(100)', 'Graded', FALSE),
    (2, 2, 'x = int(input())\ny = str(x * 2)', 'Graded', FALSE),
    (2, 3, 'num = float("45.67")', 'Under Review', FALSE),
    -- HW3: Loop Exercises
    (3, 1, 'for i in range(10):\n    print(i)', 'Graded', FALSE),
    (3, 2, 'for i in range(5):\n    for j in range(5):\n        print("*")', 'Graded', FALSE),
    (3, 4, 'i = 0\nwhile i < 10:\n    print(i)\n    i += 1', 'Graded', FALSE),
    -- HW4: Function Implementation
    (4, 1, 'def add(a, b):\n    return a + b', 'Graded', FALSE),
    (4, 2, 'def greet(name):\n    return f"Hello, {name}!"', 'Graded', TRUE),
    (4, 5, 'def factorial(n):\n    if n <= 1:\n        return 1\n    else:\n        return n * factorial(n-1)', 'Submitted', FALSE),
    -- HW5: Index Design
    (5, 2, 'CREATE INDEX idx_student_course ON course_enrollments(student_id, course_id)', 'Graded', FALSE),
    (5, 4, 'CREATE INDEX idx_submission_homework ON homework_submissions(homework_id)', 'Under Review', FALSE),
    (5, 6, 'CREATE INDEX idx_progress_lesson ON lesson_progress(lesson_id)', 'Graded', FALSE),
    -- HW6: Complex Joins
    (6, 2, 'SELECT s.first_name, c.title FROM students s JOIN course_enrollments ce ON s.student_id = ce.student_id JOIN courses c ON ce.course_id = c.course_id', 'Graded', FALSE),
    (6, 4, 'SELECT c.title, COUNT(ce.student_id) FROM courses c LEFT JOIN course_enrollments ce ON c.course_id = ce.course_id GROUP BY c.course_id', 'Graded', FALSE),
    -- HW7: Limit Proofs (Calculus)
    (7, 1, 'Proof using epsilon-delta definition', 'Graded', FALSE),
    (7, 3, 'Limit of (x^2 - 1)/(x - 1) as x approaches 1 equals 2', 'Under Review', FALSE),
    -- HW8: Derivatives
    (8, 1, 'd/dx(x^3 + 2x) = 3x^2 + 2', 'Graded', FALSE),
    (8, 5, 'd/dx(sin(x)) = cos(x)', 'Graded', FALSE),
    -- HW9: Integration
    (9, 1, 'Integral of x^2 dx = x^3/3 + C', 'Submitted', FALSE),
    (9, 3, 'Integral of e^x dx = e^x + C', 'Under Review', FALSE),
    -- HW10: Vector Operations
    (10, 2, 'Dot product of (1,2,3) and (4,5,6) = 32', 'Graded', FALSE),
    (10, 4, 'Cross product calculations', 'Graded', FALSE),
    -- HW11: Matrix Multiplication
    (11, 2, 'Matrix A = [[1,2],[3,4]] times B = [[5,6],[7,8]] = [[19,22],[43,50]]', 'Graded', FALSE),
    (11, 4, 'Product of 3x3 matrices', 'Under Review', FALSE),
    -- HW12: Kinematics
    (12, 1, 'Using v = u + at to solve motion problems', 'Graded', FALSE),
    (12, 3, 'Distance calculation with constant acceleration', 'Graded', FALSE),
    -- HW13: Force Analysis
    (13, 1, 'Free body diagram with forces balanced', 'Graded', FALSE),
    (13, 5, 'F = ma calculations for different masses', 'Submitted', FALSE),
    -- HW14: Bond Types
    (14, 2, 'NaCl is ionic, H2O is covalent, Cu is metallic', 'Graded', FALSE),
    (14, 4, 'Bond classification with electronegativity', 'Under Review', FALSE),
    -- HW15: Cell Labeling
    (15, 1, 'Labeled diagram with 15+ cell components', 'Graded', FALSE),
    (15, 3, 'Both plant and animal cell diagrams', 'Graded', FALSE),
    -- HW16: Genetics
    (16, 2, 'Punnett square showing 3:1 ratio', 'Graded', FALSE),
    (16, 4, 'Prediction of offspring genotypes', 'Under Review', FALSE),
    -- HW17: DOM Projects
    (17, 1, 'Interactive button that changes text color', 'Graded', FALSE),
    (17, 5, 'To-do list application with add/remove', 'Submitted', FALSE);

-- ============================================================
-- 11. Insert Homework Reviews
-- ============================================================
INSERT INTO homework_reviews (submission_id, teacher_id, score, status, review_round)
VALUES
    (1, 1, 95.0, 'Approved', 1),
    (2, 1, 90.0, 'Approved', 1),
    (3, 1, 85.0, 'Approved', 1),
    (4, 1, 98.0, 'Approved', 1),
    (7, 1, 92.0, 'Approved', 1),
    (8, 1, 88.0, 'Approved', 1),
    (9, 1, 80.0, 'Reviewed', 1),
    (11, 1, 87.0, 'Approved', 1),
    (12, 1, 91.0, 'Approved', 1),
    (14, 1, 75.0, 'Reviewed', 1),
    (15, 1, 78.0, 'Reviewed', 2),
    (17, 1, 85.0, 'Approved', 1),
    (18, 1, 82.0, 'Reviewed', 1),
    (21, 2, 90.0, 'Approved', 1),
    (22, 2, 88.0, 'Reviewed', 1),
    (24, 2, 92.0, 'Approved', 1),
    (25, 2, 95.0, 'Approved', 1),
    (27, 2, 87.0, 'Reviewed', 1),
    (28, 2, 82.0, 'Reviewed', 1),
    (30, 2, 91.0, 'Approved', 1),
    (32, 2, 89.0, 'Reviewed', 1),
    (34, 3, 88.0, 'Approved', 1),
    (35, 3, 86.0, 'Reviewed', 1),
    (37, 3, 93.0, 'Approved', 1),
    (38, 3, 81.0, 'Reviewed', 1),
    (40, 4, 85.0, 'Approved', 1),
    (41, 4, 79.0, 'Reviewed', 1),
    (43, 5, 90.0, 'Approved', 1),
    (44, 5, 88.0, 'Reviewed', 1),
    (46, 1, 92.0, 'Approved', 1),
    (47, 1, 87.0, 'Reviewed', 1);

-- ============================================================
-- 12. Insert Lesson Progress
-- ============================================================
INSERT INTO lesson_progress (student_id, lesson_id, status, started_at, completed_at, quiz_score, time_spent_minutes)
VALUES
    -- Student 1 in Course 1 (Python)
    (1, 1, 'Completed', '2024-01-15 10:00:00', '2024-01-15 10:15:00', NULL, 15),
    (1, 2, 'Completed', '2024-01-15 10:20:00', '2024-01-15 10:40:00', NULL, 20),
    (1, 3, 'Completed', '2024-01-15 10:45:00', '2024-01-15 11:10:00', 85.0, 25),
    (1, 4, 'Completed', '2024-01-16 09:00:00', '2024-01-16 09:30:00', NULL, 30),
    (1, 5, 'Completed', '2024-01-16 10:00:00', '2024-01-16 10:25:00', NULL, 25),
    (1, 6, 'Completed', '2024-01-16 14:00:00', '2024-01-16 14:20:00', 90.0, 20),
    (1, 7, 'Completed', '2024-01-17 09:00:00', '2024-01-17 09:20:00', NULL, 20),
    (1, 8, 'Completed', '2024-01-17 09:30:00', '2024-01-17 09:55:00', NULL, 25),
    (1, 9, 'Completed', '2024-01-17 10:00:00', '2024-01-17 10:30:00', 88.0, 30),
    (1, 10, 'In Progress', '2024-01-18 10:00:00', NULL, NULL, 20),
    (1, 11, 'Not Started', NULL, NULL, NULL, 0),
    (1, 12, 'Not Started', NULL, NULL, NULL, 0),
    -- Student 2 in Course 1 (Python)
    (2, 1, 'Completed', '2024-01-15 10:30:00', '2024-01-15 10:45:00', NULL, 15),
    (2, 2, 'Completed', '2024-01-15 11:00:00', '2024-01-15 11:25:00', NULL, 25),
    (2, 3, 'Completed', '2024-01-16 09:00:00', '2024-01-16 09:25:00', 92.0, 25),
    (2, 4, 'In Progress', '2024-01-16 14:00:00', NULL, NULL, 15),
    (2, 5, 'Not Started', NULL, NULL, NULL, 0),
    -- Student 3 in Course 1 (Python)
    (3, 1, 'Completed', '2024-01-16 09:00:00', '2024-01-16 09:15:00', NULL, 15),
    (3, 2, 'In Progress', '2024-01-16 09:30:00', NULL, NULL, 20),
    (3, 3, 'Not Started', NULL, NULL, NULL, 0),
    -- Student 2 in Course 2 (SQL)
    (2, 13, 'Completed', '2024-02-01 10:00:00', '2024-02-01 10:30:00', NULL, 30),
    (2, 14, 'Completed', '2024-02-01 10:45:00', '2024-02-01 11:20:00', NULL, 35),
    (2, 15, 'Completed', '2024-02-02 09:00:00', '2024-02-02 09:40:00', 78.0, 40),
    (2, 16, 'In Progress', '2024-02-02 10:00:00', NULL, NULL, 20),
    -- Additional progress entries for other students
    (4, 1, 'Completed', '2024-01-16 14:00:00', '2024-01-16 14:15:00', NULL, 15),
    (4, 2, 'Completed', '2024-01-16 14:30:00', '2024-01-16 14:55:00', NULL, 25),
    (4, 3, 'In Progress', '2024-01-16 15:00:00', NULL, NULL, 10),
    (5, 1, 'Not Started', NULL, NULL, NULL, 0),
    (6, 1, 'Completed', '2024-01-18 10:00:00', '2024-01-18 10:15:00', NULL, 15),
    (6, 2, 'Completed', '2024-01-18 10:30:00', '2024-01-18 10:55:00', NULL, 25),
    (6, 3, 'Completed', '2024-01-18 11:00:00', '2024-01-18 11:25:00', 95.0, 25),
    (6, 4, 'Completed', '2024-01-18 14:00:00', '2024-01-18 14:25:00', NULL, 25),
    (6, 5, 'Completed', '2024-01-19 09:00:00', '2024-01-19 09:25:00', NULL, 25),
    (6, 6, 'Completed', '2024-01-19 09:30:00', '2024-01-19 09:50:00', 98.0, 20),
    (6, 7, 'Completed', '2024-01-19 10:00:00', '2024-01-19 10:20:00', NULL, 20),
    (6, 8, 'Completed', '2024-01-19 10:30:00', '2024-01-19 10:55:00', NULL, 25),
    (6, 9, 'Completed', '2024-01-19 11:00:00', '2024-01-19 11:30:00', 96.0, 30),
    (6, 10, 'Completed', '2024-01-20 09:00:00', '2024-01-20 09:25:00', NULL, 25),
    (6, 11, 'Completed', '2024-01-20 09:30:00', '2024-01-20 09:50:00', NULL, 20),
    (6, 12, 'Completed', '2024-01-20 10:00:00', '2024-01-20 10:25:00', 94.0, 25);

-- ============================================================
-- 13. Insert Review Comments
-- ============================================================
INSERT INTO review_comments (review_id, commenter_id, comment_text, comment_type)
VALUES
    (1, 1, 'Great job! Your code is clean and well-structured.', 'General'),
    (2, 1, 'Good implementation. Consider using more descriptive variable names.', 'General'),
    (3, 1, 'Acceptable work, but submitted late. Please manage time better next time.', 'General'),
    (4, 1, 'Excellent! This is exactly how it should be done.', 'General'),
    (5, 1, 'Nice try! Your approach is correct but has some syntax errors.', 'Specific'),
    (6, 1, 'Good understanding of the material. Keep it up!', 'General'),
    (9, 1, 'You understand the concept, but need to refine your implementation.', 'General'),
    (10, 1, 'Submitted late, but shows good effort and understanding.', 'General'),
    (13, 1, 'The recursive solution is elegant. Well done!', 'General'),
    (14, 1, 'Missing some edge cases. Revise and resubmit.', 'Specific'),
    (15, 2, 'Correct approach. This demonstrates clear understanding.', 'General'),
    (16, 2, 'Good try. Check your understanding of epsilon-delta proofs.', 'Specific'),
    (18, 2, 'Spot on! Your derivative calculations are correct.', 'General'),
    (19, 2, 'Check your integration by parts. There\'s an error in step 3.', 'Specific'),
    (23, 1, 'Well-written code. Consider performance implications.', 'General'),
    (24, 1, 'The solution works, but could be more efficient.', 'Question'),
    (26, 3, 'Your physics reasoning is sound. Good job!', 'General'),
    (27, 3, 'Correct application of kinematics. Excellent work.', 'General'),
    (29, 4, 'Good classification. Just double-check compound XYZ.', 'Specific'),
    (30, 5, 'Comprehensive and accurate. Well done!', 'General');

-- ============================================================
-- Commit transaction
-- ============================================================
COMMIT;

-- End of test data script
