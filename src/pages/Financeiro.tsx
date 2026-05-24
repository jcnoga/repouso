// repouso/src/pages/Financeiro.tsx
const { data } = await supabase
  .from("payments")
  .select("*");