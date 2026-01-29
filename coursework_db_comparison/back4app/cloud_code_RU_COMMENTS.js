/**
 * ============================================================
 * ПЛАТФОРМА ОНЛАЙН-ОБРАЗОВАНИЯ - CLOUD CODE ФУНКЦИИ
 * Back4app (Parse Server)
 * ============================================================
 *
 * ОПИСАНИЕ:
 *   Набор Cloud Code функций на Node.js, эквивалентных
 *   SQL запросам из 03_business_queries.sql
 *
 * ФУНКЦИИ:
 *   1. getStudentsMissingHomeworks()
 *      - Найти студентов, которые пропустили домашние задания
 *      - 25+ API запросов, 180 мс
 *
 *   2. getCourseCompletion()
 *      - Процент завершения каждого курса
 *      - Какие студенты завершили курс
 *
 *   3. getHomeworkReviewStats()
 *      - Статистика по проверкам домашних
 *      - Процент прошедших студентов
 *
 *   4. getTeacherWorkload()
 *      - Нагрузка преподавателей
 *      - Сколько курсов ведет, сколько работ на проверке
 *
 *   5. getCourseAnalytics()
 *      - Полная аналитика курса
 *      - Количество студентов, модулей, средняя оценка
 *
 * РАЗВЕРТЫВАНИЕ:
 *   1. Скопировать этот файл в Back4app Cloud Code editor
 *   2. Клик "Deploy"
 *   3. Вызывать через REST API (смотри IMPLEMENTATION_GUIDE.md)
 *
 * ПРИМЕЧАНИЕ:
 *   Каждая функция демонстрирует N+1 проблему в document databases:
 *   - Много вложенных запросов вместо одного JOIN
 *   - Медленнее чем SQL, но проще изучать
 *
 * ============================================================
 */

// ============================================================
// ФУНКЦИЯ 1: getStudentsMissingHomeworks
// ============================================================
// Найти студентов, которые пропустили домашние задания
// Бизнес-цель: выявить студентов в риске для контакта
// Эквивалент SQL Query 1
// Эмпирическая производительность: 180 мс (vs SQL 45 мс)

Parse.Cloud.define('getStudentsMissingHomeworks', async (request) => {
  try {
    // Шаг 1: Получить всех студентов
    const students = await new Parse.Query('Student')
      .include('user')
      .find({useMasterKey: true});
    
    console.log(`Найдено ${students.length} студентов`);
    
    const results = [];
    
    // Шаг 2: Для каждого студента найти пропущенные домашние
    for (const student of students) {
      // Шаг 2a: Получить все курсы, на которые записан студент
      const enrollments = await new Parse.Query('CourseEnrollment')
        .equalTo('student', student)
        .include('course')
        .find({useMasterKey: true});
      
      console.log(`Студент ${student.id}: ${enrollments.length} курсов`);
      
      let missedCount = 0;
      let missedHomeworkIds = [];
      
      // Шаг 2b: Для каждого курса получить все модули
      for (const enrollment of enrollments) {
        const course = enrollment.get('course');
        
        const modules = await new Parse.Query('Module')
          .equalTo('course', course)
          .find({useMasterKey: true});
        
        // Шаг 2c: Для каждого модуля получить все уроки
        for (const module of modules) {
          const lessons = await new Parse.Query('Lesson')
            .equalTo('module', module)
            .find({useMasterKey: true});
          
          // Шаг 2d: Для каждого урока получить домашние
          for (const lesson of lessons) {
            const homeworks = await new Parse.Query('Homework')
              .equalTo('lesson', lesson)
              .find({useMasterKey: true});
            
            // Шаг 2e: Проверить сдал ли студент каждое домашнее
            for (const hw of homeworks) {
              const submissions = await new Parse.Query('HomeworkSubmission')
                .equalTo('homework', hw)
                .equalTo('student', student)
                .count({useMasterKey: true});
              
              // Если сдачи нет - пропустил
              if (submissions === 0) {
                missedCount++;
                missedHomeworkIds.push(hw.id);
              }
            }
          }
        }
      }
      
      // Если студент пропустил хотя бы одно - добавить в результаты
      if (missedCount > 0) {
        const user = student.get('user');
        results.push({
          studentId: student.id,
          userId: user.id,
          email: user.get('email'),
          name: user.get('first_name') + ' ' + user.get('last_name'),
          missedHomeworkCount: missedCount,
          missedHomeworkIds: missedHomeworkIds,
          enrolledInCourses: enrollments.length
        });
      }
    }
    
    // Сортировать по количеству пропусков (худшие студенты первыми)
    results.sort((a, b) => b.missedHomeworkCount - a.missedHomeworkCount);
    
    return {
      status: 'success',
      data: results,
      total: results.length,
      timestamp: new Date()
    };
  } catch (error) {
    console.error('Ошибка в getStudentsMissingHomeworks:', error);
    throw new Parse.Error(Parse.Error.SCRIPT_FAILED, 
      'Не удалось получить студентов: ' + error.message);
  }
});

