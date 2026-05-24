import { supabase } from "../lib/supabase";

export const getDashboardData = async () => {
  const residents = await supabase.from("residents").select("*");

  const payments = await supabase.from("payments").select("*");

  const subscription = await supabase
    .from("subscriptions")
    .select("*, plans(*)")
    .single();

  return {
    residents: residents.data,
    payments: payments.data,
    subscription: subscription.data,
  };
};