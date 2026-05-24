import { useAuth } from './useAuth';
const roleHierarchy = { admin: 5, enfermeiro: 4, financeiro: 3, cuidador: 2, recepcao: 1 };
export function usePermissions() {
  const { user } = useAuth();
  const role = user?.user_metadata?.role || 'recepcao';
  const hasRole = (required: string) => roleHierarchy[role] >= roleHierarchy[required];
  return { role, hasRole, isAdmin: role === 'admin' };
}
