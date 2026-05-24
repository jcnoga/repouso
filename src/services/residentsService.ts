import { supabase } from "../lib/supabase";

export const getResidents = async () => {
  return await supabase.from("residents").select("*");
};