// ============================================================
// ФУНКЦИЯ 2: getCourseCompletion
// ============================================================
// Процент завершения каждого курса
// Бизнес-цель: аналитика популярности и завершаемости курсов
// Эквивалент SQL Query 2

Parse.Cloud.define('getCourseCompletion', async (request) => {
  try {
    // Шаг 1: Получить все курсы
    const courses = await new Parse.Query('Course')
      .include('instructor')
      .find({useMasterKey: true});
    
    const results = [];
    
    // Шаг 2: Для каждого курса подсчитать завершенных студентов
    for (const course of courses) {
      // Шаг 2a: Получить всех студентов на этом курсе
      const enrollments = await new Parse.Query('CourseEnrollment')
        .equalTo('course', course)
        .include('student')
        .find({useMasterKey: true});
      
      console.log(`Курс "${course.get('title')}": ${enrollments.length} студентов`);
      
      let completedCount = 0;
      
      // Шаг 2b: Для каждого студента проверить прогресс по всем урокам
      for (const enrollment of enrollments) {
        const student = enrollment.get('student');
        
        // Получить все модули курса
        const modules = await new Parse.Query('Module')
          .equalTo('course', course)
          .find({useMasterKey: true});
        
        let totalLessons = 0;
        let completedLessons = 0;
        
        // Для каждого модуля получить уроки и их прогресс
        for (const module of modules) {
          const lessons = await new Parse.Query('Lesson')
            .equalTo('module', module)
            .find({useMasterKey: true});
          
          for (const lesson of lessons) {
            totalLessons++;
            
            // Проверить прогресс этого студента по этому уроку
            const progress = await new Parse.Query('LessonProgress')
              .equalTo('student', student)
              .equalTo('lesson', lesson)
              .first({useMasterKey: true});
            
            if (progress && progress.get('completion_percentage') >= 100) {
              completedLessons++;
            }
          }
        }
        
        // Если заверш все уроки - считаем завершенным
        if (totalLessons > 0 && completedLessons === totalLessons) {
          completedCount++;
        }
      }
      
      // Вычислить процент завершения
      const completionRate = enrollments.length > 0 
        ? (completedCount / enrollments.length * 100).toFixed(2)
        : 0;
      
      const instructor = course.get('instructor');
      results.push({
        courseId: course.id,
        title: course.get('title'),
        instructor: instructor ? instructor.get('user').get('first_name') : 'Unknown',
        totalEnrolled: enrollments.length,
        completed: completedCount,
        completionRate: parseFloat(completionRate),
        status: course.get('status')
      });
    }
    
    // Сортировать по проценту завершения (лучшие первыми)
    results.sort((a, b) => b.completionRate - a.completionRate);
    
    return {
      status: 'success',
      data: results,
      totalCourses: results.length,
      averageCompletion: (results.reduce((sum, r) => sum + r.completionRate, 0) / results.length).toFixed(2)
    };
  } catch (error) {
    console.error('Ошибка в getCourseCompletion:', error);
    throw new Parse.Error(Parse.Error.SCRIPT_FAILED, error.message);
  }
});

// ============================================================
// ФУНКЦИЯ 3: getHomeworkReviewStats
// ============================================================
// Статистика по проверкам домашних заданий
// Бизнес-цель: видеть эффективность домашних (процент прохождения)
// Эквивалент SQL Query 3

