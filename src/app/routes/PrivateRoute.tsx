import { Navigate } from "react-router-dom";

import { supabase } from "@/lib/supabase";

export async function isAuthenticated() {
  const {
    data: { session },
  } = await supabase.auth.getSession();

  return !!session;
}

export function PrivateRoute({
  children,
}: {
  children: React.ReactNode;
}) {
  const session =
    localStorage.getItem(
      "sb-uijavpqohwpscubmninu-auth-token"
    );

  if (!session) {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
}