import axios from 'axios';

class EmailService {
  static async sendEmailJS(toEmail, subject, htmlMessage) {
    const serviceId = process.env.EMAILJS_SERVICE_ID;
    const templateId = process.env.EMAILJS_TEMPLATE_ID;
    const publicKey = process.env.EMAILJS_PUBLIC_KEY;
    const privateKey = process.env.EMAILJS_PRIVATE_KEY;

    if (!serviceId || !templateId || !publicKey || !privateKey) {
      console.warn('⚠️ EmailJS credentials missing in .env');
      return;
    }

    const payload = {
      service_id: serviceId,
      template_id: templateId,
      user_id: publicKey,
      accessToken: privateKey,
      template_params: {
        to_email: toEmail,
        subject: subject,
        message_html: htmlMessage
      }
    };

    try {
      const response = await axios.post('https://api.emailjs.com/api/v1.0/email/send', payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });
      console.log(`✅ EmailJS sent successfully to: ${toEmail}`);
      return response.data;
    } catch (error) {
      console.error(`❌ EmailJS failed for: ${toEmail}`);
      console.error(`   Error: ${error.response?.data || error.message}`);
      throw error;
    }
  }

  static async sendVerificationEmail(email, token, firstName) {
    console.log(`📧 Attempting to send verification email to: ${email}`);
    
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    const subject = 'HopMe - Verifikacija email adrese';
    const html = `
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
    `;

    return this.sendEmailJS(email, subject, html);
  }

  static async sendApprovalEmail(email, firstName, isApproved) {
    console.log(`📧 Attempting to send approval email to: ${email} (approved: ${isApproved})`);
    
    const subject = isApproved 
      ? 'HopMe - Vaš nalog je odobren!' 
      : 'HopMe - Status vašeg naloga';
    
    let message = '';
    if (isApproved) {
      message = `
        <h2>Pozdrav ${firstName},</h2>
        <p>Vaš nalog je odobren od strane administratora!</p>
        <p>Sada možete da se prijavite i koristite sve funkcionalnosti HopMe platforme.</p>
        <a href="${process.env.FRONTEND_URL}/login" 
           style="background-color: #4CAF50; color: white; padding: 14px 20px; 
                  text-decoration: none; display: inline-block; border-radius: 4px;">
          Prijavite se
        </a>
      `;
    } else {
      message = `
        <h2>Pozdrav ${firstName},</h2>
        <p>Žao nam je, ali vaš zahtev za registraciju nije odobren.</p>
        <p>Za više informacija, molimo kontaktirajte našu korisničku podršku.</p>
      `;
    }
    
    const html = message + '<br><p>Srdačan pozdrav,<br>HopMe Tim</p>';
    return this.sendEmailJS(email, subject, html);
  }

  static async sendPasswordResetEmail(email, token, firstName) {
    console.log(`📧 Attempting to send password reset email to: ${email}`);
    
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    const subject = 'HopMe - Resetovanje lozinke';
    const html = `
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
    `;

    return this.sendEmailJS(email, subject, html);
  }
}

export default EmailService;