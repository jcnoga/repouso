import { supabase } from "../lib/supabase";
export const getSubscription = async () => {
  return await supabase
    .from("subscriptions")
    .select("*, plans(*)")
    .single();
};