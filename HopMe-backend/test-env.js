import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: join(__dirname, '.env') });

console.log('🔍 Environment Variables Debug:\n');

const envVars = {
  'DB_HOST': process.env.DB_HOST,
  'DB_PORT': process.env.DB_PORT,
  'DB_NAME': process.env.DB_NAME,
  'DB_USER': process.env.DB_USER,
  'DB_PASSWORD': process.env.DB_PASSWORD,
  'DB_SSL': process.env.DB_SSL,
};

Object.entries(envVars).forEach(([key, value]) => {
  console.log(`${key}:`);
  console.log(`  Value: "${value}"`);
  console.log(`  Type: ${typeof value}`);
  console.log(`  Length: ${value?.length || 0}`);
  console.log(`  Starts with space: ${value && value[0] === ' '}`);
  console.log(`  Ends with space: ${value && value[value.length - 1] === ' '}`);
  console.log(`  Has newline: ${value && value.includes('\n')}`);
  console.log(`  Has carriage return: ${value && value.includes('\r')}`);
  console.log('');
});

// Test password as string
if (process.env.DB_PASSWORD) {
  const cleanPassword = String(process.env.DB_PASSWORD).trim();
  console.log('🧹 Cleaned password:');
  console.log(`  Length: ${cleanPassword.length}`);
  console.log(`  Type: ${typeof cleanPassword}`);
}