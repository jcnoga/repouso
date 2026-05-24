  import { supabase } from "../lib/supabase";
export const login = async (email: string, password: string) => {
  return await supabase.auth.signInWithPassword({ email, password });
  import { supabase } from "../lib/supabase";
};