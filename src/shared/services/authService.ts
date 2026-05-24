import { supabase } from '../lib/supabase';
export const authService = {
  async signIn(email: string, password: string) { const { data, error } = await supabase.auth.signInWithPassword({ email, password }); if (error) throw error; return data; },
  async signOut() { const { error } = await supabase.auth.signOut(); if (error) throw error; },
  async getCurrentUser() { const { data } = await supabase.auth.getUser(); return data.user; },
  async getCurrentProfile() { const user = await this.getCurrentUser(); if (!user) return null; const { data, error } = await supabase.from('profiles').select('*, tenants(*)').eq('id', user.id).single(); if (error) throw error; return data; },
};
