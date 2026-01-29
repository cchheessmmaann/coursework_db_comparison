/*
Back4app Cloud Code Functions
Online Education Platform - Equivalent Business Logic

These functions implement the same business logic as SQL queries
but using Back4app's Cloud Code (Node.js) environment.
*/

const Parse = require('parse/node');

// ============================================================
// CLOUD FUNCTION 1: Get Students Missing Homeworks
// ============================================================
Parse.Cloud.define('getStudentsMissingHomeworks', async (request) => {
  const minMissing = request.params.minMissing || 2;
  
  try {
    // Query all course enrollments with student info
    const enrollments = await new Parse.Query('CourseEnrollment')
      .include('student', 'course')
      .limit(1000)
      .find({ useMasterKey: true });
    
    const results = [];
    
    for (const enrollment of enrollments) {
      const studentId = enrollment.get('student').id;
      const courseId = enrollment.get('course').id;
      
      // Get homeworks for this course
      const homeworks = await new Parse.Query('Homework')
        .where('course', '==', courseId)
        .select('objectId')
        .find({ useMasterKey: true });
      
      const homeworkIds = homeworks.map(h => h.id);
      
      // Get submissions for this student
      const submissions = await new Parse.Query('HomeworkSubmission')
        .where('homework', 'in', homeworkIds)
        .where('student', '==', studentId)
        .select('objectId')
        .find({ useMasterKey: true });
      
      const missing = homeworkIds.length - submissions.length;
      
      if (missing > minMissing) {
        results.push({
          studentId: studentId,
          studentName: enrollment.get('student').get('name'),
          courseId: courseId,
          courseTitle: enrollment.get('course').get('title'),
          totalHomeworks: homeworkIds.length,
          submittedHomeworks: submissions.length,
          missingSubmissions: missing,
          submissionRate: ((submissions.length / homeworkIds.length) * 100).toFixed(2)
        });
      }
    }
    
    return results.sort((a, b) => b.missingSubmissions - a.missingSubmissions);
  } catch (error) {
    throw new Error('Failed to get students with missing homeworks: ' + error.message);
  }
});

// ============================================================
// CLOUD FUNCTION 2: Get Course Completion Rate
// ============================================================
Parse.Cloud.define('getCourseCompletion', async (request) => {
  try {
    // Query all course enrollments
    const enrollments = await new Parse.Query('CourseEnrollment')
      .include('student', 'course')
      .limit(1000)
      .find({ useMasterKey: true });
    
    const results = [];
    
    for (const enrollment of enrollments) {
      const studentId = enrollment.get('student').id;
      const courseId = enrollment.get('course').id;
      
      // Get all lessons in course
      const modules = await new Parse.Query('Module')
        .where('course', '==', courseId)
        .find({ useMasterKey: true });
      
      let totalLessons = 0;
      let completedLessons = 0;
      let totalTime = 0;
      
      for (const module of modules) {
        const lessons = await new Parse.Query('Lesson')
          .where('module', '==', module.id)
          .find({ useMasterKey: true });
        
        totalLessons += lessons.length;
        
        for (const lesson of lessons) {
          const progress = await new Parse.Query('LessonProgress')
            .where('lesson', '==', lesson.id)
            .where('student', '==', studentId)
            .first({ useMasterKey: true });
          
          if (progress && progress.get('status') === 'Completed') {
            completedLessons++;
          }
          
          if (progress && progress.get('timeSpentMinutes')) {
            totalTime += progress.get('timeSpentMinutes');
          }
        }
      }
      
      if (totalLessons > 0) {
        results.push({
          enrollmentId: enrollment.id,
          studentId: studentId,
          studentName: enrollment.get('student').get('name'),
          courseId: courseId,
          courseTitle: enrollment.get('course').get('title'),
          difficultyLevel: enrollment.get('course').get('difficultyLevel'),
          totalLessons: totalLessons,
          completedLessons: completedLessons,
          completionPercentage: ((completedLessons / totalLessons) * 100).toFixed(2),
          avgTimePerLesson: (totalTime / totalLessons).toFixed(2),
          enrollmentStatus: enrollment.get('status')
        });
      }
    }
    
    return results.sort((a, b) => 
      b.completionPercentage - a.completionPercentage || 
      b.studentId.localeCompare(a.studentId)
    ).slice(0, 20);
  } catch (error) {
    throw new Error('Failed to get course completion: ' + error.message);
  }
});

// ============================================================
// CLOUD FUNCTION 3: Homework Review Cycle Analysis
// ============================================================
Parse.Cloud.define('getHomeworkReviewStats', async (request) => {
  try {
    const homeworks = await new Parse.Query('Homework')
      .include('lesson', 'course')
      .limit(1000)
      .find({ useMasterKey: true });
    
    const results = [];
    
    for (const homework of homeworks) {
      // Get submissions for this homework
      const submissions = await new Parse.Query('HomeworkSubmission')
        .where('homework', '==', homework.id)
        .find({ useMasterKey: true });
      
      let gradedCount = 0;
      let lateCount = 0;
      let totalScore = 0;
      let scoreCount = 0;
      
      for (const submission of submissions) {
        // Get reviews for this submission
        const reviews = await new Parse.Query('HomeworkReview')
          .where('submission', '==', submission.id)
          .find({ useMasterKey: true });
        
        if (reviews.length > 0 && reviews[0].get('status') === 'Approved') {
          gradedCount++;
        }
        
        if (submission.get('isLate')) {
          lateCount++;
        }
        
        if (reviews.length > 0 && reviews[0].get('score')) {
          totalScore += reviews[0].get('score');
          scoreCount++;
        }
      }
      
      results.push({
        homeworkId: homework.id,
        homeworkTitle: homework.get('title'),
        courseTitle: homework.get('course').get('title'),
        totalSubmissions: submissions.length,
        gradedCount: gradedCount,
        lateSubmissions: lateCount,
        avgScore: scoreCount > 0 ? (totalScore / scoreCount).toFixed(2) : null,
        gradingCompletionRate: submissions.length > 0 ? 
          ((gradedCount / submissions.length) * 100).toFixed(2) : 0
      });
    }
    
    return results;
  } catch (error) {
    throw new Error('Failed to get homework review stats: ' + error.message);
  }
});

