# Back4app Implementation Guide

## Platform Overview

Back4app is a Backend-as-a-Service platform built on Parse. It provides:
- Cloud-hosted database (NoSQL)
- REST API and SDKs
- Cloud Code for server-side logic
- Built-in user authentication
- File storage
- Real-time subscriptions

## Step-by-Step Implementation

### 1. Initial Setup

1. Create account at https://www.back4app.com
2. Create a new application
3. Note your Application ID and REST API Key
4. Configure data classes (equivalent to database tables)

### 2. Data Model Design in Back4app

Unlike SQL, Back4app uses flexible schema with classes and relations:

#### Classes to Create:

1. **User** (extends Parse.User)
   - Fields: email, firstName, lastName, phone, isActive
   
2. **Student** (extends User relationship)
   - Fields: studentNumber, bio, enrollmentDate
   - Pointer to: User
   
3. **Teacher** (extends User relationship)
   - Fields: employeeNumber, specialization, bio, hireDate
   - Pointer to: User
   
4. **Course**
   - Fields: title, description, category, difficultyLevel, status, maxStudents
   - Pointer to: Teacher (instructor)
   
5. **CourseEnrollment**
   - Fields: enrollmentDate, completionDate, status, grade
   - Pointers: Student, Course
   
6. **Module**
   - Fields: title, description, orderNumber
   - Pointer to: Course
   
7. **Lesson**
   - Fields: title, description, lessonType, contentUrl, durationMinutes, orderNumber
   - Pointer to: Module
   
8. **Quiz**
   - Fields: title, description, passingScore, totalQuestions, timeLimitMinutes
   - Pointer to: Lesson
   
9. **LessonProgress**
   - Fields: status, startedAt, completedAt, quizScore, timeSpentMinutes
   - Pointers: Student, Lesson
   
10. **Homework**
    - Fields: title, description, instructions, maxScore, dueDate
    - Pointer to: Lesson
    
11. **HomeworkSubmission**
    - Fields: submissionText, fileUrl, submittedAt, status, isLate
    - Pointers: Homework, Student
    
12. **HomeworkReview**
    - Fields: score, feedback, status, reviewRound, createdAt, updatedAt
    - Pointers: HomeworkSubmission, Teacher
    
13. **ReviewComment**
    - Fields: commentText, lineNumber, commentType, createdAt, updatedAt
    - Pointers: HomeworkReview, User (commenter)

### 3. Creating Classes via Web Console

For each class:
1. Go to Data Browser
2. Click "+ Create class"
3. Enter class name
4. Set columns/fields with appropriate types:
   - String
   - Number
   - Boolean
   - Date
   - Pointer (to other classes)
   - Array
   - Object

### 4. Uploading Test Data

#### Option A: CSV Import
1. Prepare CSV file with headers matching field names
2. Data Browser → Import → Select CSV

#### Option B: REST API
```bash
curl -X POST https://parseapi.back4app.com/parse/classes/Course \
  -H "X-Parse-Application-Id: YOUR_APP_ID" \
  -H "X-Parse-REST-API-Key: YOUR_REST_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Introduction to Python Programming",
    "description": "Learn Python basics from scratch",
    "category": "Programming",
    "difficultyLevel": "Beginner",
    "status": "Active"
  }'
```

#### Option C: Batch Import
Create JSON file with data and use Data Batch API

### 5. Cloud Code Deployment

The `cloud_code.js` file contains 5 Cloud Functions:

1. **getStudentsMissingHomeworks**
   - Finds students with missing homework submissions
   
2. **getCourseCompletion**
   - Calculates completion rates for enrollments
   
3. **getHomeworkReviewStats**
   - Analyzes homework submissions and reviews
   
4. **getTeacherWorkload**
   - Shows teacher statistics
   
5. **getCourseAnalytics**
   - Comprehensive course metrics

#### Deploying Cloud Code:

1. Install Back4app CLI:
   ```bash
   npm install -g back4app-cli
   ```

2. Login:
   ```bash
   back4app login
   ```

3. Deploy from cloud_code.js directory:
   ```bash
   back4app deploy
   ```

Or upload directly in Back4app Console → Cloud Code

### 6. Querying Data

#### Via REST API:

