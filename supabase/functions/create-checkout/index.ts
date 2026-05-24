import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function handler(req: any) {
  const { tenant_id, plan_id } = req.body;

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",

    line_items: [
      {
        price: plan_id,
        quantity: 1,
      },
    ],

    metadata: {
      tenant_id,
      plan_id,
    },
  });

  return { url: session.url };
}