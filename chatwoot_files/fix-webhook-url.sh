#!/bin/bash

echo "🔧 Corrigiendo URL del webhook en Chatwoot"
echo "=========================================="

# Ejecutar dentro del contenedor de Chatwoot
docker compose -f chatwoot_files/docker-compose.yml exec -T chatwoot bash -c "
echo 'Conectando a la base de datos...'
export PGPASSWORD=4DM1Nchatwoot

# Verificar inboxes actuales
echo 'Inboxes actuales:'
psql -h chatwoot_postgres -U chatwoot -d chatwoot -c 'SELECT id, name, channel_type, webhook_url FROM inboxes;'

# Actualizar webhook_url de localhost:8080 a evolution_api:8080
echo 'Actualizando webhook URLs...'
psql -h chatwoot_postgres -U chatwoot -d chatwoot -c \"
UPDATE inboxes
SET webhook_url = REPLACE(webhook_url, 'localhost:8080', 'https://evo-api.syntalix.net/')
WHERE webhook_url LIKE '%localhost:8080%';
\"

# Verificar cambios
echo 'Inboxes después de la actualización:'
psql -h chatwoot_postgres -U chatwoot -d chatwoot -c 'SELECT id, name, channel_type, webhook_url FROM inboxes;'

echo '✅ Webhook URLs corregidas'
"

echo ""
echo "🔄 Reiniciando servicios de Chatwoot..."
docker compose -f chatwoot_files/docker-compose.yml restart chatwoot chatwoot_sidekiq

echo ""
echo "✅ Problema corregido!"
echo ""
echo "Ahora Chatwoot debería poder conectarse correctamente a Evolution API."
echo "Los mensajes que fallaron anteriormente deberían reenviarse automáticamente."