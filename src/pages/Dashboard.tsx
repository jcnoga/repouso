import { useEffect, useState } from "react";
import { getDashboardData } from "../services/dashboardService";

export function Dashboard() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    getDashboardData().then(setData);
  }, []);

  if (!data) return <div>Carregando...</div>;

  const totalResidents = data.residents?.length || 0;

  const totalRevenue =
    data.payments?.reduce((sum: number, p: any) => sum + Number(p.amount), 0) ||
    0;

  return (
    <div style={{ padding: 20 }}>
      <h1>📊 Dashboard Executivo</h1>

      <div>
        <h2>👵 Residentes</h2>
        <p>{totalResidents}</p>
      </div>

      <div>
        <h2>💰 Receita Total</h2>
        <p>R$ {totalRevenue}</p>
      </div>

      <div>
        <h2>💳 Plano Atual</h2>
        <p>{data.subscription?.plans?.name}</p>
      </div>

      <div>
        <h2>📌 Status Assinatura</h2>
        <p>{data.subscription?.status}</p>
      </div>
    </div>
  );
}