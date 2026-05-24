import { supabase } from "../lib/supabase";

export async function testConnection() {
  const { data, error } = await supabase.from("profiles").select("*");

  console.log("DATA:", data);
  console.log("ERROR:", error);
}