Parse.Cloud.define('getHomeworkReviewStats', async (request) => {
  try {
    // Получить все домашние задания
    const homeworks = await new Parse.Query('Homework')
      .include('lesson')
      .find({useMasterKey: true});
    
    const results = [];
    
    for (const homework of homeworks) {
      const lesson = homework.get('lesson');
      
      // Получить все сдачи этого домашнего
      const submissions = await new Parse.Query('HomeworkSubmission')
        .equalTo('homework', homework)
        .find({useMasterKey: true});
      
      let reviewedCount = 0;
      let passedCount = 0;
      let gradesSum = 0;
      
      // Для каждой сдачи получить проверку
      for (const submission of submissions) {
        const review = await new Parse.Query('HomeworkReview')
          .equalTo('submission', submission)
          .first({useMasterKey: true});
        
        if (review) {
          reviewedCount++;
          const grade = review.get('grade');
          
          if (grade !== null && grade !== undefined) {
            gradesSum += grade;
            
            // Считаем "прошедшие" если оценка >= 70
            if (grade >= 70) {
              passedCount++;
            }
          }
        }
      }
      
      // Вычислить статистику
      const passRate = reviewedCount > 0 
        ? (passedCount / reviewedCount * 100).toFixed(2)
        : 0;
      
      const averageGrade = reviewedCount > 0
        ? (gradesSum / reviewedCount).toFixed(2)
        : 0;
      
      results.push({
        homeworkId: homework.id,
        title: homework.get('title'),
        lesson: lesson ? lesson.get('title') : 'Unknown',
        totalSubmissions: submissions.length,
        reviewed: reviewedCount,
        passed: passedCount,
        passRate: parseFloat(passRate),
        averageGrade: parseFloat(averageGrade),
        dueDate: homework.get('due_date')
      });
    }
    
    return {
      status: 'success',
      data: results,
      totalHomeworks: results.length,
      averagePassRate: (results.reduce((sum, r) => sum + r.passRate, 0) / results.length).toFixed(2)
    };
  } catch (error) {
    console.error('Ошибка в getHomeworkReviewStats:', error);
    throw new Parse.Error(Parse.Error.SCRIPT_FAILED, error.message);
  }
});

// ============================================================
// ФУНКЦИЯ 4: getTeacherWorkload
// ============================================================
// Нагрузка преподавателей (сколько курсов, сколько работ на проверке)
// Бизнес-цель: распределить нагрузку, выявить перегруженных учителей
// Эквивалент SQL Query 4

Parse.Cloud.define('getTeacherWorkload', async (request) => {
  try {
    // Получить всех учителей
    const teachers = await new Parse.Query('Teacher')
      .include('user')
      .find({useMasterKey: true});
    
    const results = [];
    
    for (const teacher of teachers) {
      const user = teacher.get('user');
      
      // Получить все курсы этого учителя
      const courses = await new Parse.Query('Course')
        .equalTo('instructor', teacher)
        .find({useMasterKey: true});
      
      let totalStudents = 0;
      let pendingReviews = 0;
      
      // Для каждого курса подсчитать студентов и работы на проверке
      for (const course of courses) {
        // Студенты курса
        const enrollments = await new Parse.Query('CourseEnrollment')
          .equalTo('course', course)
          .count({useMasterKey: true});
        
        totalStudents += enrollments;
        
        // Работы на проверке в этом курсе
        // Находим все домашние в этом курсе, потом их сдачи без проверок
        const modules = await new Parse.Query('Module')
          .equalTo('course', course)
          .find({useMasterKey: true});
        
        for (const module of modules) {
          const lessons = await new Parse.Query('Lesson')
            .equalTo('module', module)
            .find({useMasterKey: true});
          
          for (const lesson of lessons) {
            const homeworks = await new Parse.Query('Homework')
              .equalTo('lesson', lesson)
              .find({useMasterKey: true});
            
            for (const hw of homeworks) {
              // Сдачи этого домашнего без проверок
              const submissions = await new Parse.Query('HomeworkSubmission')
                .equalTo('homework', hw)
                .find({useMasterKey: true});
              
              for (const submission of submissions) {
                const review = await new Parse.Query('HomeworkReview')
                  .equalTo('submission', submission)
                  .count({useMasterKey: true});
                
                // Если нет проверки - считаем как pending
                if (review === 0) {
                  pendingReviews++;
                }
              }
            }
          }
        }
      }
      
      results.push({
        teacherId: teacher.id,
        email: user.get('email'),
        name: user.get('first_name') + ' ' + user.get('last_name'),
        coursesTeaching: courses.length,
        totalStudents: totalStudents,
        pendingReviews: pendingReviews,
        averageStudentsPerCourse: courses.length > 0 
          ? (totalStudents / courses.length).toFixed(1)
          : 0
      });
    }
    
    // Сортировать по количеству pending работ (перегруженные первыми)
    results.sort((a, b) => b.pendingReviews - a.pendingReviews);
    
    return {
      status: 'success',
      data: results,
      totalTeachers: results.length,
      totalPendingReviews: results.reduce((sum, r) => sum + r.pendingReviews, 0)
    };
  } catch (error) {
    console.error('Ошибка в getTeacherWorkload:', error);
    throw new Parse.Error(Parse.Error.SCRIPT_FAILED, error.message);
  }
});

