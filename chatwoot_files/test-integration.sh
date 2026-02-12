#!/bin/bash

echo "🔍 Diagnóstico de Integración Chatwoot ↔ Evolution API"
echo "===================================================="

# 1. Verificar estado de servicios
echo ""
echo "1. 📊 Estado de Servicios:"
echo "   Chatwoot: $(docker compose -f chatwoot_files/docker-compose.yml ps chatwoot --format json | jq -r '.[0].State' 2>/dev/null || echo 'Desconocido')"
echo "   Evolution API: $(docker compose -f evoapi_files/docker-compose.yml ps evolution-api --format json | jq -r '.[0].State' 2>/dev/null || echo 'Desconocido')"

# 2. Verificar configuración de Chatwoot
echo ""
echo "2. ⚙️ Configuración de Chatwoot:"
docker compose -f chatwoot_files/docker-compose.yml exec -T chatwoot bundle exec rails runner "
puts 'Inbox API:'
inbox = ActiveRecord::Base.connection.execute('SELECT id, name, channel_type FROM inboxes WHERE id = 1').first
puts \"  ID: #{inbox['id']}, Name: #{inbox['name']}, Type: #{inbox['channel_type']}\"

puts 'Channel API webhook:'
channel = ActiveRecord::Base.connection.execute('SELECT webhook_url FROM channel_api WHERE id = 1').first
puts \"  URL: #{channel['webhook_url']}\"
" 2>/dev/null

# 3. Verificar configuración de Evolution API
echo ""
echo "3. 🔧 Configuración de Evolution API:"
INSTANCE_INFO=$(curl -s -H "apikey: A224E19A4FF2C5C3E26679FC26135" http://localhost:8080/instance/fetchInstances 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   Estado de instancia: $(echo $INSTANCE_INFO | jq -r '.[0].instance.state' 2>/dev/null || echo 'Error')"
    echo "   Chatwoot habilitado: $(echo $INSTANCE_INFO | jq -r '.[0].Chatwoot.enabled' 2>/dev/null || echo 'Error')"
    echo "   URL de Chatwoot: $(echo $INSTANCE_INFO | jq -r '.[0].Chatwoot.url' 2>/dev/null || echo 'Error')"
else
    echo "   ❌ No se pudo conectar a Evolution API"
fi

# 4. Probar envío de webhook desde Chatwoot
echo ""
echo "4. 🧪 Prueba de Webhook Chatwoot → Evolution API:"
WEBHOOK_TEST=$(curl -s -w "%{http_code}" -o /dev/null -X POST "https://evo-api.syntalix.net/chatwoot/webhook/n8n" \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature: sha256=test" \
  -d '{"event": "test", "message": "diagnóstico"}' 2>/dev/null)

if [ "$WEBHOOK_TEST" = "200" ]; then
    echo "   ✅ Webhook llega correctamente (HTTP 200)"
else
    echo "   ❌ Webhook falló (HTTP $WEBHOOK_TEST)"
fi

# 5. Verificar logs recientes de Evolution API
echo ""
echo "5. 📋 Logs recientes de Evolution API (últimas 3 líneas):"
docker logs evolution_api --tail 3 2>/dev/null | head -3

# 6. Verificar logs de webhook en Chatwoot
echo ""
echo "6. 📋 Logs de webhook en Chatwoot Sidekiq:"
docker logs chatwoot_sidekiq 2>&1 | grep -A 2 -B 2 "WebhookJob" | tail -5 2>/dev/null

echo ""
echo "🎯 Diagnóstico Completado"
echo ""
echo "💡 Posibles problemas identificados:"
echo "   - La instancia de WhatsApp debe estar conectada (QR code)"
echo "   - Evolution API debe enviar webhooks a Chatwoot cuando recibe mensajes"
echo "   - Chatwoot debe poder enviar respuestas a Evolution API"
echo ""
echo "🔧 Para conectar WhatsApp:"
echo "   1. Ve a: https://evo-api.syntalix.net/"
echo "   2. Inicia sesión con el token de la instancia 'n8n'"
echo "   3. Escanea el QR code para conectar WhatsApp"