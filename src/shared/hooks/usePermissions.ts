import { useAuth } from './useAuth';
const permissions: Record<string, number> = {
  admin: 10,
  enfermeiro: 5,
  financeiro: 4,
  cuidador: 2,
  recepcao: 1,
};

return permissions[user.role];
export function usePermissions() {
  const { user } = useAuth();
  const role = user?.user_metadata?.role || 'recepcao';
  const hasRole = (required: string) => roleHierarchy[role] >= roleHierarchy[required];
  return { role, hasRole, isAdmin: role === 'admin' };
}
