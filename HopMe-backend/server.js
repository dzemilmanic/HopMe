// First load dotenv - before all other imports!
import dotenv from "dotenv";
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Explicitly load .env file
const result = dotenv.config({ path: join(__dirname, '.env') });

if (result.error) {
  console.error('❌ Error loading .env file:', result.error);
  console.log('📁 Looking for .env at:', join(__dirname, '.env'));
} else {
  console.log('✅ .env file successfully loaded');
  console.log('🔍 DB_HOST:', process.env.DB_HOST ? '✓ exists' : '✗ does not exist');
  console.log('🔍 DB_PORT:', process.env.DB_PORT ? '✓ exists' : '✗ does not exist');
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
import testimonialRoutes from './src/routes/testimonial.routes.js';

const app = express();
const PORT = process.env.PORT || 5000;


// Middleware
// Simplest CORS for development
app.use(cors({
  origin: '*', // Allow ALL (only for development!)
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
app.use('/api/testimonials', testimonialRoutes);
// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ 
      message: 'File is too large. Maximum size is 5MB' 
    });
  }

  if (err.code === '23505') {
    return res.status(400).json({ 
      message: 'Value already exists in the database' 
    });
  }

  if (err.code === '23503') {
    return res.status(400).json({ 
      message: 'Referenced resource does not exist' 
    });
  }
  
  res.status(err.status || 500).json({
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// PostgreSQL connection test
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('❌ Error in PostgreSQL connection:', err);
    process.exit(1);
  } else {
    console.log('✅ PostgreSQL connected:', result.rows[0].now);
  }
});

// Server start
app.listen(PORT, () => {
  console.log(`🚀 HopMe Backend started on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV}`);
  console.log(`📊 Database: ${process.env.DB_HOST}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Server shutdown...');
  await pool.end();
  process.exit(0);
});

export default app;