// PRVO učitaj dotenv i ovde!
import dotenv from 'dotenv';
dotenv.config();

import pg from 'pg';
const { Pool } = pg;

// Proveri da li su varijable učitane
if (!process.env.DB_HOST || !process.env.DB_PASSWORD) {
  console.error('❌ KRITIČNA GREŠKA: Environment varijable nisu učitane!');
  console.error('DB_HOST:', process.env.DB_HOST);
  console.error('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);
  throw new Error('Database configuration missing');
}

const poolConfig = {
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD, // već je string
  ssl: {
    rejectUnauthorized: false
  },
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
};

console.log('📊 Database pool configuration:');
console.log('  Host:', poolConfig.host);
console.log('  Port:', poolConfig.port);
console.log('  Database:', poolConfig.database);
console.log('  User:', poolConfig.user);
console.log('  Password length:', poolConfig.password?.length);
console.log('  SSL:', poolConfig.ssl ? 'enabled' : 'disabled');

const pool = new Pool(poolConfig);

pool.on('connect', (client) => {
  console.log('✅ PostgreSQL konekcija uspešna');
});

pool.on('error', (err, client) => {
  console.error('❌ PostgreSQL greška:', err.message);
});

// Async test konekcije
(async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Test konekcije uspešan');
    client.release();
  } catch (err) {
    console.error('❌ Greška pri testiranju konekcije:', err.message);
  }
})();

export default pool;