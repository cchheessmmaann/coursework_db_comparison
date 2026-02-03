ToDo Frontend (Back4App)

Files:
- `index.html` — simple UI
- `app.js` — uses Parse JS SDK and calls Cloud Functions (see `cloud_code.js`)
- `style.css` — minimal styling

Setup:
1. Replace `APP_ID` and `JS_KEY` in `app.js` with your Back4App Application ID and JavaScript Key.
2. If hosting on Back4App web hosting, upload the `web_todo` folder or serve via any static host.
3. Open `index.html` in a browser to test locally (note: browser CORS and session behavior may require using the hosted version for full parity).

Notes:
- The app uses Parse Cloud Functions (`createTodo`, `getTodos`, `toggleTodo`, `deleteTodo`).
- Authentication: basic username/password sign-up and login is provided for demo purposes. In production, use robust auth flows.
