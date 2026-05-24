import { ResidentsPage } from "@/modules/residents/views/ResidentsPage";
import { Routes, Route } from "react-router-dom";

import { AppLayout } from "../layouts/AppLayout";

import { PrivateRoute } from "./PrivateRoute";

import { LoginPage } from "@/modules/auth/LoginPage";

import { DashboardPage } from "@/modules/dashboards/views/DashboardPage";

import { CareSchedulePage } from "@/modules/care-schedule/views/CareSchedulePage";

import { FinancialDashboard } from "@/modules/financial/views/FinancialDashboard";

import { FamiliesPage } from "@/modules/crm-family/views/FamiliesPage";

export function AppRoutes() {
  return (
  
    <Routes>
      <Route
        path="/login"
        element={<LoginPage />}
      />

      <Route
        path="/"
        element={
          <PrivateRoute>
            <AppLayout>
              <DashboardPage />
            </AppLayout>
          </PrivateRoute>
        }
      />

      <Route
        path="/agenda"
        element={
          <PrivateRoute>
            <AppLayout>
              <CareSchedulePage />
            </AppLayout>
          </PrivateRoute>
        }
      />

      <Route
        path="/financeiro"
        element={
          <PrivateRoute>
            <AppLayout>
              <FinancialDashboard />
            </AppLayout>
          </PrivateRoute>
        }
      />

      <Route
        path="/crm"
        element={
          <PrivateRoute>
            <AppLayout>
              <FamiliesPage />
            </AppLayout>
          </PrivateRoute>
        }
      />
	  <Route
  path="/residentes"
  element={
    <PrivateRoute>
      <AppLayout>
        <ResidentsPage />
      </AppLayout>
    </PrivateRoute>
  }
/>
    </Routes>
  );
}