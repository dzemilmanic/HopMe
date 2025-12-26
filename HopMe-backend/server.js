// PRVO učitaj dotenv - pre svih ostalih importa!
import dotenv from "dotenv";
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Eksplicitno učitaj .env fajl
const result = dotenv.config({ path: join(__dirname, '.env') });

if (result.error) {
  console.error('❌ Greška pri učitavanju .env fajla:', result.error);
  console.log('📁 Tražim .env na lokaciji:', join(__dirname, '.env'));
} else {
  console.log('✅ .env fajl uspešno učitan');
  console.log('🔍 DB_HOST:', process.env.DB_HOST ? '✓ postoji' : '✗ ne postoji');
  console.log('🔍 DB_PORT:', process.env.DB_PORT ? '✓ postoji' : '✗ ne postoji');
}

import express from 'express';
import cors from 'cors';
import pool from './src/config/database.js';
import swaggerUi from "swagger-ui-express";
import swaggerSpec from './src/config/swagger.js';
import responseTransformer from './src/middleware/responseTransformer.js';

// Routes
import authRoutes from './src/routes/auth.routes.js';
import adminRoutes from './src/routes/admin.routes.js';
import userRoutes from './src/routes/user.routes.js';
import rideRoutes from './src/routes/ride.routes.js';
import bookingRoutes from './src/routes/booking.routes.js';
import ratingRoutes from './src/routes/rating.routes.js';
import notificationRoutes from './src/routes/notification.routes.js';
import mapsRoutes from './src/routes/maps.routes.js';

const app = express();
const PORT = process.env.PORT || 5000;


// Middleware
// Najjednostavniji CORS za development
app.use(cors({
  origin: '*', // Dozvoljava SVE (samo za development!)
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Response Transformer - converts all responses to camelCase and parses PostgreSQL arrays
app.use('/api', responseTransformer);

// Swagger Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'HopMe API Docs',
}));

// Swagger JSON
app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV 
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/user', userRoutes);
app.use('/api/rides', rideRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/ratings', ratingRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/maps', mapsRoutes);
// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ 
      message: 'Fajl je prevelik. Maksimalna veličina je 5MB' 
    });
  }

  if (err.code === '23505') {
    return res.status(400).json({ 
      message: 'Vrednost već postoji u bazi' 
    });
  }

  if (err.code === '23503') {
    return res.status(400).json({ 
      message: 'Referencirani resurs ne postoji' 
    });
  }
  
  res.status(err.status || 500).json({
    message: err.message || 'Interna greška servera',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta nije pronađena' });
});

// PostgreSQL connection test
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('❌ Greška u PostgreSQL konekciji:', err);
    process.exit(1);
  } else {
    console.log('✅ PostgreSQL povezan:', result.rows[0].now);
  }
});

// Server start
app.listen(PORT, () => {
  console.log(`🚀 HopMe Backend pokrenut na portu ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV}`);
  console.log(`📊 Database: ${process.env.DB_HOST}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Gašenje servera...');
  await pool.end();
  process.exit(0);
});

export default app;