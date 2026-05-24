import { useAuthStore } from '../stores/authStore';
import { authService } from '../services/authService';
import { useCallback } from 'react';
export function useAuth() {
  const { user, isLoading, setUser, setSession, setLoading } = useAuthStore();
  const signIn = useCallback(async (email: string, password: string) => { await authService.signIn(email, password); }, []);
  const signOut = useCallback(async () => { await authService.signOut(); }, []);
  return { user, isLoading, signIn, signOut, isAuthenticated: !!user };
}
