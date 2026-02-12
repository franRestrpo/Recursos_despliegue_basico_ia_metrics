# 🔧 Utilidades - Servicios Auxiliares + Zero Trust

Este directorio contiene servicios auxiliares para el proyecto N8N Chatwoot, incluyendo base de datos, vector database, interfaces web y **Cloudflare Zero Trust** para acceso seguro remoto.

## Arquitectura

```
+----------------+     +----------------+     +----------------+
|   PostgreSQL   |     |     Qdrant     |     |  Open WebUI    |
|   (Puerto int) |     | (Puertos 6333/4)|    |  (Puerto 3002) |
+----------------+     +----------------+     +----------------+
         |                     |                     |
         +---------------------+---------------------+
                         |
                +----------------+
                |   Dense Index  |
                |  (Pinecone emu)|
                | (Puerto 5081)  |
                +----------------+
```

## Servicios

### PostgreSQL

- **Puerto**: Interno (5432)
- **Base de datos**: n8n
- **Usuario**: n8n_user
- **Función**: Base de datos para N8N y otros servicios.

### Qdrant

- **Puertos**: 6333 (HTTP), 6334 (gRPC)
- **Función**: Base de datos vectorial para embeddings.
- **API Key**: Configurable en `.env`

### Open WebUI

- **Puerto**: 3002
- **Función**: Interfaz web para modelos de IA.
- **Vector DB**: Chroma (configurable)

### Dense Index (Pinecone Emulator)

- **Puerto**: 5081
- **Función**: Emulación de Pinecone para índices vectoriales.
- **Dimensión**: 2 (configurable)
- **Métrica**: Cosine

### Cloudflare Tunnel (Zero Trust)

- **Función**: Túnel seguro para acceso remoto sin exponer puertos
- **Configuración**: Token en `.env` (CLOUDFLARE_TUNNEL_TOKEN)
- **Gestión**: Scripts en este directorio para configuración
- **Documentación**: Ver [README-ZeroTrust.md](README-ZeroTrust.md)

## Estructura de Archivos

```
utilidades/
├── docker-compose.yml          # Configuración de servicios
├── .env                         # Variables de entorno
├── .env.example                 # Ejemplo de variables
├── postgres_data/               # Datos de PostgreSQL
├── qdrant_storage/              # Datos de Qdrant
├── open-webui/                  # Datos de Open WebUI
├── setup-token-only.sh          # Configuración Zero Trust
├── test-firewall.sh             # Test de conectividad
├── README-ZeroTrust.md          # Documentación Zero Trust
└── readme.md                   # Archivo de ejemplo de curl
```

## Requisitos Previos

- Docker y Docker Compose
- Red externa `n8n_evoapi`
- Espacio suficiente para datos persistentes

## Instalación y Uso

### 1. Configurar Variables de Entorno

```bash
cp .env.example .env
# Editar .env según necesidades
# IMPORTANTE: Configurar CLOUDFLARE_TUNNEL_TOKEN para Zero Trust
```

### 2. Configurar Zero Trust (Opcional pero recomendado)

```bash
# Configurar túnel Cloudflare para acceso seguro
./setup-token-only.sh

# Verificar conectividad del firewall
./test-firewall.sh
```

### 3. Iniciar Servicios

```bash
docker compose up -d
```

### 3. Acceder a las Interfaces

- **Open WebUI**: http://localhost:3002
- **Qdrant Dashboard**: http://localhost:6333/dashboard
- **Pinecone Emulator**: http://localhost:5081 (API)

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

#### PostgreSQL

- `POSTGRES_DB`: Nombre de la base de datos
- `POSTGRES_USER`: Usuario de PostgreSQL
- `POSTGRES_PASSWORD`: Contraseña

#### Qdrant

- `QDRANT__SERVICE__API_KEY`: Clave API para Qdrant
- `QDRANT_STORAGE`: Directorio de almacenamiento
- `QDRANT_HTTP_PORT`: Puerto HTTP
- `QDRANT_LOG_LEVEL`: Nivel de logging

#### Open WebUI

- `PORT`: Puerto de la aplicación

#### Pinecone Emulator

- `INDEX_TYPE`: Tipo de índice
- `VECTOR_TYPE`: Tipo de vector
- `DIMENSION`: Dimensión de vectores
- `METRIC`: Métrica de distancia

## Uso de Qdrant

### Crear Colección

```bash
curl -X PUT http://localhost:6333/collections/RAGN8N \
  -H "Content-Type: application/json" \
  -H "api-key: <tu_api_key>" \
  -d '{
    "vectors": {
      "content": {
        "size": 768,
        "distance": "Cosine"
      }
    }
  }'
```

### Insertar Vectores

```bash
curl -X PUT http://localhost:6333/collections/RAG_N8N/points \
  -H "Content-Type: application/json" \
  -H "api-key: <tu_api_key>" \
  -d '{
    "points": [
      {
        "id": 1,
        "vector": [0.1, 0.2, ...],
        "payload": {"text": "ejemplo"}
      }
    ]
  }'
```

## Open WebUI

### Configuración Inicial

1. Acceder a http://localhost:3002
2. Configurar modelos de IA
3. Conectar con vector databases si es necesario

### Funciones

- Chat con modelos de IA
- Gestión de documentos
- Integración con bases vectoriales

## Pinecone Emulator

### Uso Básico

```bash
# Crear índice
curl -X POST http://localhost:5081/indexes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-index",
    "dimension": 2,
    "metric": "cosine"
  }'

# Insertar vectores
curl -X POST http://localhost:5081/vectors/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": [
      {
        "id": "vec1",
        "values": [0.1, 0.2]
      }
    ]
  }'
```

## Solución de Problemas

### PostgreSQL No Inicia

- Verificar permisos del directorio `postgres_data`
- Revisar logs: `docker compose logs postgres`

### Qdrant No Responde

- Verificar API key en `.env`
- Revisar logs: `docker compose logs qdrant`

### Open WebUI Error de CORS

- Configurar `CORS_ALLOW_ORIGIN` en producción
- Advertencia normal en desarrollo

### Conexiones Cruzadas

- Los exporters de monitoring pueden intentar conectar
- Asegurar credenciales correctas en `monitoring/.env`

## Persistencia de Datos

- **PostgreSQL**: `./postgres_data`
- **Qdrant**: `./qdrant_storage`
- **Open WebUI**: `./open-webui`

## Integración con N8N

- **PostgreSQL**: Usado por N8N para almacenamiento principal
- **Qdrant**: Para RAG y embeddings en workflows
- **Open WebUI**: Interfaz para testing de modelos de IA
- **Cloudflare Tunnel**: Proporciona acceso seguro remoto a N8N sin exponer puertos

## Licencia

Parte del proyecto de utilidades de N8N Chatwoot.
