import nodemailer from 'nodemailer';

// Log email configuration status on startup
console.log('📧 Email Service Configuration:');
console.log('   HOST:', process.env.EMAIL_HOST || '❌ NOT SET');
console.log('   PORT:', process.env.EMAIL_PORT || '❌ NOT SET');
console.log('   USER:', process.env.EMAIL_USER ? '✅ SET' : '❌ NOT SET');
console.log('   PASS:', process.env.EMAIL_PASS ? '✅ SET' : '❌ NOT SET');
console.log('   FROM:', process.env.EMAIL_FROM || '❌ NOT SET');
console.log('   FRONTEND_URL:', process.env.FRONTEND_URL || '❌ NOT SET');

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: process.env.EMAIL_PORT,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Verify transporter connection on startup
transporter.verify((error, success) => {
  if (error) {
    console.error('❌ Email transporter verification failed:', error.message);
  } else {
    console.log('✅ Email transporter is ready to send emails');
  }
});

class EmailService {
  static async sendVerificationEmail(email, token, firstName) {
    console.log(`📧 Attempting to send verification email to: ${email}`);
    
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: 'HopMe - Verifikacija email adrese',
      html: `
        <h2>Pozdrav ${firstName},</h2>
        <p>Hvala što ste se registrovali na HopMe platformu!</p>
        <p>Molimo vas da verifikujete vašu email adresu klikom na dugme ispod:</p>
        <a href="${verificationUrl}" 
           style="background-color: #4CAF50; color: white; padding: 14px 20px; 
                  text-decoration: none; display: inline-block; border-radius: 4px;">
          Verifikuj Email
        </a>
        <p>Ili kopirajte sledeći link u vaš browser:</p>
        <p>${verificationUrl}</p>
        <p>Link ističe za 24 sata.</p>
        <br>
        <p>Srdačan pozdrav,<br>HopMe Tim</p>
      `
    };

    try {
      const result = await transporter.sendMail(mailOptions);
      console.log(`✅ Verification email sent successfully to: ${email}`);
      console.log(`   Message ID: ${result.messageId}`);
      return result;
    } catch (error) {
      console.error(`❌ Failed to send verification email to: ${email}`);
      console.error(`   Error: ${error.message}`);
      console.error(`   Code: ${error.code}`);
      throw error;
    }
  }

  static async sendApprovalEmail(email, firstName, isApproved) {
    console.log(`📧 Attempting to send approval email to: ${email} (approved: ${isApproved})`);
    
    const subject = isApproved 
      ? 'HopMe - Vaš nalog je odobren!' 
      : 'HopMe - Status vašeg naloga';
    
    const message = isApproved
      ? `
        <h2>Pozdrav ${firstName},</h2>
        <p>Vaš nalog je odobren od strane administratora!</p>
        <p>Sada možete da se prijavite i koristite sve funkcionalnosti HopMe platforme.</p>
        <a href="${process.env.FRONTEND_URL}/login" 
           style="background-color: #4CAF50; color: white; padding: 14px 20px; 
                  text-decoration: none; display: inline-block; border-radius: 4px;">
          Prijavite se
        </a>
      `
      : `
        <h2>Pozdrav ${firstName},</h2>
        <p>Žao nam je, ali vaš zahtev za registraciju nije odobren.</p>
        <p>Za više informacija, molimo kontaktirajte našu korisničku podršku.</p>
      `;

    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: subject,
      html: message + '<br><p>Srdačan pozdrav,<br>HopMe Tim</p>'
    };

    try {
      const result = await transporter.sendMail(mailOptions);
      console.log(`✅ Approval email sent successfully to: ${email}`);
      return result;
    } catch (error) {
      console.error(`❌ Failed to send approval email to: ${email}`);
      console.error(`   Error: ${error.message}`);
      throw error;
    }
  }

  static async sendPasswordResetEmail(email, token, firstName) {
    console.log(`📧 Attempting to send password reset email to: ${email}`);
    
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to: email,
      subject: 'HopMe - Resetovanje lozinke',
      html: `
        <h2>Pozdrav ${firstName},</h2>
        <p>Primili smo zahtev za resetovanje vaše lozinke.</p>
        <p>Kliknite na dugme ispod da resetujete lozinku:</p>
        <a href="${resetUrl}" 
           style="background-color: #2196F3; color: white; padding: 14px 20px; 
                  text-decoration: none; display: inline-block; border-radius: 4px;">
          Resetuj Lozinku
        </a>
        <p>Link ističe za 1 sat.</p>
        <p>Ako niste Vi zatražili ovu promenu, ignorišite ovaj email.</p>
        <br>
        <p>Srdačan pozdrav,<br>HopMe Tim</p>
      `
    };

    try {
      const result = await transporter.sendMail(mailOptions);
      console.log(`✅ Password reset email sent successfully to: ${email}`);
      return result;
    } catch (error) {
      console.error(`❌ Failed to send password reset email to: ${email}`);
      console.error(`   Error: ${error.message}`);
      throw error;
    }
  }
}

export default EmailService;