-- Create companies table
CREATE TABLE companies (
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

-- Create company_invites table
CREATE TABLE company_invites (
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

-- Add company_id to profiles
ALTER TABLE profiles
ADD COLUMN company_id uuid REFERENCES companies(id),
ADD COLUMN company_role text CHECK (company_role IN ('admin', 'user'));

-- Enable RLS
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_invites ENABLE ROW LEVEL SECURITY;

-- Create policies for companies
CREATE POLICY "Companies are viewable by their members"
  ON companies FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Companies are updatable by admins"
  ON companies FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create policies for company_invites
CREATE POLICY "Invites are viewable by company admins"
  ON company_invites FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

CREATE POLICY "Invites are creatable by company admins"
  ON company_invites FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

CREATE POLICY "Invites are updatable by company admins"
  ON company_invites FOR UPDATE
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id 
      FROM profiles 
      WHERE id = auth.uid() 
      AND company_role = 'admin'
    )
  );

-- Create function to generate random invite code
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

-- Create function to handle company creation
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

-- Create trigger for company creation
CREATE TRIGGER on_company_creation
  BEFORE INSERT ON companies
  FOR EACH ROW
  EXECUTE FUNCTION handle_company_creation();

-- Create function to handle invite creation
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

-- Create trigger for invite creation
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