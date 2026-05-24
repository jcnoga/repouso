import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '@/shared/stores/authStore';
export function PrivateRoute() { const { user, isLoading } = useAuthStore(); if (isLoading) return <div>Carregando...</div>; return user ? <Outlet /> : <Navigate to="/login" replace />; }
