#!/bin/bash

echo "🚀 Configuración de Cloudflare Zero Trust para el proyecto"
echo "========================================================"

# Verificar que cloudflared esté instalado
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared no está instalado. Instálalo desde: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/"
    exit 1
fi

echo "✅ cloudflared está instalado"

# Verificar login en Cloudflare
echo "🔐 Verificando autenticación en Cloudflare..."
if ! cloudflared tunnel login; then
    echo "❌ Error en la autenticación. Asegúrate de tener una cuenta de Cloudflare Teams."
    exit 1
fi

echo "✅ Autenticación exitosa"

# Crear túnel si no existe
TUNNEL_NAME="midominio-tunnel"
echo "🔧 Creando/verificando túnel: $TUNNEL_NAME"

# Verificar si el túnel ya existe
if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
    echo "✅ Túnel '$TUNNEL_NAME' ya existe"
else
    echo "📝 Creando nuevo túnel..."
    cloudflared tunnel create "$TUNNEL_NAME"
fi

# Obtener el ID del túnel
TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')

if [ -z "$TUNNEL_ID" ]; then
    echo "❌ Error: No se pudo obtener el ID del túnel"
    exit 1
fi

echo "✅ ID del túnel: $TUNNEL_ID"

# Configurar DNS para los subdominios
DOMAINS=(
    "chatwoot.midominio.com"
    "api.midominio.com"
    "webui.midominio.com"
    "monitoring.midominio.com"
    "metrics.midominio.com"
    "n8n.midominio.com"
)

echo "🌐 Configurando registros DNS..."
for domain in "${DOMAINS[@]}"; do
    echo "  - Configurando $domain"
    cloudflared tunnel route dns "$TUNNEL_NAME" "$domain"
done

echo "✅ Configuración DNS completada"

# Crear token del túnel
echo "🔑 Generando token del túnel..."
TOKEN=$(cloudflared tunnel token "$TUNNEL_NAME")

if [ -z "$TOKEN" ]; then
    echo "❌ Error: No se pudo generar el token"
    exit 1
fi

echo "✅ Token generado"

# Actualizar archivo .env
ENV_FILE="utilidades/.env"
if [ -f "$ENV_FILE" ]; then
    # Reemplazar el token existente
    sed -i "s/CLOUDFLARE_TUNNEL_TOKEN=.*/CLOUDFLARE_TUNNEL_TOKEN=\"$TOKEN\"/" "$ENV_FILE"
    echo "✅ Token actualizado en $ENV_FILE"
else
    echo "❌ Archivo $ENV_FILE no encontrado"
    exit 1
fi

echo ""
echo "🎉 Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Reinicia los servicios: docker compose down && docker compose up -d"
echo "2. Verifica que cloudflared esté funcionando: docker logs cloudflared"
echo "3. Configura políticas de Zero Trust en https://one.dash.cloudflare.com/"
echo ""
echo "🔒 URLs seguras:"
echo "   • Chatwoot: https://chatwoot.midominio.com"
echo "   • Evolution API: https://api.midominio.com"
echo "   • Open WebUI: https://webui.midominio.com"
echo "   • Grafana: https://monitoring.midominio.com"
echo "   • Prometheus: https://metrics.midominio.com"
echo "   • N8N: https://n8n.midominio.com"