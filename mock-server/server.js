const jsonServer = require('json-server');
const jwt = require('jsonwebtoken');
const path = require('path');

const SECRET = 'dev-secret-do-not-use-in-prod';
const ACCESS_TTL = 60 * 60;
const REFRESH_TTL = 60 * 60 * 24 * 7;

const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));
const middlewares = jsonServer.defaults({ logger: true });

server.use(middlewares);
server.use(jsonServer.bodyParser);

function signTokens(user) {
  const payload = { sub: user.id, username: user.username, role: user.role };
  const accessToken = jwt.sign(payload, SECRET, { expiresIn: ACCESS_TTL });
  const refreshToken = jwt.sign({ sub: user.id, type: 'refresh' }, SECRET, { expiresIn: REFRESH_TTL });
  return { accessToken, refreshToken };
}

function publicUser(u) {
  const { password, ...safe } = u;
  return safe;
}

server.post('/auth/login', (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ error: 'username/password required' });
  }
  const db = router.db;
  const user = db.get('users').find({ username }).value();
  if (!user || user.password !== password) {
    return res.status(401).json({ error: 'Sai tên đăng nhập hoặc mật khẩu' });
  }
  if (user.status !== 'ACTIVE') {
    return res.status(403).json({ error: 'Tài khoản bị khóa' });
  }
  const tokens = signTokens(user);
  return res.json({ user: publicUser(user), ...tokens, expiresIn: ACCESS_TTL });
});

server.post('/auth/refresh', (req, res) => {
  const { refreshToken } = req.body || {};
  if (!refreshToken) return res.status(400).json({ error: 'refreshToken required' });
  try {
    const decoded = jwt.verify(refreshToken, SECRET);
    const user = router.db.get('users').find({ id: decoded.sub }).value();
    if (!user) return res.status(401).json({ error: 'User not found' });
    const tokens = signTokens(user);
    return res.json({ ...tokens, expiresIn: ACCESS_TTL });
  } catch (e) {
    return res.status(401).json({ error: 'Invalid refresh token' });
  }
});

server.post('/auth/forgot-password', (req, res) => {
  return res.json({ ok: true, message: 'Nếu email tồn tại, link reset đã được gửi.' });
});

server.post('/auth/logout', (req, res) => res.json({ ok: true }));

server.use((req, res, next) => {
  if (req.path.startsWith('/auth/')) return next();
  const auth = req.headers.authorization || '';
  const token = auth.replace(/^Bearer\s+/i, '');
  if (!token) return res.status(401).json({ error: 'Missing token' });
  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
});

server.get('/me', (req, res) => {
  const u = router.db.get('users').find({ id: req.user.sub }).value();
  if (!u) return res.status(404).json({ error: 'Not found' });
  res.json(publicUser(u));
});

server.get('/me/children', (req, res) => {
  const u = router.db.get('users').find({ id: req.user.sub }).value();
  if (!u || u.role !== 'PARENT') return res.status(403).json({ error: 'Parent only' });
  const ids = u.childrenIds || [];
  const children = router.db.get('users').filter(x => ids.includes(x.id)).value().map(publicUser);
  res.json(children);
});

server.use(router);

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`SSE mock API running at http://localhost:${PORT}`);
});
