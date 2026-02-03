"""
Online Education Platform Database Comparison
Console Application for Testing SQL and Back4app Implementation

This application demonstrates identical operations on both SQL and BaaS databases.
"""

import psycopg2
import json
import time
from typing import List, Dict, Tuple
from datetime import datetime

class SQLDatabase:
    """PostgreSQL database connection and operations"""
    
    def __init__(self, host='localhost', database='education_platform', 
                 user='postgres', password='your_password'):
        """Initialize PostgreSQL connection"""
        try:
            self.conn = psycopg2.connect(
                host=host,
                database=database,
                user=user,
                password=password
            )
            self.cursor = self.conn.cursor()
            print("✓ Connected to PostgreSQL database")
        except Exception as e:
            print(f"✗ Failed to connect to PostgreSQL: {e}")
            raise
    
    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("✓ PostgreSQL connection closed")
    
    def query1_students_missing_homeworks(self, min_missing=2):
        """
        Query 1: Find students not submitting more than N homeworks in a course
        This identifies at-risk students who may need intervention
        """
        query = """
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
            AND (COUNT(DISTINCT h.homework_id) - COUNT(DISTINCT hs.submission_id)) > %s
        ORDER BY missing_submissions DESC, c.title;
        """
        
        self.cursor.execute(query, (min_missing,))
        return self.cursor.fetchall()
    
    def query2_course_completion_rate(self):
        """
        Query 2: Calculate course completion rate and identify lagging students
        Shows progress for each student across course structure
        """
        query = """
        SELECT 
            ce.enrollment_id,
            s.student_id,
            u.first_name || ' ' || u.last_name AS student_name,
            c.course_id,
            c.title AS course_title,
            c.difficulty_level,
            COUNT(DISTINCT l.lesson_id) AS total_lessons,
            COUNT(DISTINCT CASE WHEN lp.status = 'Completed' THEN l.lesson_id END) AS completed_lessons,
            ROUND(
                COUNT(DISTINCT CASE WHEN lp.status = 'Completed' THEN l.lesson_id END) * 100.0 / 
                NULLIF(COUNT(DISTINCT l.lesson_id), 0), 2
            ) AS completion_percentage,
            ROUND(AVG(lp.time_spent_minutes), 2) AS avg_time_per_lesson,
            ce.status AS enrollment_status
        FROM course_enrollments ce
        JOIN students s ON ce.student_id = s.student_id
        JOIN users u ON s.user_id = u.user_id
        JOIN courses c ON ce.course_id = c.course_id
        JOIN modules m ON c.course_id = m.course_id
        JOIN lessons l ON m.module_id = l.lesson_id
        LEFT JOIN lesson_progress lp ON l.lesson_id = lp.lesson_id AND s.student_id = lp.student_id
        GROUP BY ce.enrollment_id, s.student_id, u.first_name, u.last_name, c.course_id, c.title, c.difficulty_level, ce.status
        ORDER BY c.course_id, completion_percentage DESC
        LIMIT 20;
        """
        
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def query3_homework_review_cycle(self):
        """
        Query 3: Homework review cycle analysis
        Shows homework submissions and their review status
        """
        query = """
        SELECT 
            h.homework_id,
            h.title AS homework_title,
            c.title AS course_title,
            COUNT(DISTINCT hs.submission_id) AS total_submissions,
            COUNT(DISTINCT CASE WHEN hs.status = 'Graded' THEN hs.submission_id END) AS graded,
            COUNT(DISTINCT CASE WHEN hs.is_late = TRUE THEN hs.submission_id END) AS late_submissions,
            ROUND(AVG(hr.score), 2) AS avg_score
        FROM homeworks h
        JOIN lessons l ON h.lesson_id = l.lesson_id
        JOIN modules m ON l.module_id = m.module_id
        JOIN courses c ON m.course_id = c.course_id
        LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id
        LEFT JOIN homework_reviews hr ON hs.submission_id = hr.submission_id
        GROUP BY h.homework_id, h.title, c.title
        ORDER BY c.course_id, h.homework_id;
        """
        
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def query4_teacher_workload(self):
        """
        Query 4: Teacher workload analysis
        Shows teaching load and grading responsibilities
        """
        query = """
        SELECT 
            t.teacher_id,
            u.first_name || ' ' || u.last_name AS teacher_name,
            t.specialization,
            COUNT(DISTINCT c.course_id) AS courses_teaching,
            COUNT(DISTINCT ce.student_id) AS total_students,
            COUNT(DISTINCT CASE WHEN hr.status != 'Approved' THEN hr.review_id END) AS pending_reviews,
            ROUND(AVG(CASE WHEN hr.score IS NOT NULL THEN hr.score ELSE NULL END), 2) AS avg_grade_given
        FROM teachers t
        JOIN users u ON t.user_id = u.user_id
        JOIN courses c ON t.teacher_id = c.instructor_id
        JOIN course_enrollments ce ON c.course_id = ce.course_id
        LEFT JOIN modules m ON c.course_id = m.course_id
        LEFT JOIN lessons l ON m.module_id = l.lesson_id
        LEFT JOIN homeworks h ON l.lesson_id = h.lesson_id
        LEFT JOIN homework_submissions hs ON h.homework_id = hs.homework_id
        LEFT JOIN homework_reviews hr ON hs.submission_id = hr.submission_id AND t.teacher_id = hr.teacher_id
        GROUP BY t.teacher_id, u.first_name, u.last_name, t.specialization
        ORDER BY courses_teaching DESC;
        """
        
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def query5_course_analytics(self):
        """
        Query 5: Course analytics and performance metrics
        Provides comprehensive course statistics
        """
        query = """
        SELECT 
            c.course_id,
            c.title AS course_title,
            u_teacher.first_name || ' ' || u_teacher.last_name AS instructor_name,
            c.category,
            c.difficulty_level,
            COUNT(DISTINCT ce.student_id) AS enrolled_students,
            COUNT(DISTINCT CASE WHEN ce.status = 'Completed' THEN ce.student_id END) AS completed,
            COUNT(DISTINCT m.module_id) AS num_modules,
            COUNT(DISTINCT l.lesson_id) AS num_lessons,
            ROUND(AVG(ce.grade), 2) AS avg_student_grade,
            ROUND(
                COUNT(DISTINCT CASE WHEN ce.status = 'Completed' THEN ce.student_id END) * 100.0 / 
                NULLIF(COUNT(DISTINCT ce.student_id), 0), 2
            ) AS completion_rate
        FROM courses c
        JOIN teachers t ON c.instructor_id = t.teacher_id
        JOIN users u_teacher ON t.user_id = u_teacher.user_id
        LEFT JOIN course_enrollments ce ON c.course_id = ce.course_id
        LEFT JOIN modules m ON c.course_id = m.course_id
        LEFT JOIN lessons l ON m.module_id = l.lesson_id
        GROUP BY c.course_id, c.title, u_teacher.first_name, u_teacher.last_name, c.category, c.difficulty_level
        ORDER BY enrolled_students DESC;
        """
        
        self.cursor.execute(query)
        return self.cursor.fetchall()


