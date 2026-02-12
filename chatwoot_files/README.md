# 💬 Chatwoot - Plataforma de Atención al Cliente

Este directorio contiene la configuración de **Chatwoot**, una plataforma de atención al cliente open-source que permite gestionar conversaciones a través de múltiples canales como WhatsApp, email, web chat, etc.

## Arquitectura

```
+--------------------+     +----------------+     +----------------+
|     Chatwoot       |     |   PostgreSQL   |     |     Redis      |
|   (Puerto 3000)    |<--->|   (Vector DB)  |     |   (Cache)      |
+--------------------+     +----------------+     +----------------+
          ^
          |
+--------------------+
|   Evolution API    |
|   (WhatsApp)       |
+--------------------+
```

### Servicios

- **Chatwoot**: Aplicación principal Rails (puerto 3000)
- **Sidekiq**: Procesador de trabajos en segundo plano
- **PostgreSQL con pgvector**: Base de datos con soporte para embeddings
- **Redis**: Cache y cola de trabajos

### Integración con Evolution API

Chatwoot se integra con **Evolution API** para proporcionar soporte WhatsApp:
- Los mensajes de WhatsApp se enrutan a través de Evolution API
- Chatwoot maneja la interfaz de agente y gestión de conversaciones
- Soporte para múltiples números de WhatsApp

## Estructura de Archivos

```
chatwoot_files/
├── docker-compose.yml    # Configuración de servicios
├── .env                  # Variables de entorno
├── .env.example          # Ejemplo de configuración
├── fix-webhook-url.sh    # Script para corregir URLs de webhook
└── test-integration.sh   # Script para probar integración
```

## Requisitos Previos

- Docker y Docker Compose
- Red externa `n8n_evoapi`
- Evolution API configurado (opcional pero recomendado)

## Instalación y Uso

### 1. Configurar Variables de Entorno

```bash
cp .env.example .env
# Editar .env con credenciales y configuración
```

### 2. Iniciar Servicios

```bash
docker compose up -d
```

### 3. Primera Configuración

1. Acceder a la interfaz: `https://chatwoot.srv750421.hstgr.cloud`
2. Crear cuenta de administrador
3. Configurar inbox para WhatsApp (requiere Evolution API)

### 4. Verificar Estado

```bash
docker compose ps
```

### 5. Ver Logs

```bash
docker compose logs -f
```

## Configuración

### Variables de Entorno (.env)

#### Base de Datos
- `POSTGRES_HOST`: Host de PostgreSQL
- `POSTGRES_DATABASE`: Nombre de la base de datos
- `POSTGRES_USERNAME`: Usuario de PostgreSQL
- `POSTGRES_PASSWORD`: Contraseña

#### Redis
- `REDIS_URL`: URL de conexión a Redis
- `REDIS_PASSWORD`: Contraseña de Redis

#### Aplicación
- `FRONTEND_URL`: URL pública de Chatwoot
- `SECRET_KEY_BASE`: Clave secreta para Rails
- `MAILER_SENDER_EMAIL`: Email del remitente

## Integración con Evolution API

### Configuración de Inbox WhatsApp

1. En Chatwoot, crear un inbox de tipo "API"
2. Configurar webhook URL: `https://evolution.srv750421.hstgr.cloud/chatwoot/webhook`
3. Usar API key de Evolution API

### Uso del Script de Integración

```bash
# Probar integración
./test-integration.sh

# Corregir URLs de webhook si es necesario
./fix-webhook-url.sh
```

## Acceso Seguro (Zero Trust)

- **URL Pública**: `https://chatwoot.srv750421.hstgr.cloud`
- **Autenticación**: Zero Trust (Cloudflare)
- **Rate Limiting**: 100 requests/minute por IP

## Solución de Problemas

### Error de Base de Datos

```bash
# Reiniciar desde cero (borra datos existentes)
docker compose down
docker volume rm chatwoot_files_chatwoot_data chatwoot_files_chatwoot_postgres_data
docker compose run --rm chatwoot bundle exec rails db:chatwoot_prepare
docker compose run --rm chatwoot bundle exec rails db:migrate db:seed
docker compose up -d
```

### Problemas de Redis

- Verificar `REDIS_PASSWORD` en `.env`
- Revisar logs: `docker compose logs chatwoot_redis`

### Integración WhatsApp No Funciona

```bash
# Verificar estado de Evolution API
curl http://evolution_api:8080

# Probar webhook
./test-integration.sh
```

### Error de Permisos

```bash
# Asegurar permisos en volúmenes
sudo chown -R 1000:1000 chatwoot_data/
```

## Persistencia de Datos

- **Aplicación**: `./chatwoot_data` (storage, uploads)
- **Base de datos**: `./chatwoot_postgres_data`

## Monitoreo

Chatwoot incluye métricas que pueden ser recolectadas por Prometheus:
- Conexiones activas
- Uso de recursos
- Estadísticas de conversaciones

## Actualizaciones

```bash
# Actualizar imagen
docker compose pull
docker compose up -d

# Migrar base de datos si es necesario
docker compose run --rm chatwoot bundle exec rails db:migrate
```

## Licencia

Chatwoot es open-source bajo licencia MIT. Parte de la infraestructura N8N Chatwoot.