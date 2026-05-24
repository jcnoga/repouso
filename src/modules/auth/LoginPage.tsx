import { useState } from 'react';
import { useAuth } from '@/shared/hooks/useAuth';
import { useNavigate } from 'react-router-dom';
export function LoginPage() {
  const { signIn } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const handleSubmit = async (e: React.FormEvent) => { e.preventDefault(); try { await signIn(email, password); navigate('/'); } catch (err) { alert('Erro no login'); } };
  return ( <div className="flex min-h-screen items-center justify-center"> <form onSubmit={handleSubmit} className="w-96 space-y-4 p-6 border rounded"> <h1 className="text-2xl font-bold">CareHome SaaS</h1> <input type="email" placeholder="E-mail" value={email} onChange={e=>setEmail(e.target.value)} className="w-full p-2 border rounded" required /> <input type="password" placeholder="Senha" value={password} onChange={e=>setPassword(e.target.value)} className="w-full p-2 border rounded" required /> <button type="submit" className="w-full bg-primary text-white p-2 rounded">Entrar</button> </form> </div> );
}
