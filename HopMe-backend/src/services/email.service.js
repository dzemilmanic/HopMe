import { Resend } from 'resend';

// Initialize Resend with API key
const resend = new Resend(process.env.RESEND_API_KEY);

// Log configuration status
console.log('📧 Email Service Configuration (Resend):');
console.log('   API_KEY:', process.env.RESEND_API_KEY ? '✅ SET' : '❌ NOT SET');
console.log('   FROM:', process.env.EMAIL_FROM || 'onboarding@resend.dev');
console.log('   FRONTEND_URL:', process.env.FRONTEND_URL || '❌ NOT SET');

const fromEmail = process.env.EMAIL_FROM || 'onboarding@resend.dev';

class EmailService {
  static async sendVerificationEmail(email, token, firstName) {
    console.log(`📧 Attempting to send verification email to: ${email}`);
    
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    
    try {
      const { data, error } = await resend.emails.send({
        from: fromEmail,
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
      });

      if (error) {
        console.error(`❌ Resend error: ${error.message}`);
        throw new Error(error.message);
      }

      console.log(`✅ Verification email sent successfully to: ${email}`);
      console.log(`   Message ID: ${data?.id}`);
      return data;
    } catch (error) {
      console.error(`❌ Failed to send verification email to: ${email}`);
      console.error(`   Error: ${error.message}`);
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

    try {
      const { data, error } = await resend.emails.send({
        from: fromEmail,
        to: email,
        subject: subject,
        html: message + '<br><p>Srdačan pozdrav,<br>HopMe Tim</p>'
      });

      if (error) {
        console.error(`❌ Resend error: ${error.message}`);
        throw new Error(error.message);
      }

      console.log(`✅ Approval email sent successfully to: ${email}`);
      return data;
    } catch (error) {
      console.error(`❌ Failed to send approval email to: ${email}`);
      console.error(`   Error: ${error.message}`);
      throw error;
    }
  }

  static async sendPasswordResetEmail(email, token, firstName) {
    console.log(`📧 Attempting to send password reset email to: ${email}`);
    
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    
    try {
      const { data, error } = await resend.emails.send({
        from: fromEmail,
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
      });

      if (error) {
        console.error(`❌ Resend error: ${error.message}`);
        throw new Error(error.message);
      }

      console.log(`✅ Password reset email sent successfully to: ${email}`);
      return data;
    } catch (error) {
      console.error(`❌ Failed to send password reset email to: ${email}`);
      console.error(`   Error: ${error.message}`);
      throw error;
    }
  }
}

export default EmailService;