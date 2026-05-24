import { useEffect } from 'react';
import { useAuthStore } from '@/shared/stores/authStore';
export function AuthProvider({ children }) { const initialize = useAuthStore((state) => state.initialize); useEffect(() => { initialize(); }, []); return <>{children}</>; }
