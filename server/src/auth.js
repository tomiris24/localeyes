import jwt from 'jsonwebtoken';

import { User } from './models/user.js';

const DEV_SECRET = 'localeyes-dev-secret';
const TOKEN_LIFETIME = '30d';

function secret() {
  return process.env.JWT_SECRET || DEV_SECRET;
}

export function signToken(user) {
  return jwt.sign({ sub: user._id.toString() }, secret(), {
    expiresIn: TOKEN_LIFETIME,
  });
}

/// Reads `Authorization: Bearer <token>` and puts the user on the request.
export async function requireUser(req, res, next) {
  const header = req.get('authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Sign in to continue' });

  let payload;
  try {
    payload = jwt.verify(token, secret());
  } catch {
    return res.status(401).json({ error: 'Your session has expired' });
  }

  const user = await User.findById(payload.sub);
  if (!user) return res.status(401).json({ error: 'This account is gone' });

  req.user = user;
  next();
}
