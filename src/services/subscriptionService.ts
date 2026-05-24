  import { supabase } from "../lib/supabase";
const { data } = await supabase
  .from("subscriptions")
  .select("*, plans(*)")
  .single();