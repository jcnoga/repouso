export const getSubscription = async () => {
  return await supabase
    .from("subscriptions")
    .select("*, plans(*)")
    .single();
};