import jwt from 'jsonwebtoken';

class TokenService {
  static generateAccessToken(userId, email, roles) {
    return jwt.sign(
      { userId, email, roles },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );
  }

  static verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      return null;
    }
  }
}

export default TokenService;