```bash
# Simple query
curl -X GET "https://parseapi.back4app.com/parse/classes/Course?where={\"status\":\"Active\"}" \
  -H "X-Parse-Application-Id: YOUR_APP_ID" \
  -H "X-Parse-REST-API-Key: YOUR_REST_KEY"

# With includes (joins)
curl -X GET "https://parseapi.back4app.com/parse/classes/CourseEnrollment?include=student,course&limit=100" \
  -H "X-Parse-Application-Id: YOUR_APP_ID" \
  -H "X-Parse-REST-API-Key: YOUR_REST_KEY"

# Cloud Function call
curl -X POST "https://parseapi.back4app.com/parse/functions/getCourseAnalytics" \
  -H "X-Parse-Application-Id: YOUR_APP_ID" \
  -H "X-Parse-REST-API-Key: YOUR_REST_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

#### Via Python SDK:

```python
from parse_rest.connection import register
from parse_rest.query import QueryResourceSet

register('YOUR_APP_ID', 'YOUR_REST_KEY')

# Query Course class
courses = QueryResourceSet('Course', limit=100)
for course in courses:
    print(course.title)
```

### 7. Setting Up ACL and Security

```javascript
// In Cloud Code, set object-level permissions
const acl = new Parse.ACL();
acl.setReadAccess(user, true);
acl.setWriteAccess(user, true);
object.setACL(acl);
```

### 8. Comparison Points

**Advantages of Back4app:**
- No database setup required
- Automatic scaling
- Built-in user management
- Real-time subscriptions
- File hosting
- Dashboard included

**Disadvantages:**
- Less control over data structure
- Fewer complex query capabilities
- Data costs increase with scale
- Learning curve for Cloud Code

## ToDo App Example

This repository includes a minimal ToDo app example that demonstrates how to model data, expose Cloud Functions, and provide a small web frontend hosted via Back4App (or any static host).

### Data model
- **Todo**
  - `title` (String) — required
  - `done` (Boolean) — default `false`
  - `dueDate` (Date) — optional
  - `priority` (Number) — default `1`
  - `order` (Number) — optional (for ordering)
  - `owner` (Pointer -> _User) — set automatically on create

> Security: A `beforeSave` Cloud trigger sets the `owner` and applies an ACL that allows only the owner to read/write their todos.

### Cloud Functions (added to `cloud_code.js`)
- `createTodo` — creates a Todo for the authenticated user
- `getTodos` — lists the current user's todos (supports `done` filter)
- `updateTodo` — updates fields on a Todo (owner-only)
- `deleteTodo` — deletes a Todo (owner-only)
- `toggleTodo` — toggles the `done` state (owner-only)

All functions require authentication (valid session token) and use `useMasterKey` internally for secure ownership checks.

### Example REST call (create)
```bash
curl -X POST https://parseapi.back4app.com/parse/functions/createTodo \
  -H "X-Parse-Application-Id: YOUR_APP_ID" \
  -H "X-Parse-REST-API-Key: YOUR_REST_KEY" \
  -H "X-Parse-Session-Token: USER_SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Buy milk","dueDate":"2026-02-05T12:00:00Z"}'
```

### Frontend (static web)
A simple single-page app is provided in `back4app/web_todo/`:
- `index.html` — UI and Parse JS SDK include
- `app.js` — initialization (`Parse.initialize(APP_ID, JS_KEY)` + `Parse.serverURL`) and CRUD interactions
- `style.css` — minimal styling

To use the front-end locally, open `index.html` after replacing placeholders in `app.js` with your **Application ID**, **JavaScript Key**, and server URL. To host via Back4App, upload the files through Web Hosting or serve them from any static host.

### Deployment
1. Deploy Cloud Code with:
   ```bash
   npm install -g back4app-cli
   back4app login
   back4app deploy
   ```
2. Upload `web_todo` directory to Back4App Web Hosting or any static hosting provider and configure keys in `app.js`.

---

## Key Differences from SQL

| Feature | SQL | Back4app |
|---------|-----|----------|
| Schema | Rigid, predefined | Flexible, grows with data |
| Relationships | Foreign keys, JOINs | Pointers, includes |
| Complex queries | SQL with JOINs, aggregates | Cloud Code + multiple API calls |
| Scalability | Requires management | Automatic |
| Setup time | Hours/days | Minutes |
| Learning curve | Higher for beginners | Lower for web developers |
| Cost model | Server rental | Pay-per-use |

## References

- Back4app Documentation: https://www.back4app.com/docs
- Parse Server GitHub: https://github.com/parse-community/parse-server
- API Reference: https://www.back4app.com/docs/infrastructure/api-reference
