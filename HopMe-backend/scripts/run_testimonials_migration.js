import pool from '../src/config/database.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function runTestimonialsMigration() {
  try {
    console.log('🚀 Running testimonials migration...');

    const sqlPath = path.join(__dirname, 'add_testimonials_table.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    await pool.query(sql);

    console.log('✅ Testimonials table successfully created!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during testimonials migration:', error);
    process.exit(1);
  }
}

runTestimonialsMigration();
