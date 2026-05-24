export const getPayments = async () => {
  return await supabase.from("payments").select("*");
};