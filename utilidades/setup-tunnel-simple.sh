#!/bin/bash

echo "🚀 Configuración Simplificada del Túnel Cloudflare"
echo "================================================="

echo "📋 Método simplificado usando token temporal"
echo ""

# Verificar si ya hay un token en el .env
ENV_FILE="utilidades/.env"
if [ -f "$ENV_FILE" ] && grep -q "CLOUDFLARE_TUNNEL_TOKEN" "$ENV_FILE"; then
    CURRENT_TOKEN=$(grep "CLOUDFLARE_TUNNEL_TOKEN" "$ENV_FILE" | cut -d'"' -f2)
    if [ ! -z "$CURRENT_TOKEN" ] && [ "$CURRENT_TOKEN" != "your_token_here" ]; then
        echo "⚠️  Ya hay un token configurado. ¿Quieres continuar y reemplazarlo?"
        echo "Token actual: ${CURRENT_TOKEN:0:20}..."
        read -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
    fi
fi

echo ""
echo "🔧 PASO 1: Crear túnel manualmente en Cloudflare"
echo ""
echo "Ve a https://one.dash.cloudflare.com/ y sigue estos pasos:"
echo ""
echo "1. Ve a 'Networks' → 'Tunnels'"
echo "2. Click 'Create a tunnel'"
echo "3. Selecciona 'Cloudflared' como tipo"
echo "4. Nombra el túnel: 'midominio-tunnel'"
echo "5. Selecciona tu dominio: midominio.com"
echo "6. Agrega las siguientes rutas públicas:"
echo "   - Subdomain: chatwoot → Service: http://chatwoot:3000"
echo "   - Subdomain: api → Service: http://evolution_api:8080"
echo "   - Subdomain: n8n → Service: http://n8n:5678"
echo "   - Subdomain: monitoring → Service: http://grafana:3000"
echo "   - Subdomain: webui → Service: http://open-webui:8080"
echo "   - Subdomain: metrics → Service: http://prometheus:9090"
echo "7. Guarda el túnel y copia el token que aparece"
echo ""
read -p "Presiona Enter cuando hayas completado la configuración en Cloudflare..."

echo ""
echo "🔑 PASO 2: Ingresar el token"

echo "Pega el token que copiaste de Cloudflare:"
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo "❌ Token vacío"
    exit 1
fi

echo ""
echo "💾 PASO 3: Actualizando configuración..."

# Crear backup
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Actualizar token
if [ -f "$ENV_FILE" ]; then
    sed -i "s/CLOUDFLARE_TUNNEL_TOKEN=.*/CLOUDFLARE_TUNNEL_TOKEN=\"$TOKEN\"/" "$ENV_FILE"
else
    # Crear archivo si no existe
    cat > "$ENV_FILE" << EOF
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_SCHEMA=public
DB_POSTGRESDB_PASSWORD="your_db_password_here"
GENERIC_TIMEZONE=UTC
TZ=UTC
POSTGRES_DB=n8n
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD="your_db_password_here"
QDRANT__SERVICE__API_KEY="your_qdrant_api_key_here"
QDRANT_STORAGE=/qdrant/storage
QDRANT_LOG_LEVEL=DEBUG
QDRANT_LOG_FILE=/qdrant/storage/qdrant.log
QDRANT_HTTP_PORT=6333
PORT=5081
INDEX_TYPE=serverless
VECTOR_TYPE=dense
DIMENSION=2
METRIC=cosine
IP_LOCAL="127.0.0.1"
CLOUDFLARE_TUNNEL_TOKEN="$TOKEN"
EOF
fi

echo "✅ Configuración actualizada"

echo ""
echo "🎉 ¡CONFIGURACIÓN COMPLETADA!"
echo ""
echo "🚀 Iniciar el túnel:"
echo "   docker compose -f utilidades/docker-compose.yml up -d cloudflared"
echo ""
echo "📊 Verificar estado:"
echo "   docker logs cloudflared"
echo ""
echo "🔒 URLs seguras disponibles:"
echo "   • https://chatwoot.midominio.com"
echo "   • https://api.midominio.com"
echo "   • https://n8n.midominio.com"
echo "   • https://monitoring.midominio.com"
echo "   • https://webui.midominio.com"
echo "   • https://metrics.midominio.com"
echo ""
echo "⚠️  IMPORTANTE: Asegúrate de que los registros DNS CNAME estén configurados en Cloudflare"
echo "   apuntando al túnel que creaste."