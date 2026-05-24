const { data } = await supabase
  .from("subscriptions")
  .select("*, plans(*)")
  .single();