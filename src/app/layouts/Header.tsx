import { useAuth } from '@/shared/hooks/useAuth';
import { ThemeToggle } from '@/components/shared/ThemeToggle';
export function Header() { const { user } = useAuth(); return ( <header className="border-b px-4 py-2 flex justify-between items-center"> <h1 className="text-xl font-semibold">CareHome SaaS</h1> <div className="flex items-center gap-2"> <ThemeToggle /> <span className="text-sm">{user?.email}</span> </div> </header> ); }
