import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { PrivateRoute } from './PrivateRoute';
import { AppLayout } from '../layouts/AppLayout';
import { LoginPage } from '@/modules/auth/LoginPage';
import { DashboardPage } from '@/modules/dashboards/views/DashboardPage';
import { ResidentsPage } from '@/modules/residents/views/ResidentsPage';
import { MedicationsPage } from '@/modules/medications/views/MedicationsPage';
import { CareSchedulePage } from '@/modules/care-schedule/views/CareSchedulePage';
import { FinancialDashboard } from '@/modules/financial/views/FinancialDashboard';
import { FamiliesPage } from '@/modules/crm-family/views/FamiliesPage';
export function AppRoutes() {
  return ( <BrowserRouter> <Routes> <Route path="/login" element={<LoginPage />} /> <Route element={<PrivateRoute />}> <Route element={<AppLayout />}> <Route path="/" element={<DashboardPage />} /> <Route path="/residentes" element={<ResidentsPage />} /> <Route path="/medicacoes" element={<MedicationsPage />} /> <Route path="/agenda" element={<CareSchedulePage />} /> <Route path="/financeiro" element={<FinancialDashboard />} /> <Route path="/familiares" element={<FamiliesPage />} /> </Route> </Route> </Routes> </BrowserRouter> );
}
