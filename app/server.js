const express = require('express');
const session = require('express-session');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

const app = express();
app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: false }));
app.use(session({
  secret: process.env.SESSION_SECRET || 'dev-secret',
  resave: false,
  saveUninitialized: false
}));
app.use((req, res, next) => { res.locals.user = req.session.user || null; next(); });

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5
});

const h = fn => (req, res, next) => fn(req, res, next).catch(next);
const needLogin = (req, res, next) => req.session.user ? next() : res.redirect('/login');

app.get('/health', (req, res) => res.send('OK'));

// Trang chủ: danh sách chủ đề
app.get('/', h(async (req, res) => {
  const [topics] = await pool.query(
    `SELECT t.id, t.title, u.username, t.created_at,
     (SELECT COUNT(*) FROM posts p WHERE p.topic_id = t.id) AS post_count
     FROM topics t JOIN users u ON u.id = t.user_id ORDER BY t.id DESC`);
  res.render('index', { topics });
}));

app.post('/topics', needLogin, h(async (req, res) => {
  const title = (req.body.title || '').trim();
  if (title) await pool.query('INSERT INTO topics (title, user_id) VALUES (?, ?)', [title, req.session.user.id]);
  res.redirect('/');
}));

// Chủ đề: danh sách bài viết
app.get('/topics/:id', h(async (req, res) => {
  const [t] = await pool.query('SELECT * FROM topics WHERE id = ?', [req.params.id]);
  if (!t.length) return res.status(404).send('Khong tim thay chu de');
  const [posts] = await pool.query(
    `SELECT p.id, p.title, u.username, p.created_at
     FROM posts p JOIN users u ON u.id = p.user_id
     WHERE p.topic_id = ? ORDER BY p.id DESC`, [req.params.id]);
  res.render('topic', { topic: t[0], posts });
}));

app.post('/topics/:id/posts', needLogin, h(async (req, res) => {
  const title = (req.body.title || '').trim();
  const content = (req.body.content || '').trim();
  if (title && content)
    await pool.query('INSERT INTO posts (topic_id, user_id, title, content) VALUES (?, ?, ?, ?)',
      [req.params.id, req.session.user.id, title, content]);
  res.redirect('/topics/' + req.params.id);
}));

// Bài viết + bình luận
app.get('/posts/:id', h(async (req, res) => {
  const [p] = await pool.query(
    `SELECT p.*, u.username FROM posts p JOIN users u ON u.id = p.user_id WHERE p.id = ?`, [req.params.id]);
  if (!p.length) return res.status(404).send('Khong tim thay bai viet');
  const [comments] = await pool.query(
    `SELECT c.content, c.created_at, u.username
     FROM comments c JOIN users u ON u.id = c.user_id
     WHERE c.post_id = ? ORDER BY c.id`, [req.params.id]);
  res.render('post', { post: p[0], comments });
}));

app.post('/posts/:id/comments', needLogin, h(async (req, res) => {
  const content = (req.body.content || '').trim();
  if (content)
    await pool.query('INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)',
      [req.params.id, req.session.user.id, content]);
  res.redirect('/posts/' + req.params.id);
}));

// Đăng ký / đăng nhập / đăng xuất
app.get('/register', (req, res) => res.render('auth', { title: 'Dang ky', action: '/register', error: null }));
app.post('/register', h(async (req, res) => {
  const username = (req.body.username || '').trim();
  const password = req.body.password || '';
  if (username.length < 3 || password.length < 6)
    return res.render('auth', { title: 'Dang ky', action: '/register', error: 'Ten >= 3 ky tu, mat khau >= 6 ky tu' });
  try {
    const hash = await bcrypt.hash(password, 10);
    await pool.query('INSERT INTO users (username, password_hash) VALUES (?, ?)', [username, hash]);
    res.redirect('/login');
  } catch (e) {
    res.render('auth', { title: 'Dang ky', action: '/register', error: 'Ten dang nhap da ton tai' });
  }
}));

app.get('/login', (req, res) => res.render('auth', { title: 'Dang nhap', action: '/login', error: null }));
app.post('/login', h(async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users WHERE username = ?', [req.body.username || '']);
  if (rows.length && await bcrypt.compare(req.body.password || '', rows[0].password_hash)) {
    req.session.user = { id: rows[0].id, username: rows[0].username };
    return res.redirect('/');
  }
  console.log('LOGIN_FAILED user=' + (req.body.username || ''));
  res.render('auth', { title: 'Dang nhap', action: '/login', error: 'Sai ten dang nhap hoac mat khau' });
}));

app.get('/logout', (req, res) => req.session.destroy(() => res.redirect('/')));

app.use((err, req, res, next) => { console.error(err); res.status(500).send('Loi may chu'); });

app.listen(3000, () => console.log('Forum dang chay o cong 3000'));
