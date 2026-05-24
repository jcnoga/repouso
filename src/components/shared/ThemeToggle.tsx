import { useTheme } from '@/app/providers/ThemeProvider';
import { Moon, Sun } from 'lucide-react';
export function ThemeToggle() { const { theme, setTheme } = useTheme(); return ( <button onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}> {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />} </button> ); }
