import { create } from 'zustand';
import { supabase } from '../lib/supabase';
interface AuthState { user: any; session: any; isLoading: boolean; setUser: (user: any) => void; setSession: (session: any) => void; setLoading: (loading: boolean) => void; initialize: () => Promise<void>; }
export const useAuthStore = create<AuthState>((set) => ({
  user: null, session: null, isLoading: true,
  setUser: (user) => set({ user }),
  setSession: (session) => set({ session }),
  setLoading: (loading) => set({ isLoading: loading }),
  initialize: async () => {
    set({ isLoading: true });
    const { data } = await supabase.auth.getSession();
    set({ user: data.session?.user ?? null, session: data.session, isLoading: false });
    supabase.auth.onAuthStateChange((_event, session) => set({ session, user: session?.user ?? null }));
  },
}));
