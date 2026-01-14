import TokenService from '../services/token.service.js';
import User from '../models/User.js';

// Parse PostgreSQL array string to proper array
const parsePostgresArray = (value) => {
  if (Array.isArray(value)) return value;
  if (typeof value === 'string' && value.startsWith('{') && value.endsWith('}')) {
    return value.replace(/[{}]/g, '').split(',').filter(r => r.trim());
  }
  return value;
};

export const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Token not found' });
    }

    const decoded = TokenService.verifyToken(token);
    
    if (!decoded) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    if (user.account_status !== 'approved') {
      return res.status(403).json({ 
        message: 'Your account is not approved or suspended' 
      });
    }

    req.user = {
      id: user.id,
      email: user.email,
      roles: parsePostgresArray(user.roles) || []
    };

    next();
  } catch (error) {
    res.status(401).json({ message: 'Authentication failed' });
  }
};

export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.roles) {
      return res.status(403).json({ message: 'You do not have access to this resource' });
    }

    const hasRole = req.user.roles.some(role => roles.includes(role));

    if (!hasRole) {
      return res.status(403).json({ 
        message: `You do not have access to this resource: ${roles.join(', ')}` 
      });
    }

    next();
  };
};