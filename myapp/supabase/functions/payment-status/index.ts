import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function respond(
  body: Record<string, unknown>,
  status = 200,
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return respond({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Missing server-side Supabase configuration.");
    return respond({ error: "Server configuration error" }, 500);
  }

  try {
    const body = await req.json();
    const externalId =
      typeof body.external_id === "string"
        ? body.external_id.trim()
        : "";

    if (
      !externalId ||
      externalId.length > 200 ||
      !/^[a-zA-Z0-9_-]+$/.test(externalId)
    ) {
      return respond({ error: "Invalid external_id" }, 400);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const { data, error } = await supabase
      .from("orders")
      .select("status")
      .eq("external_id", externalId)
      .maybeSingle();

    if (error) {
      console.error("Order status query failed:", error.message);
      return respond({ error: "Could not retrieve payment status" }, 500);
    }

    if (!data) {
      return respond({ error: "Order not found" }, 404);
    }

    const allowedStatuses = [
      "PAID",
      "PENDING",
      "FAILED",
      "EXPIRED",
      "CANCELLED",
      "CANCELED",
    ];

    const status = String(data.status ?? "PENDING").toUpperCase();

    return respond({
      external_id: externalId,
      status: allowedStatuses.includes(status) ? status : "PENDING",
    });
  } catch (error) {
    console.error("Payment status function error:", error);
    return respond({ error: "Invalid request" }, 400);
  }
});
