// Replace these placeholder values with your Back4App credentials
const APP_ID = 'YOUR_APP_ID';
const JS_KEY = 'YOUR_JAVASCRIPT_KEY';
const SERVER_URL = 'https://parseapi.back4app.com';

Parse.initialize(APP_ID, JS_KEY);
Parse.serverURL = SERVER_URL;

// Simple auth (signup/login for demo purposes)
const signupBtn = document.getElementById('signupBtn');
const loginBtn = document.getElementById('loginBtn');
const logoutBtn = document.getElementById('logoutBtn');
const userInfo = document.getElementById('userInfo');

signupBtn.onclick = async () => {
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  if (!username || !password) return alert('Enter username and password');
  const user = new Parse.User();
  user.set('username', username);
  user.set('password', password);
  try {
    await user.signUp();
    renderAuthState();
    loadTodos();
  } catch (e) { alert(e.message); }
};

loginBtn.onclick = async () => {
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  try {
    await Parse.User.logIn(username, password);
    renderAuthState();
    loadTodos();
  } catch (e) { alert(e.message); }
};

logoutBtn.onclick = async () => {
  await Parse.User.logOut();
  renderAuthState();
  document.getElementById('todoList').innerHTML = '';
};

function renderAuthState() {
  const user = Parse.User.current();
  if (user) {
    userInfo.textContent = `Logged in as ${user.get('username')}`;
    logoutBtn.style.display = 'inline-block';
    document.getElementById('todoForm').style.display = 'block';
    document.getElementById('auth').querySelectorAll('input,button').forEach(el => { if (el !== logoutBtn) el.style.display = 'none'; });
  } else {
    userInfo.textContent = 'Not logged in';
    logoutBtn.style.display = 'none';
    document.getElementById('todoForm').style.display = 'none';
    document.getElementById('auth').querySelectorAll('input,button').forEach(el => { if (el !== logoutBtn) el.style.display = 'inline-block'; });
  }
}

// Add todo
document.getElementById('addBtn').onclick = async () => {
  const title = document.getElementById('title').value;
  const dueDate = document.getElementById('dueDate').value;
  const priority = parseInt(document.getElementById('priority').value, 10);
  if (!title) return alert('Enter title');
  try {
    await Parse.Cloud.run('createTodo', { title, dueDate: dueDate || undefined, priority });
    document.getElementById('title').value = '';
    loadTodos();
  } catch (e) { alert(e.message); }
};

// Load todos
async function loadTodos() {
  try {
    const results = await Parse.Cloud.run('getTodos', {});
    const list = document.getElementById('todoList');
    list.innerHTML = '';
    results.forEach(t => {
      const li = document.createElement('li');
      const chk = document.createElement('input'); chk.type = 'checkbox'; chk.checked = t.done;
      chk.onchange = async () => { await Parse.Cloud.run('toggleTodo', { todoId: t.id }); loadTodos(); };
      li.appendChild(chk);
      const span = document.createElement('span'); span.textContent = ` ${t.title} `;
      li.appendChild(span);
      if (t.dueDate) {
        const d = new Date(t.dueDate).toLocaleDateString();
        const dateSpan = document.createElement('small'); dateSpan.textContent = ` (due ${d}) `; li.appendChild(dateSpan);
      }
      const del = document.createElement('button'); del.textContent = 'Delete'; del.onclick = async () => { await Parse.Cloud.run('deleteTodo', { todoId: t.id }); loadTodos(); };
      li.appendChild(del);
      list.appendChild(li);
    });
  } catch (e) {
    console.error(e); if (e.code === 209) { alert('Session expired — please log in again'); Parse.User.logOut(); renderAuthState(); }
  }
}

// Initialize
renderAuthState();
if (Parse.User.current()) loadTodos();