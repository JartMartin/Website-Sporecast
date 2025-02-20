import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables');
}

// Create a single instance of the Supabase client
export const supabase = createClient(supabaseUrl, supabaseKey);

// Helper to handle Supabase errors
export const handleSupabaseError = (error: any): string | null => {
  if (!error) return null;
  
  if (error.message === 'Failed to fetch') {
    return 'Network connection error. Please check your internet connection and try again.';
  }
  
  if (error.code === 'PGRST116' || error.code === '406') {
    // Not an error - just means no rows found
    return null;
  }
  
  if (error.code === 'PGRST301') {
    return 'Database connection error. Please try again later.';
  }

  if (error.code === '23505') {
    return 'This alert already exists.';
  }

  if (error.code === '22P02') {
    return 'Invalid data format. Please check your input and try again.';
  }
  
  return error.message || 'An unexpected error occurred';
};