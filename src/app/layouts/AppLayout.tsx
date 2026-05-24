import { ReactNode } from "react";

import { Link } from "react-router-dom";

import { supabase } from "@/lib/supabase";

export function AppLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <div
      style={{
        display: "flex",
        minHeight: "100vh",
      }}
    >
      <aside
        style={{
          width: 240,
          background: "#111",
          color: "#fff",
          padding: 20,
        }}
      >
        <h2>CareHome SaaS</h2>

        <button
          onClick={async () => {
            await supabase.auth.signOut();

            location.href = "/login";
          }}
        >
          Sair
        </button>

        <nav
          style={{
            display: "flex",
            flexDirection: "column",
            gap: 12,
            marginTop: 30,
          }}
        >
          <Link to="/">Dashboard</Link>

          <Link to="/agenda">
            Agenda
          </Link>

          <Link to="/financeiro">
            Financeiro
          </Link>
		  
		  <Link to="/residentes">
            Residentes
          </Link>

          <Link to="/crm">CRM</Link>
        </nav>
      </aside>

      <main
        style={{
          flex: 1,
          padding: 30,
        }}
      >
        {children}
      </main>
    </div>
  );
}