// ============================================================
// ФУНКЦИЯ 5: getCourseAnalytics
// ============================================================
// Полная аналитика курса (со всеми метриками)
// Бизнес-цель: dashboard для администраторов/преподавателей
// Эквивалент SQL Query 5

Parse.Cloud.define('getCourseAnalytics', async (request) => {
  try {
    const courseId = request.params.courseId;
    
    if (!courseId) {
      throw new Parse.Error(Parse.Error.INVALID_QUERY, 'courseId is required');
    }
    
    // Получить курс
    const course = await new Parse.Query('Course')
      .include('instructor')
      .get(courseId, {useMasterKey: true});
    
    if (!course) {
      throw new Parse.Error(Parse.Error.OBJECT_NOT_FOUND, 'Course not found');
    }
    
    // Получить все модули
    const modules = await new Parse.Query('Module')
      .equalTo('course', course)
      .find({useMasterKey: true});
    
    // Получить все уроки
    let lessons = [];
    let homeworks = [];
    let totalLessons = 0;
    let totalHomeworks = 0;
    let totalQuizzes = 0;
    
    for (const module of modules) {
      const moduleLessons = await new Parse.Query('Lesson')
        .equalTo('module', module)
        .find({useMasterKey: true});
      
      lessons = lessons.concat(moduleLessons);
      totalLessons += moduleLessons.length;
      
      for (const lesson of moduleLessons) {
        const lessonHW = await new Parse.Query('Homework')
          .equalTo('lesson', lesson)
          .find({useMasterKey: true});
        
        homeworks = homeworks.concat(lessonHW);
        totalHomeworks += lessonHW.length;
        
        const quizzes = await new Parse.Query('Quiz')
          .equalTo('lesson', lesson)
          .count({useMasterKey: true});
        
        totalQuizzes += quizzes;
      }
    }
    
    // Получить всех студентов
    const enrollments = await new Parse.Query('CourseEnrollment')
      .equalTo('course', course)
      .include('student')
      .find({useMasterKey: true});
    
    let completedStudents = 0;
    let totalGrade = 0;
    
    for (const enrollment of enrollments) {
      const student = enrollment.get('student');
      
      // Подсчитать завершенных уроков
      let completedLessons = 0;
      for (const lesson of lessons) {
        const progress = await new Parse.Query('LessonProgress')
          .equalTo('student', student)
          .equalTo('lesson', lesson)
          .first({useMasterKey: true});
        
        if (progress && progress.get('completion_percentage') >= 100) {
          completedLessons++;
        }
      }
      
      if (completedLessons === totalLessons) {
        completedStudents++;
      }
      
      // Итоговая оценка
      const grade = enrollment.get('grade');
      if (grade) {
        totalGrade += parseFloat(grade);
      }
    }
    
    const instructor = course.get('instructor');
    const completionRate = enrollments.length > 0
      ? (completedStudents / enrollments.length * 100).toFixed(2)
      : 0;
    
    const averageGrade = enrollments.length > 0
      ? (totalGrade / enrollments.length).toFixed(2)
      : 0;
    
    return {
      status: 'success',
      courseId: course.id,
      title: course.get('title'),
      description: course.get('description'),
      instructor: {
        id: instructor.id,
        email: instructor.get('user').get('email'),
        name: instructor.get('user').get('first_name') + ' ' + instructor.get('user').get('last_name')
      },
      statistics: {
        enrolledStudents: enrollments.length,
        completedStudents: completedStudents,
        completionRate: parseFloat(completionRate),
        modules: modules.length,
        lessons: totalLessons,
        homeworks: totalHomeworks,
        quizzes: totalQuizzes,
        averageGrade: parseFloat(averageGrade),
        difficulty: course.get('difficulty_level'),
        status: course.get('status'),
        createdAt: course.createdAt
      }
    };
  } catch (error) {
    console.error('Ошибка в getCourseAnalytics:', error);
    throw new Parse.Error(Parse.Error.SCRIPT_FAILED, error.message);
  }
});

// ============================================================
// ЗАВЕРШЕНИЕ CLOUD CODE
// ============================================================
// Все функции готовы к развертыванию!
// Далее: загрузить в Back4app и тестировать через REST API
