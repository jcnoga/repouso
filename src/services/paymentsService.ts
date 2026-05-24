import { supabase } from "../lib/supabase";

export async function getPayments() {
  const { data, error } = await supabase
    .from("payments")
    .select("*");

  if (error) {
    console.error(error);
    return [];
  }

  return data;
}