import { Link } from 'react-router-dom';
import { LayoutDashboard, Users, Pill, Calendar, DollarSign, Heart, LogOut } from 'lucide-react';
import { useAuth } from '@/shared/hooks/useAuth';
import { usePermissions } from '@/shared/hooks/usePermissions';
export function Sidebar() {
  const { signOut } = useAuth();
  const { role } = usePermissions();
  const items = [
    { path: '/', label: 'Dashboard', icon: LayoutDashboard, roles: ['admin','enfermeiro','cuidador','financeiro','recepcao'] },
    { path: '/residentes', label: 'Residentes', icon: Users, roles: ['admin','enfermeiro','cuidador','recepcao'] },
    { path: '/medicacoes', label: 'Medicações', icon: Pill, roles: ['admin','enfermeiro','cuidador'] },
    { path: '/agenda', label: 'Agenda', icon: Calendar, roles: ['admin','enfermeiro','cuidador'] },
    { path: '/financeiro', label: 'Financeiro', icon: DollarSign, roles: ['admin','financeiro'] },
    { path: '/familiares', label: 'CRM Familiar', icon: Heart, roles: ['admin','enfermeiro','recepcao'] },
  ];
  const filtered = items.filter(i => i.roles.includes(role));
  return ( <aside className="w-64 border-r bg-card flex flex-col"> <div className="p-4 font-bold text-lg">CareHome</div> <nav className="flex-1 flex flex-col gap-2 p-2"> {filtered.map(item => ( <Link key={item.path} to={item.path} className="flex items-center gap-2 p-2 rounded hover:bg-accent"> <item.icon className="h-4 w-4" /> {item.label} </Link> ))} </nav> <div className="p-2 border-t"> <button onClick={() => signOut()} className="flex items-center gap-2 p-2 w-full rounded hover:bg-accent"> <LogOut className="h-4 w-4" /> Sair </button> </div> </aside> ); }