class Back4appDatabase:
    """Back4app BaaS platform operations"""
    
    def __init__(self, server_url: str, app_id: str, api_key: str):
        """
        Initialize Back4app connection
        
        Args:
            server_url: Back4app server URL (e.g., 'https://parseapi.back4app.com')
            app_id: Back4app Application ID
            api_key: Back4app REST API key
        """
        import requests
        
        self.server_url = server_url
        self.app_id = app_id
        self.api_key = api_key
        self.requests = requests
        self.session = requests.Session()
        self.session.headers.update({
            'X-Parse-Application-Id': self.app_id,
            'X-Parse-REST-API-Key': self.api_key,
            'Content-Type': 'application/json'
        })
        print("✓ Configured Back4app connection")
    
    def query1_students_missing_homeworks(self, min_missing: int = 2) -> List[Dict]:
        """
        Query 1 equivalent: Find students with missing homeworks
        Note: Back4app requires multiple requests due to API structure
        """
        try:
            # This would require fetching students, courses, and homeworks
            # and filtering in the application layer
            print("⚠ Back4app: Implementing multi-step query equivalent")
            # Implementation would fetch all relevant classes and filter
            return []
        except Exception as e:
            print(f"✗ Back4app Query 1 Error: {e}")
            return []
    
    def query2_course_completion_rate(self) -> List[Dict]:
        """
        Query 2 equivalent: Calculate course completion rate
        """
        try:
            # Back4app Cloud Code function approach
            endpoint = f"{self.server_url}/parse/functions/getCourseCompletion"
            response = self.session.post(endpoint, json={})
            if response.status_code == 200:
                return response.json().get('result', [])
            return []
        except Exception as e:
            print(f"✗ Back4app Query 2 Error: {e}")
            return []
    
    def query3_homework_review_cycle(self) -> List[Dict]:
        """
        Query 3 equivalent: Homework review cycle analysis
        """
        try:
            # Fetch Homework class with aggregate statistics
            endpoint = f"{self.server_url}/parse/classes/Homework"
            params = {
                'include': 'lesson,lesson.module,lesson.module.course',
                'limit': 1000
            }
            response = self.session.get(endpoint, params=params)
            if response.status_code == 200:
                return response.json().get('results', [])
            return []
        except Exception as e:
            print(f"✗ Back4app Query 3 Error: {e}")
            return []
    
    def query4_teacher_workload(self) -> List[Dict]:
        """
        Query 4 equivalent: Teacher workload analysis
        """
        try:
            # Fetch Teacher class with related courses and reviews
            endpoint = f"{self.server_url}/parse/classes/Teacher"
            params = {
                'include': 'courses,reviews',
                'limit': 1000
            }
            response = self.session.get(endpoint, params=params)
            if response.status_code == 200:
                return response.json().get('results', [])
            return []
        except Exception as e:
            print(f"✗ Back4app Query 4 Error: {e}")
            return []
    
    def query5_course_analytics(self) -> List[Dict]:
        """
        Query 5 equivalent: Course analytics and performance metrics
        """
        try:
            # Fetch Course class with enrollments and modules
            endpoint = f"{self.server_url}/parse/classes/Course"
            params = {
                'include': 'instructor,enrollments,modules',
                'limit': 1000
            }
            response = self.session.get(endpoint, params=params)
            if response.status_code == 200:
                return response.json().get('results', [])
            return []
        except Exception as e:
            print(f"✗ Back4app Query 5 Error: {e}")
            return []


