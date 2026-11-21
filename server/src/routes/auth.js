import bcrypt from 'bcryptjs';
import { Router } from 'express';

import { requireUser, signToken } from '../auth.js';
import { ROLES, User } from '../models/user.js';

export const authRouter = Router();

const MIN_PASSWORD = 6;

// One account per email. Asking to register with one that is already taken is
// not an error the traveller should have to decode: the app turns this answer
// into "you already have an account, sign in instead".
authRouter.post('/register', async (req, res) => {
  const { name, email, password, role } = req.body ?? {};

  const problem = validate({ name, email, password });
  if (problem) return res.status(400).json({ error: problem });

  const taken = await User.exists({ email: String(email).toLowerCase() });
  if (taken) {
    return res.status(409).json({
      error: 'An account with this email already exists. Sign in instead.',
      code: 'email_taken',
    });
  }

  const user = await User.create({
    name: String(name).trim(),
    email: String(email).toLowerCase().trim(),
    passwordHash: await bcrypt.hash(String(password), 10),
    role: ROLES.includes(role) ? role : 'traveller',
  });

  res.status(201).json({ token: signToken(user), user: user.toPublic() });
});

authRouter.post('/login', async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) {
    return res.status(400).json({ error: 'Enter your email and password' });
  }

  const user = await User.findOne({ email: String(email).toLowerCase().trim() });
  // The same answer whether the email is unknown or the password is wrong:
  // otherwise this endpoint tells anyone who asks which emails are registered.
  const ok =
    user && (await bcrypt.compare(String(password), user.passwordHash));
  if (!ok) return res.status(401).json({ error: 'Wrong email or password' });

  res.json({ token: signToken(user), user: user.toPublic() });
});

// The app calls this at launch with the token it kept, to find out whether the
// session is still good.
authRouter.get('/me', requireUser, (req, res) => {
  res.json({ user: req.user.toPublic() });
});

function validate({ name, email, password }) {
  if (!name || String(name).trim().length < 2) return 'Enter your full name';
  if (!email || !String(email).includes('@')) return 'Enter a valid email';
  if (!password || String(password).length < MIN_PASSWORD) {
    return `Password must be at least ${MIN_PASSWORD} characters`;
  }
  return null;
}
