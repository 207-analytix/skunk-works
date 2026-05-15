import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing authorization header" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  let credentialName: string;
  try {
    const body = await req.json();
    credentialName = body.credential_name;
    if (!credentialName) throw new Error("Missing credential_name");
  } catch (e) {
    return new Response(JSON.stringify({ error: "Invalid request body. Expected { credential_name: string }" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  // User-scoped client — RLS enforces role access
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } }
  );

  const { data: credential, error: credError } = await userClient
    .schema("broker")
    .from("credentials")
    .select("id, name, description, vault_secret_id, required_role, scope")
    .eq("name", credentialName)
    .single();

  if (credError || !credential) {
    return new Response(JSON.stringify({ error: "Credential not found or access denied" }), {
      status: 403,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Service-role client — fetch secret from Vault server-side only
  const adminClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: secret, error: vaultError } = await adminClient
    .schema("vault")
    .from("decrypted_secrets")
    .select("decrypted_secret")
    .eq("id", credential.vault_secret_id)
    .single();

  if (vaultError || !secret) {
    return new Response(JSON.stringify({ error: "Failed to retrieve secret from Vault" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(
    JSON.stringify({
      credential_name: credential.name,
      description: credential.description,
      scope: credential.scope,
      secret: secret.decrypted_secret,
    }),
    {
      status: 200,
      headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
    }
  );
});
