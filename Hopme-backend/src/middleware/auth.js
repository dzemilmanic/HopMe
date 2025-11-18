import TokenService from '../services/token.service.js';
import User from '../models/User.js';

export const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Token nije pronađen' });
    }

    const decoded = TokenService.verifyToken(token);
    
    if (!decoded) {
      return res.status(401).json({ message: 'Nevažeći token' });
    }

    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ message: 'Korisnik ne postoji' });
    }

    if (user.account_status !== 'approved') {
      return res.status(403).json({ 
        message: 'Vaš nalog još uvek nije odobren ili je suspendovan' 
      });
    }

    req.user = {
      id: user.id,
      email: user.email,
      roles: user.roles
    };

    next();
  } catch (error) {
    res.status(401).json({ message: 'Autentifikacija neuspešna' });
  }
};