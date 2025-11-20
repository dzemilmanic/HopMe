import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: process.env.EMAIL_PORT,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

class EmailService {
  static async sendVerificationEmail(email, token, firstName) {
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

    await transporter.sendMail(mailOptions);
  }

  static async sendApprovalEmail(email, firstName, isApproved) {
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

    await transporter.sendMail(mailOptions);
  }

  static async sendPasswordResetEmail(email, token, firstName) {
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

    await transporter.sendMail(mailOptions);
  }
}

export default EmailService;