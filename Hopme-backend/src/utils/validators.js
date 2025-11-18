import { body, validationResult } from 'express-validator';

export const validateRegistration = [
  body('email').isEmail().withMessage('Unesite validnu email adresu'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Lozinka mora imati minimum 6 karaktera'),
  body('firstName').notEmpty().withMessage('Ime je obavezno'),
  body('lastName').notEmpty().withMessage('Prezime je obavezno'),
  body('phone')
    .matches(/^[0-9+\-\s()]+$/)
    .withMessage('Unesite validan broj telefona'),
];

export const validateVehicle = [
  body('vehicleType').notEmpty().withMessage('Tip vozila je obavezan'),
];

export const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};