import pool from '../src/config/database.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function runMigration() {
  try {
    console.log('🚀 Pokretanje migracija...');

    const sqlPath = path.join(__dirname, 'database_setup.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    await pool.query(sql);

    console.log('✅ Migracije uspešno izvršene!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Greška pri migraciji:', error);
    process.exit(1);
  }
}

runMigration();