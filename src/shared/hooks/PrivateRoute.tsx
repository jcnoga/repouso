import { Navigate } from "react-router-dom";

import { useEffect, useState } from "react";

import { supabase } from "@/lib/supabase";

export function PrivateRoute({
  children,
}: {
  children: React.ReactNode;
}) {
  const [loading, setLoading] =
    useState(true);

  const [authenticated, setAuthenticated] =
    useState(false);

  useEffect(() => {
    async function checkUser() {
      const {
        data: { session },
      } = await supabase.auth.getSession();

      setAuthenticated(!!session);

      setLoading(false);
    }

    checkUser();
  }, []);

  if (loading) {
    return <div>Carregando...</div>;
  }

  if (!authenticated) {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
}