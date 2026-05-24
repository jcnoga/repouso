import { supabase } from "@/lib/supabase";

export function useAuth() {
  async function signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      throw error;
    }
  }

  return {
    signIn,
  };
}
