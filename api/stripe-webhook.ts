import { supabase } from "../lib/supabase";

export async function handleStripeEvent(event: any) {
  if (event.type === "checkout.session.completed") {
    const session = event.data.object;

    const tenant_id = session.metadata.tenant_id;
    const plan_id = session.metadata.plan_id;

    await supabase.from("subscriptions").insert({
      tenant_id,
      plan_id,
      status: "active",
      started_at: new Date(),
    });
  }

  if (event.type === "invoice.payment_failed") {
    const subscriptionId = event.data.object.id;

    await supabase
      .from("subscriptions")
      .update({ status: "past_due" })
      .eq("stripe_subscription_id", subscriptionId);
  }
}