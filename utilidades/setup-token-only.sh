#!/bin/bash

echo "🔑 Configuración Rápida de Token Cloudflare"
echo "=========================================="

echo "Este script configura el token de Cloudflare Zero Trust."
echo "Necesitas crear el túnel manualmente en Cloudflare Dashboard."
echo ""

echo "📋 PASOS EN CLOUDFLARE DASHBOARD:"
echo ""
echo "1. Ve a: https://one.dash.cloudflare.com/"
echo "2. Networks → Tunnels"
echo "3. Click 'Create a tunnel'"
echo "4. Nombre: midominio-tunnel"
echo "5. Tipo: Cloudflared"
echo "6. Agregar rutas públicas:"
echo "   - chatwoot.midominio.com → http://chatwoot:3000"
echo "   - api.midominio.com → http://evolution_api:8080"
echo "   - n8n.midominio.com → http://n8n:5678"
echo "   - monitoring.midominio.com → http://grafana:3000"
echo "   - webui.midominio.com → http://open-webui:8080"
echo "   - metrics.midominio.com → http://prometheus:9090"
echo "7. Save tunnel"
echo "8. Copia el TOKEN que aparece"
echo ""

read -p "Presiona Enter cuando hayas creado el túnel y copiado el token..."

echo ""
echo "🔑 Pega el token de Cloudflare:"
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo "❌ Token vacío"
    exit 1
fi

echo ""
echo "💾 Actualizando configuración..."

# Backup
ENV_FILE="utilidades/.env"
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Actualizar token
sed -i "s/CLOUDFLARE_TUNNEL_TOKEN=.*/CLOUDFLARE_TUNNEL_TOKEN=\"$TOKEN\"/" "$ENV_FILE"

echo "✅ Token configurado"

echo ""
echo "🚀 Iniciando túnel..."
docker compose -f utilidades/docker-compose.yml up -d cloudflared

echo ""
echo "📊 Verificando..."
sleep 3
docker logs cloudflared --tail 5

echo ""
echo "🎉 ¡Listo!"
echo ""
echo "🔒 URLs disponibles:"
echo "   • https://chatwoot.midominio.com"
echo "   • https://api.midominio.com"
echo "   • https://n8n.midominio.com"
echo "   • https://monitoring.midominio.com"
echo "   • https://webui.midominio.com"
echo "   • https://metrics.midominio.com"