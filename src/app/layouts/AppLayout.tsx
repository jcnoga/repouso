import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
export function AppLayout() { return ( <div className="flex h-screen"> <Sidebar /> <div className="flex flex-1 flex-col"> <Header /> <main className="flex-1 overflow-y-auto p-4"><Outlet /></main> </div> </div> ); }
