# ⚡ N8N - Automatización de Workflows

Este directorio contiene la configuración de **N8N**, una herramienta de automatización de workflows que permite crear flujos de trabajo visuales sin código, integrando múltiples servicios y APIs.

## Arquitectura

```
+--------------------+     +----------------+
|       N8N          |     |    Traefik     |
|   (Puerto 5678)    |<--->|  (Proxy)       |
+--------------------+     +----------------+
          ^
          |
+--------------------+
|   Base de Datos    |
|   (PostgreSQL)     |
+--------------------+
```

### Servicios

- **N8N**: Aplicación principal Node.js (puerto 5678, localhost only)
- **Traefik**: Proxy reverso para enrutamiento interno

### Características

- **Workflows Visuales**: Interfaz drag-and-drop para crear automatizaciones
- **Integraciones**: +350 nodos preconstruidos para APIs populares
- **Ejecución**: Procesamiento en tiempo real o programado
- **Persistencia**: Almacenamiento de workflows y datos en PostgreSQL
- **Comunidad**: Paquetes adicionales disponibles

## Estructura de Archivos

```
n8n_files/
├── docker-compose.yml        # Configuración de servicios
├── .env                      # Variables de entorno
├── .env.example              # Ejemplo de configuración
├── n8n_data/                 # Datos persistentes de N8N
│   ├── config                # Configuración
│   ├── custom/               # Workflows personalizados
│   ├── git/                  # Integración Git
│   ├── nodes/                # Nodos personalizados
│   └── binaryData/           # Archivos binarios
└── local-files/              # Archivos locales para workflows
```

## Requisitos Previos

- Docker y Docker Compose
- Red externa `n8n_evoapi`
- Base de datos PostgreSQL (desde utilidades/)

## Instalación y Uso

### 1. Configurar Variables de Entorno

```bash
cp .env.example .env
# Editar .env con configuración específica
```

### 2. Iniciar Servicios

```bash
docker compose up -d
```

### 3. Acceder a N8N

- **URL**: `http://localhost:5678`
- **Primer acceso**: Crear cuenta de administrador

### 4. Verificar Estado

```bash
docker compose ps
```

### 5. Ver Logs

```bash
docker compose logs -f n8n
```

## Configuración

### Variables de Entorno (.env)

#### Básicas
- `N8N_HOST`: Host donde corre N8N
- `N8N_PORT`: Puerto (5678)
- `N8N_PROTOCOL`: Protocolo (http)
- `NODE_ENV`: Entorno (production)

#### Base de Datos
- `DB_TYPE`: Tipo de BD (postgresdb)
- `DB_POSTGRESDB_HOST`: Host de PostgreSQL
- `DB_POSTGRESDB_PORT`: Puerto (5432)
- `DB_POSTGRESDB_DATABASE`: Nombre de BD
- `DB_POSTGRESDB_USER`: Usuario
- `DB_POSTGRESDB_PASSWORD`: Contraseña

#### Seguridad
- `N8N_BASIC_AUTH_ACTIVE`: Autenticación básica (false)
- `N8N_JWT_SECRET`: Secreto para JWT

#### Webhooks
- `WEBHOOK_URL`: URL base para webhooks
- `GENERIC_TIMEZONE`: Zona horaria

#### Métricas
- `N8N_METRICS`: Habilitar métricas (true)
- `N8N_METRICS_INCLUDE_QUEUE_METRICS`: Métricas de cola

## Uso de N8N

### Crear Primer Workflow

1. Acceder a `http://localhost:5678`
2. Hacer clic en "Add first workflow"
3. Arrastrar nodos del panel izquierdo
4. Conectar nodos y configurar
5. Ejecutar workflow

### Nodos Populares

- **HTTP Request**: Llamadas a APIs
- **Webhook**: Recibir datos externos
- **Schedule**: Ejecución programada
- **Email**: Envío de correos
- **Database**: Consultas SQL
- **Chatwoot**: Integración con soporte al cliente
- **Evolution API**: WhatsApp automation

### Workflows de Ejemplo

#### Automatización WhatsApp + Chatwoot
1. Webhook recibe mensaje de WhatsApp
2. Procesa con IA (Open WebUI)
3. Almacena en base de datos vectorial (Qdrant)
4. Responde automáticamente o escala a agente humano

#### Monitoreo de Servicios
1. Schedule ejecuta cada hora
2. HTTP Request verifica estado de servicios
3. Si falla, envía alerta por email/Slack

## Persistencia de Datos

- **Workflows**: `./n8n_data` (JSON de workflows)
- **Archivos**: `./local-files` (para nodos File)
- **Configuración**: `./n8n_data/config`

## Integración con Otros Servicios

### PostgreSQL (Utilidades)
- Almacenamiento principal de datos
- Configurado en `.env`

### Qdrant (Utilidades)
- Base de datos vectorial para RAG
- Usar con nodos de embeddings

### Open WebUI (Utilidades)
- Interfaz para testing de modelos IA
- Integrar con workflows de IA

### Evolution API
- Automatización WhatsApp
- Nodos específicos disponibles

### Chatwoot
- Gestión de conversaciones
- Escalado automático de tickets

## Monitoreo

N8N expone métricas en `/metrics`:
- Workflows activos
- Ejecuciones por hora
- Uso de CPU/memoria
- Errores por workflow

Configurado para ser recolectado por Prometheus.

## Solución de Problemas

### N8N No Inicia

```bash
# Verificar conexión a BD
docker compose logs n8n | grep postgres

# Verificar variables de entorno
cat .env | grep DB_
```

### Workflows No Se Ejecutan

```bash
# Verificar logs de ejecución
docker compose logs n8n

# Revisar configuración de webhook URL
cat .env | grep WEBHOOK_URL
```

### Problemas de Memoria

```bash
# Aumentar límites en docker-compose.yml
environment:
  - NODE_OPTIONS=--max-old-space-size=4096
```

### Actualizaciones

```bash
# Backup de workflows
cp -r n8n_data n8n_data_backup

# Actualizar
docker compose pull
docker compose up -d

# Verificar migraciones si es necesario
docker compose logs n8n | grep migration
```

## Desarrollo

### Nodos Personalizados

Los nodos personalizados se almacenan en `./n8n_data/nodes/`:
- Desarrollar en TypeScript
- Publicar como paquetes npm
- Cargar automáticamente

### Integración Git

N8N puede sincronizar workflows con Git:
- Configurar repositorio en settings
- Push/pull automático
- Versionado de workflows

## Licencia

N8N es open-source bajo licencia Apache 2.0. Parte de la infraestructura N8N Chatwoot.