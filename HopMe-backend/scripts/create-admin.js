import pool from '../src/config/database.js';
import bcrypt from 'bcryptjs';
import readline from 'readline';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function createAdmin() {
  try {
    console.log('🔐 Kreiranje prvog admin naloga\n');

    const email = await question('Email: ');
    const password = await question('Lozinka: ');
    const firstName = await question('Ime: ');
    const lastName = await question('Prezime: ');
    const phone = await question('Telefon: ');

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert admin
    const result = await pool.query(
      `INSERT INTO users (email, password, first_name, last_name, phone, roles, account_status, is_email_verified, approved_at)
       VALUES ($1, $2, $3, $4, $5, ARRAY['admin']::user_role[], 'approved', true, CURRENT_TIMESTAMP)
       RETURNING id, email, first_name, last_name`,
      [email, hashedPassword, firstName, lastName, phone]
    );

    console.log('\n✅ Admin nalog kreiran!');
    console.log('📧 Email:', result.rows[0].email);
    console.log('👤 Ime:', result.rows[0].first_name, result.rows[0].last_name);
    
    rl.close();
    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Greška:', error.message);
    rl.close();
    await pool.end();
    process.exit(1);
  }
}

createAdmin();