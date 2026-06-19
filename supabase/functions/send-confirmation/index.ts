import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createTransport } from "npm:nodemailer@6";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface Pick {
  nombre: string;
  bandera: string;
  grupo: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email, picks } = (await req.json()) as {
      email: string;
      picks: Pick[];
    };

    const port = Number(Deno.env.get("SMTP_PORT") ?? "587");

    const transporter = createTransport({
      host: Deno.env.get("SMTP_HOST"),
      port,
      secure: port === 465,
      auth: {
        user: Deno.env.get("SMTP_USER"),
        pass: Deno.env.get("SMTP_PASS"),
      },
    });

    await transporter.sendMail({
      from: `"Mundial 2026 Picks" <${Deno.env.get("SMTP_FROM")}>`,
      to: email,
      subject: "🏆 Tu selección para el Mundial 2026 está confirmada",
      html: buildHtml(email, picks),
    });

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

function buildHtml(email: string, picks: Pick[]): string {
  const byGroup = picks.reduce((acc, p) => {
    if (!acc[p.grupo]) acc[p.grupo] = [];
    acc[p.grupo].push(p);
    return acc;
  }, {} as Record<string, Pick[]>);

  const rows = Object.keys(byGroup)
    .sort()
    .map((grupo) => {
      const teams = byGroup[grupo]
        .map(
          (p) => `
          <tr>
            <td style="padding:8px 14px;font-size:24px;line-height:1;">${p.bandera}</td>
            <td style="padding:8px 4px;color:#e8e8e8;font-size:15px;font-weight:500;">${p.nombre}</td>
            <td style="padding:8px 14px;text-align:right;">
              <span style="background:#8B0000;color:white;padding:2px 9px;border-radius:5px;font-size:11px;font-weight:700;letter-spacing:.5px;">G${grupo}</span>
            </td>
          </tr>`
        )
        .join("");

      return `
        <tr>
          <td colspan="3" style="padding:14px 14px 4px;color:#666;font-size:11px;letter-spacing:1.5px;border-top:1px solid #2a2a2a;">GRUPO ${grupo}</td>
        </tr>
        ${teams}`;
    })
    .join("");

  return `
    <!DOCTYPE html>
    <html lang="es">
    <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
    <body style="margin:0;padding:0;background:#0D1117;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" style="padding:32px 16px;">
            <table width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background:#161B22;border-radius:16px;overflow:hidden;border:1px solid #30363D;">

              <!-- Header -->
              <tr>
                <td style="background:linear-gradient(135deg,#8B0000 0%,#C62828 100%);padding:28px 24px;text-align:center;">
                  <div style="font-size:40px;margin-bottom:8px;">🏆</div>
                  <h1 style="color:white;margin:0;font-size:22px;font-weight:800;letter-spacing:-0.5px;">Mundial 2026</h1>
                  <p style="color:rgba(255,255,255,0.75);margin:6px 0 0;font-size:13px;">Selección confirmada para ${email}</p>
                </td>
              </tr>

              <!-- Intro -->
              <tr>
                <td style="padding:20px 24px 8px;">
                  <p style="color:#aaa;font-size:13px;margin:0;line-height:1.6;">
                    Tu selección de <strong style="color:white;">16 países</strong> para el Mundial 2026 quedó registrada. Aquí están tus picks:
                  </p>
                </td>
              </tr>

              <!-- Picks table -->
              <tr>
                <td style="padding:8px 10px 16px;">
                  <table width="100%" cellpadding="0" cellspacing="0">
                    ${rows}
                  </table>
                </td>
              </tr>

              <!-- Footer -->
              <tr>
                <td style="padding:16px 24px;border-top:1px solid #30363D;text-align:center;">
                  <p style="color:#444;font-size:11px;margin:0;">
                    Enviado desde <span style="color:#666;">Mundial 2026 Picks</span>
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>`;
}
