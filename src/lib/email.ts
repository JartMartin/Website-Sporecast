import emailjs from '@emailjs/browser';

interface EmailParams {
  to_email: string;
  to_name: string;
  meeting_date: string;
  meeting_time: string;
  meeting_link: string;
  language: string;
}

export async function sendMeetingConfirmation(params: EmailParams) {
  try {
    await emailjs.send(
      'YOUR_SERVICE_ID', // Get from EmailJS dashboard
      'YOUR_TEMPLATE_ID', // Get from EmailJS dashboard
      params,
      'YOUR_PUBLIC_KEY' // Get from EmailJS dashboard
    );
    return { success: true };
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error };
  }
}