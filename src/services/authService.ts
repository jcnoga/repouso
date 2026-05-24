export const login = async (email: string, password: string) => {
  return await supabase.auth.signInWithPassword({ email, password });
};