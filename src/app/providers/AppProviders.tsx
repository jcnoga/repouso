import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from './ThemeProvider';
import { AuthProvider } from './AuthProvider';
import { Toaster } from 'sonner';
const queryClient = new QueryClient({ defaultOptions: { queries: { staleTime: 1000 * 60 * 5 } } });
export function AppProviders({ children }) { return ( <QueryClientProvider client={queryClient}> <ThemeProvider defaultTheme="light" storageKey="carehome-theme"> <AuthProvider> {children} <Toaster position="top-right" /> </AuthProvider> </ThemeProvider> </QueryClientProvider> ); }