// ============================================================
// CLOUD FUNCTION 4: Teacher Workload Analysis
// ============================================================
Parse.Cloud.define('getTeacherWorkload', async (request) => {
  try {
    const teachers = await new Parse.Query('Teacher')
      .include('user')
      .limit(1000)
      .find({ useMasterKey: true });
    
    const results = [];
    
    for (const teacher of teachers) {
      const teacherId = teacher.id;
      
      // Get courses taught
      const courses = await new Parse.Query('Course')
        .where('instructor', '==', teacher)
        .find({ useMasterKey: true });
      
      let totalStudents = new Set();
      let pendingReviews = 0;
      let totalScore = 0;
      let scoreCount = 0;
      
      for (const course of courses) {
        // Get enrollments
        const enrollments = await new Parse.Query('CourseEnrollment')
          .where('course', '==', course.id)
          .find({ useMasterKey: true });
        
        enrollments.forEach(e => totalStudents.add(e.get('student').id));
        
        // Get homework reviews for this course
        const modules = await new Parse.Query('Module')
          .where('course', '==', course.id)
          .find({ useMasterKey: true });
        
        for (const module of modules) {
          const lessons = await new Parse.Query('Lesson')
            .where('module', '==', module.id)
            .find({ useMasterKey: true });
          
          for (const lesson of lessons) {
            const homeworks = await new Parse.Query('Homework')
              .where('lesson', '==', lesson.id)
              .find({ useMasterKey: true });
            
            for (const homework of homeworks) {
              const submissions = await new Parse.Query('HomeworkSubmission')
                .where('homework', '==', homework.id)
                .find({ useMasterKey: true });
              
              for (const submission of submissions) {
                const reviews = await new Parse.Query('HomeworkReview')
                  .where('submission', '==', submission.id)
                  .where('teacher', '==', teacher)
                  .find({ useMasterKey: true });
                
                for (const review of reviews) {
                  if (review.get('status') !== 'Approved') {
                    pendingReviews++;
                  }
                  if (review.get('score')) {
                    totalScore += review.get('score');
                    scoreCount++;
                  }
                }
              }
            }
          }
        }
      }
      
      results.push({
        teacherId: teacherId,
        teacherName: teacher.get('user').get('name'),
        specialization: teacher.get('specialization'),
        coursesTaught: courses.length,
        totalStudents: totalStudents.size,
        pendingReviews: pendingReviews,
        avgGradeGiven: scoreCount > 0 ? (totalScore / scoreCount).toFixed(2) : null
      });
    }
    
    return results.sort((a, b) => b.coursesTaught - a.coursesTaught);
  } catch (error) {
    throw new Error('Failed to get teacher workload: ' + error.message);
  }
});

// ============================================================
// CLOUD FUNCTION 5: Course Analytics
// ============================================================
Parse.Cloud.define('getCourseAnalytics', async (request) => {
  try {
    const courses = await new Parse.Query('Course')
      .include('instructor')
      .limit(1000)
      .find({ useMasterKey: true });
    
    const results = [];
    
    for (const course of courses) {
      const courseId = course.id;
      
      // Get enrollments
      const enrollments = await new Parse.Query('CourseEnrollment')
        .where('course', '==', courseId)
        .find({ useMasterKey: true });
      
      let completedCount = 0;
      let totalGrade = 0;
      let gradeCount = 0;
      
      for (const enrollment of enrollments) {
        if (enrollment.get('status') === 'Completed') {
          completedCount++;
        }
        if (enrollment.get('grade')) {
          totalGrade += enrollment.get('grade');
          gradeCount++;
        }
      }
      
      // Get modules and lessons
      const modules = await new Parse.Query('Module')
        .where('course', '==', courseId)
        .find({ useMasterKey: true });
      
      let totalLessons = 0;
      for (const module of modules) {
        const lessons = await new Parse.Query('Lesson')
          .where('module', '==', module.id)
          .find({ useMasterKey: true });
        totalLessons += lessons.length;
      }
      
      results.push({
        courseId: courseId,
        courseTitle: course.get('title'),
        instructorName: course.get('instructor').get('name'),
        category: course.get('category'),
        difficultyLevel: course.get('difficultyLevel'),
        enrolledStudents: enrollments.length,
        completed: completedCount,
        numModules: modules.length,
        numLessons: totalLessons,
        avgStudentGrade: gradeCount > 0 ? (totalGrade / gradeCount).toFixed(2) : null,
        completionRate: enrollments.length > 0 ? 
          ((completedCount / enrollments.length) * 100).toFixed(2) : 0
      });
    }
    
    return results.sort((a, b) => b.enrolledStudents - a.enrolledStudents);
  } catch (error) {
    throw new Error('Failed to get course analytics: ' + error.message);
  }
});

// ============================================================
// HELPER FUNCTION: Initialize Parse
// ============================================================
Parse.Cloud.beforeSave('ClassName', async (request) => {
  // Update timestamps
  const object = request.object;
  if (!object.createdAt) {
    object.set('createdAt', new Date());
  }
  object.set('updatedAt', new Date());
});
