import { supabase } from "../../lib/supabase";

export async function handler(event: any) {
  if (event.type === "checkout.session.completed") {
    const session = event.data.object;

    await supabase.from("subscriptions").insert({
      tenant_id: session.metadata.tenant_id,
      plan_id: session.metadata.plan_id,
      status: "active",
    });
  }
}