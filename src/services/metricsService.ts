  import { supabase } from "../lib/supabase";
export const getOccupancy = async () => {
  const { data: residents } = await supabase
    .from("residents")
    .select("*");

  const total = residents?.length || 0;

  const capacity = 50; // pode vir do plano

  return {
    total,
    capacity,
    occupancyRate: (total / capacity) * 100,
  };
};