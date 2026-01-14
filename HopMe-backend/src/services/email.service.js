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
    const subject = 'HopMe - Verification email address';
    const html = `
      <h2>Hello ${firstName},</h2>
      <p>Thank you for registering on the HopMe platform!</p>
      <p>Please verify your email address by clicking the button below:</p>
      <a href="${verificationUrl}" 
         style="background-color: #4CAF50; color: white; padding: 14px 20px; 
                text-decoration: none; display: inline-block; border-radius: 4px;">
        Verify Email
      </a>
      <p>Or copy the following link into your browser:</p>
      <p>${verificationUrl}</p>
      <p>The link expires in 24 hours.</p>
      <br>
      <p>Best regards,<br>HopMe Team</p>
    `;

    return this.sendEmailJS(email, subject, html);
  }

  static async sendApprovalEmail(email, firstName, isApproved) {
    console.log(`📧 Attempting to send approval email to: ${email} (approved: ${isApproved})`);
    
    const subject = isApproved 
      ? 'HopMe - Your account has been approved!' 
      : 'HopMe - Your account status';
    
    let message = '';
    if (isApproved) {
      message = `
        <h2>Hello ${firstName},</h2>
        <p>Your account has been approved by the administrator!</p>
        <p>You can now log in and use all the features of the HopMe platform.</p>
        <a href="${process.env.FRONTEND_URL}/login" 
           style="background-color: #4CAF50; color: white; padding: 14px 20px; 
                  text-decoration: none; display: inline-block; border-radius: 4px;">
          Login
        </a>
      `;
    } else {
      message = `
        <h2>Hello ${firstName},</h2>
        <p>Sorry, but your registration request has not been approved.</p>
        <p>For more information, please contact our customer support.</p>
      `;
    }
    
    const html = message + '<br><p>Best regards,<br>HopMe Team</p>';
    return this.sendEmailJS(email, subject, html);
  }

  static async sendPasswordResetEmail(email, token, firstName) {
    console.log(`📧 Attempting to send password reset email to: ${email}`);
    
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    const subject = 'HopMe - Password Reset';
    const html = `
      <h2>Hello ${firstName},</h2>
      <p>We have received a request to reset your password.</p>
      <p>Click the button below to reset your password:</p>
      <a href="${resetUrl}" 
         style="background-color: #2196F3; color: white; padding: 14px 20px; 
                text-decoration: none; display: inline-block; border-radius: 4px;">
        Reset Password
      </a>
      <p>The link expires in 1 hour.</p>
      <p>If you did not request this change, ignore this email.</p>
      <br>
      <p>Best regards,<br>HopMe Team</p>
    `;

    return this.sendEmailJS(email, subject, html);
  }
}

export default EmailService;