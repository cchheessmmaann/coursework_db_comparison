

// ФУНКЦИЯ 1:
// Найти студентов, которые пропустили домашние задания
// Бизнес-цель: выявить студентов в риске для контакта
// Эквивалент SQL Query 1

Parse.Cloud.define('getStudentsMissingHomeworks', async (request) => {
  try {
    const students = await new Parse.Query('Student')
      .include('user')
      .find({useMasterKey: true});
    
    console.log(`Найдено ${students.length} студентов`);
    
    const results = [];
    
    for (const student of students) {
      const enrollments = await new Parse.Query('CourseEnrollment')
        .equalTo('student', student)
        .include('course')
        .find({useMasterKey: true});
      
      console.log(`Студент ${student.id}: ${enrollments.length} курсов`);
      
      let missedCount = 0;
      let missedHomeworkIds = [];
      
      for (const enrollment of enrollments) {
        const course = enrollment.get('course');
        
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
              const submissions = await new Parse.Query('HomeworkSubmission')
                .equalTo('homework', hw)
                .equalTo('student', student)
                .count({useMasterKey: true});
              
              if (submissions === 0) {
                missedCount++;
                missedHomeworkIds.push(hw.id);
              }
            }
          }
        }
      }
      
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


// ФУНКЦИЯ 2: 
// Процент завершения каждого курса
// Бизнес-цель: аналитика популярности и завершаемости курсов
// Эквивалент SQL Query 2

Parse.Cloud.define('getCourseCompletion', async (request) => {
  try {
    const courses = await new Parse.Query('Course')
      .include('instructor')
      .find({useMasterKey: true});
    
    const results = [];
    
    for (const course of courses) {
      const enrollments = await new Parse.Query('CourseEnrollment')
        .equalTo('course', course)
        .include('student')
        .find({useMasterKey: true});
      
      console.log(`Курс "${course.get('title')}": ${enrollments.length} студентов`);
      
      let completedCount = 0;
      
      for (const enrollment of enrollments) {
        const student = enrollment.get('student');
        
        const modules = await new Parse.Query('Module')
          .equalTo('course', course)
          .find({useMasterKey: true});
        
        let totalLessons = 0;
        let completedLessons = 0;
        
        for (const module of modules) {
          const lessons = await new Parse.Query('Lesson')
            .equalTo('module', module)
            .find({useMasterKey: true});
          
          for (const lesson of lessons) {
            totalLessons++;
            
            const progress = await new Parse.Query('LessonProgress')
              .equalTo('student', student)
              .equalTo('lesson', lesson)
              .first({useMasterKey: true});
            
            if (progress && progress.get('completion_percentage') >= 100) {
              completedLessons++;
            }
          }
        }
        
        if (totalLessons > 0 && completedLessons === totalLessons) {
          completedCount++;
        }
      }
      
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

// ФУНКЦИЯ 3: 
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
      
      const submissions = await new Parse.Query('HomeworkSubmission')
        .equalTo('homework', homework)
        .find({useMasterKey: true});
      
      let reviewedCount = 0;
      let passedCount = 0;
      let gradesSum = 0;
      
      for (const submission of submissions) {
        const review = await new Parse.Query('HomeworkReview')
          .equalTo('submission', submission)
          .first({useMasterKey: true});
        
        if (review) {
          reviewedCount++;
          const grade = review.get('grade');
          
          if (grade !== null && grade !== undefined) {
            gradesSum += grade;
            
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

// ФУНКЦИЯ 4: getTeacherWorkload
// Нагрузка преподавателей (сколько курсов, сколько работ на проверке)
// Бизнес-цель: распределить нагрузку, выявить перегруженных учителей
// Эквивалент SQL Query 4

Parse.Cloud.define('getTeacherWorkload', async (request) => {
  try {
    const teachers = await new Parse.Query('Teacher')
      .include('user')
      .find({useMasterKey: true});
    
    const results = [];
    
    for (const teacher of teachers) {
      const user = teacher.get('user');
      
      const courses = await new Parse.Query('Course')
        .equalTo('instructor', teacher)
        .find({useMasterKey: true});
      
      let totalStudents = 0;
      let pendingReviews = 0;
      
      for (const course of courses) {
        const enrollments = await new Parse.Query('CourseEnrollment')
          .equalTo('course', course)
          .count({useMasterKey: true});
        
        totalStudents += enrollments;
        
        // Работы на проверке в этом курсе
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
              const submissions = await new Parse.Query('HomeworkSubmission')
                .equalTo('homework', hw)
                .find({useMasterKey: true});
              
              for (const submission of submissions) {
                const review = await new Parse.Query('HomeworkReview')
                  .equalTo('submission', submission)
                  .count({useMasterKey: true});
                
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

// ФУНКЦИЯ 5: getCourseAnalytics
// Полная аналитика курса (со всеми метриками)
// Бизнес-цель: dashboard для администраторов/преподавателей
// Эквивалент SQL Query 5

Parse.Cloud.define('getCourseAnalytics', async (request) => {
  try {
    const courseId = request.params.courseId;
    
    if (!courseId) {
      throw new Parse.Error(Parse.Error.INVALID_QUERY, 'courseId is required');
    }
    
    const course = await new Parse.Query('Course')
      .include('instructor')
      .get(courseId, {useMasterKey: true});
    
    if (!course) {
      throw new Parse.Error(Parse.Error.OBJECT_NOT_FOUND, 'Course not found');
    }
    
    const modules = await new Parse.Query('Module')
      .equalTo('course', course)
      .find({useMasterKey: true});
    
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
    
    const enrollments = await new Parse.Query('CourseEnrollment')
      .equalTo('course', course)
      .include('student')
      .find({useMasterKey: true});
    
    let completedStudents = 0;
    let totalGrade = 0;
    
    for (const enrollment of enrollments) {
      const student = enrollment.get('student');
      
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

// -----------------------------
// ToDo App Cloud Code
// -----------------------------

// Helper: fetch a Todo by id and ensure it belongs to the requesting user
async function _getTodoByIdForUser(todoId, user) {
  const q = new Parse.Query('Todo');
  q.equalTo('objectId', todoId);
  q.equalTo('owner', user);
  const todo = await q.first({useMasterKey: true});
  if (!todo) throw new Parse.Error(Parse.Error.OBJECT_NOT_FOUND, 'Todo not found');
  return todo;
}

// Validate and set defaults before saving a Todo
Parse.Cloud.beforeSave('Todo', async (req) => {
  const todo = req.object;
  const user = req.user;

  if (!todo.get('title') || todo.get('title').trim().length === 0) {
    throw new Parse.Error(Parse.Error.VALIDATION_ERROR, 'Title is required');
  }

  // On create, set owner + ACL and defaults
  if (todo.isNew()) {
    if (user) {
      todo.set('owner', user);
      const acl = new Parse.ACL(user);
      todo.setACL(acl);
    }
    if (todo.get('done') === undefined) todo.set('done', false);
    if (todo.get('priority') === undefined) todo.set('priority', 1);
  }
});

// Create a new Todo
Parse.Cloud.define('createTodo', async (req) => {
  const user = req.user;
  if (!user) throw new Parse.Error(Parse.Error.INVALID_SESSION_TOKEN, 'Authentication required');

  const Todo = Parse.Object.extend('Todo');
  const todo = new Todo();
  todo.set('title', req.params.title);
  todo.set('done', !!req.params.done);
  if (req.params.dueDate) todo.set('dueDate', new Date(req.params.dueDate));
  if (req.params.priority !== undefined) todo.set('priority', req.params.priority);
  todo.set('owner', user);

  const acl = new Parse.ACL(user);
  todo.setACL(acl);

  await todo.save(null, {useMasterKey: true});
  return {
    id: todo.id,
    title: todo.get('title'),
    done: todo.get('done'),
    dueDate: todo.get('dueDate'),
    priority: todo.get('priority')
  };
});

// List Todos for current user (optional filter by done)
Parse.Cloud.define('getTodos', async (req) => {
  const user = req.user;
  if (!user) throw new Parse.Error(Parse.Error.INVALID_SESSION_TOKEN, 'Authentication required');

  const q = new Parse.Query('Todo');
  q.equalTo('owner', user);
  if (req.params.done !== undefined) q.equalTo('done', req.params.done);
  q.ascending('order');

  const results = await q.find({useMasterKey: true});
  return results.map(t => ({ id: t.id, title: t.get('title'), done: t.get('done'), dueDate: t.get('dueDate'), priority: t.get('priority') }));
});

// Update a Todo (title, done, dueDate, priority)
Parse.Cloud.define('updateTodo', async (req) => {
  const user = req.user;
  if (!user) throw new Parse.Error(Parse.Error.INVALID_SESSION_TOKEN, 'Authentication required');

  const todo = await _getTodoByIdForUser(req.params.todoId, user);
  if (req.params.title !== undefined) todo.set('title', req.params.title);
  if (req.params.done !== undefined) todo.set('done', req.params.done);
  if (req.params.dueDate !== undefined) todo.set('dueDate', new Date(req.params.dueDate));
  if (req.params.priority !== undefined) todo.set('priority', req.params.priority);

  await todo.save(null, {useMasterKey: true});
  return { id: todo.id, title: todo.get('title'), done: todo.get('done'), dueDate: todo.get('dueDate'), priority: todo.get('priority') };
});

// Delete a Todo
Parse.Cloud.define('deleteTodo', async (req) => {
  const user = req.user;
  if (!user) throw new Parse.Error(Parse.Error.INVALID_SESSION_TOKEN, 'Authentication required');

  const todo = await _getTodoByIdForUser(req.params.todoId, user);
  await todo.destroy({useMasterKey: true});
  return { success: true };
});

// Toggle done state
Parse.Cloud.define('toggleTodo', async (req) => {
  const user = req.user;
  if (!user) throw new Parse.Error(Parse.Error.INVALID_SESSION_TOKEN, 'Authentication required');

  const todo = await _getTodoByIdForUser(req.params.todoId, user);
  todo.set('done', !todo.get('done'));
  await todo.save(null, {useMasterKey: true});
  return { id: todo.id, done: todo.get('done') };
});