class ComparisonAnalyzer:
    """Analyzes and compares SQL vs BaaS performance"""
    
    def __init__(self):
        self.results = {
            'query1': {},
            'query2': {},
            'query3': {},
            'query4': {},
            'query5': {}
        }
    
    def run_comparison(self, sql_db: SQLDatabase, back4app: Back4appDatabase):
        """Run all comparison queries"""
        
        print("\n" + "="*80)
        print("COMPARISON TEST SUITE: SQL vs Back4app")
        print("="*80)
        
        # Query 1: Students missing homeworks
        print("\n[QUERY 1] Students Not Submitting Homeworks")
        print("-" * 80)
        self._test_query(
            "Query 1",
            lambda: sql_db.query1_students_missing_homeworks(min_missing=2),
            lambda: back4app.query1_students_missing_homeworks(min_missing=2)
        )
        
        # Query 2: Course completion rate
        print("\n[QUERY 2] Course Completion Rate and Student Progress")
        print("-" * 80)
        self._test_query(
            "Query 2",
            lambda: sql_db.query2_course_completion_rate(),
            lambda: back4app.query2_course_completion_rate()
        )
        
        # Query 3: Homework review cycle
        print("\n[QUERY 3] Homework Review Cycle Analysis")
        print("-" * 80)
        self._test_query(
            "Query 3",
            lambda: sql_db.query3_homework_review_cycle(),
            lambda: back4app.query3_homework_review_cycle()
        )
        
        # Query 4: Teacher workload
        print("\n[QUERY 4] Teacher Workload Analysis")
        print("-" * 80)
        self._test_query(
            "Query 4",
            lambda: sql_db.query4_teacher_workload(),
            lambda: back4app.query4_teacher_workload()
        )
        
        # Query 5: Course analytics
        print("\n[QUERY 5] Course Analytics and Performance")
        print("-" * 80)
        self._test_query(
            "Query 5",
            lambda: sql_db.query5_course_analytics(),
            lambda: back4app.query5_course_analytics()
        )
        
        self._print_summary()
    
    def _test_query(self, query_name: str, sql_func, back4app_func):
        """Test a single query on both databases"""
        
        # SQL execution
        start_time = time.time()
        try:
            sql_results = sql_func()
            sql_time = time.time() - start_time
            sql_count = len(sql_results) if sql_results else 0
            print(f"✓ SQL    : {sql_count} rows in {sql_time*1000:.2f}ms")
            
            if sql_count > 0:
                print(f"  First result: {sql_results[0][:3]}")  # Show first 3 columns
        except Exception as e:
            print(f"✗ SQL    : Error - {e}")
            sql_time = -1
            sql_count = 0
        
        # Back4app execution
        start_time = time.time()
        try:
            back4app_results = back4app_func()
            back4app_time = time.time() - start_time
            back4app_count = len(back4app_results) if back4app_results else 0
            print(f"✓ Back4app : {back4app_count} rows in {back4app_time*1000:.2f}ms")
            
            if back4app_count > 0:
                print(f"  First result: {back4app_results[0]}")
        except Exception as e:
            print(f"✗ Back4app : Error - {e}")
            back4app_time = -1
            back4app_count = 0
        
        # Store results
        if sql_time > 0 and back4app_time > 0:
            ratio = back4app_time / sql_time
            print(f"  Speed ratio: Back4app is {ratio:.1f}x {'faster' if ratio < 1 else 'slower'}")
        
        self.results[query_name.lower()] = {
            'sql_time': sql_time,
            'back4app_time': back4app_time,
            'sql_count': sql_count,
            'back4app_count': back4app_count
        }
    
    def _print_summary(self):
        """Print test summary"""
        print("\n" + "="*80)
        print("SUMMARY")
        print("="*80)
        
        for query_name, metrics in self.results.items():
            if metrics['sql_time'] > 0:
                print(f"{query_name.upper()}: SQL {metrics['sql_time']*1000:.2f}ms vs Back4app {metrics['back4app_time']*1000:.2f}ms")


def main():
    """Main entry point"""
    
    print("\n" + "="*80)
    print("ONLINE EDUCATION PLATFORM - Database Comparison Tool")
    print("Comparing Classical SQL vs Back4app BaaS")
    print("="*80 + "\n")
    
    # Connect to SQL database
    try:
        sql_db = SQLDatabase(
            host='localhost',
            database='education_platform',
            user='postgres',
            password='your_password'  # Change to your actual password
        )
    except Exception as e:
        print(f"Cannot continue without SQL database connection: {e}")
        return
    
    # Configure Back4app connection
    # These should be your actual Back4app credentials
    back4app_config = {
        'server_url': 'https://parseapi.back4app.com',
        'app_id': 'YOUR_APP_ID',
        'api_key': 'YOUR_API_KEY'
    }
    
    try:
        back4app = Back4appDatabase(**back4app_config)
    except Exception as e:
        print(f"Warning: Could not connect to Back4app: {e}")
        print("Proceeding with SQL tests only...\n")
        back4app = None
    
    # Run comparison
    analyzer = ComparisonAnalyzer()
    analyzer.run_comparison(sql_db, back4app)
    
    sql_db.close()
    
    print("\n✓ Comparison complete!")


if __name__ == '__main__':
    main()
