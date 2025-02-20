-- Drop existing policies first
DROP POLICY IF EXISTS "Companies are viewable by their members" ON companies;
DROP POLICY IF EXISTS "Companies are updatable by admins" ON companies;
DROP POLICY IF EXISTS "Companies are insertable by public" ON companies;
DROP POLICY IF EXISTS "Companies are insertable by anyone" ON companies;
DROP POLICY IF EXISTS "Invites are viewable by public" ON company_invites;
DROP POLICY IF EXISTS "Invites are creatable by company admins" ON company_invites;
DROP POLICY IF EXISTS "Invites are updatable by company admins" ON company_invites;

-- Create or update companies table
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  industry text,
  subscription_status text NOT NULL DEFAULT 'trial' CHECK (subscription_status IN ('trial', 'active', 'cancelled')),
  trial_ends_at timestamptz,
  stripe_customer_id text,
  stripe_subscription_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create or update company_invites table
CREATE TABLE IF NOT EXISTS company_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
  invite_code text NOT NULL UNIQUE,
  email text,
  company_role text NOT NULL CHECK (company_role IN ('admin', 'user')),
  expires_at timestamptz NOT NULL,
  created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  used_at timestamptz,
  CONSTRAINT invite_code_length CHECK (char_length(invite_code) = 8)
);

-- Add company-related columns to profiles if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'company_id') THEN
    ALTER TABLE profiles ADD COLUMN company_id uuid REFERENCES companies(id);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'company_role') THEN
    ALTER TABLE profiles ADD COLUMN company_role text CHECK (company_role IN ('admin', 'user'));
  END IF;
END $$;

-- Enable RLS
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_invites ENABLE ROW LEVEL SECURITY;

-- Create new policies with unique names
CREATE POLICY "Companies insertable during registration"
  ON companies FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Companies visible to members and invitees"
  ON companies FOR SELECT
  TO public
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 
      FROM company_invites 
      WHERE company_id = companies.id 
      AND used_at IS NULL 
      AND expires_at > now()
    )
  );

CREATE POLICY "Companies updatable by company admins"
  ON companies FOR UPDATE
  TO public
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create policies for company_invites with unique names
CREATE POLICY "Invites visible to admins and invitees"
  ON company_invites FOR SELECT
  TO public
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
    OR
    (used_at IS NULL AND expires_at > now())
  );

CREATE POLICY "Invites creatable by company admins only"
  ON company_invites FOR INSERT
  TO public
  WITH CHECK (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

CREATE POLICY "Invites updatable by company admins only"
  ON company_invites FOR UPDATE
  TO public
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create or replace functions
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  chars text[] := '{A,B,C,D,E,F,G,H,J,K,L,M,N,P,Q,R,S,T,U,V,W,X,Y,Z,2,3,4,5,6,7,8,9}';
  result text := '';
  i integer := 0;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  END LOOP;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION handle_company_creation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Set trial end date to 5 days from now
  NEW.trial_ends_at := now() + interval '5 days';
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION handle_invite_creation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Generate unique invite code
  LOOP
    NEW.invite_code := generate_invite_code();
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM company_invites WHERE invite_code = NEW.invite_code
    );
  END LOOP;
  
  -- Set expiry to 7 days from now
  NEW.expires_at := now() + interval '7 days';
  
  RETURN NEW;
END;
$$;

-- Drop and recreate triggers
DROP TRIGGER IF EXISTS on_company_creation ON companies;
DROP TRIGGER IF EXISTS on_invite_creation ON company_invites;

CREATE TRIGGER on_company_creation
  BEFORE INSERT ON companies
  FOR EACH ROW
  EXECUTE FUNCTION handle_company_creation();

CREATE TRIGGER on_invite_creation
  BEFORE INSERT ON company_invites
  FOR EACH ROW
  EXECUTE FUNCTION handle_invite_creation();

-- Add helpful comments
COMMENT ON TABLE companies IS 'Stores company information and subscription status';
COMMENT ON TABLE company_invites IS 'Stores company invites for new users';
COMMENT ON COLUMN companies.subscription_status IS 'Current subscription status (trial, active, cancelled)';
COMMENT ON COLUMN companies.trial_ends_at IS 'When the trial period ends';
COMMENT ON COLUMN company_invites.invite_code IS 'Unique 8-character invite code';
COMMENT ON COLUMN company_invites.company_role IS 'Role to be assigned to the invited user';
COMMENT ON COLUMN profiles.company_id IS 'Company the user belongs to';
COMMENT ON COLUMN profiles.company_role IS 'User role within the company (admin or user)';