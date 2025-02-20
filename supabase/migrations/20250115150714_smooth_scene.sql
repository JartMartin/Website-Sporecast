/*
  # Add role column to profiles table

  1. Changes
    - Add role column to profiles table
    - Add role validation using enum type
    - Update RLS policies

  2. Security
    - Maintain existing RLS policies
    - Add validation for role values
*/

-- Create enum type for roles
CREATE TYPE user_role AS ENUM (
  'purchase_department',
  'head_of_purchase',
  'board_management'
);

-- Add role column to profiles table
ALTER TABLE profiles 
ADD COLUMN role user_role;

-- Add role column validation
ALTER TABLE profiles
ADD CONSTRAINT valid_role CHECK (role IS NOT NULL);