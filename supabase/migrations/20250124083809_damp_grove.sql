-- Keep only the specified user and their related data
DO $$
DECLARE
  v_target_email text := 'hoihoi@live.nl';
  v_target_user_id uuid;
BEGIN
  -- Get the target user's ID
  SELECT id INTO v_target_user_id
  FROM auth.users
  WHERE email = v_target_email;

  -- Delete all other users' portfolio entries
  DELETE FROM commodity_portfolio
  WHERE user_id != v_target_user_id;

  -- Delete all other users' alerts
  DELETE FROM commodity_alerts
  WHERE user_id != v_target_user_id;

  -- Delete all other profiles
  DELETE FROM profiles
  WHERE id != v_target_user_id;

  -- Delete all other users from auth.users
  DELETE FROM auth.users
  WHERE email != v_target_email;
END $$;