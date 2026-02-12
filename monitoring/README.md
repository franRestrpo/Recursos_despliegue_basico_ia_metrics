# Monitoring - Servicios de Monitoreo

Este directorio contiene la configuración de servicios de monitoreo para el proyecto N8N Chatwoot, utilizando Prometheus, Grafana y exporters.

## Arquitectura

```
+----------------+     +----------------+     +----------------+
|   Prometheus   |     |    Grafana     |     |   Exporters    |
|   (Puerto 9090)|<--->|  (Puerto 3000) |     | (Varios puertos)|
+----------------+     +----------------+     +----------------+
         ^
         |
+----------------+
|   Servicios     |
|   (N8N, Evo,    |
|    Utilidades)  |
+----------------+
```

## Servicios

### Prometheus
- **Puerto**: 9090
- **Función**: Recopila métricas de exporters.
- **Configuración**: `prometheus.yml`

### Grafana
- **Puerto**: 3000
- **Usuario**: admin
- **Contraseña**: admin (configurable en `.env`)
- **Función**: Visualización de métricas.

### Exporters
- **Node Exporter**: Métricas del sistema (puerto 9100)
- **cAdvisor**: Métricas de contenedores (puerto 8081)
- **Postgres Exporters**: Métricas de bases de datos PostgreSQL
  - N8N: puerto 9187
  - EvoAPI: puerto 9188
  - Utilidades: puerto 9189
- **Redis Exporters**: Métricas de Redis
  - N8N: puerto 9121
  - EvoAPI: puerto 9122

## Estructura de Archivos

```
monitoring/
├── docker-compose.yml    # Configuración de servicios
├── prometheus.yml        # Configuración de Prometheus
├── .env                  # Variables de entorno
├── .env.example          # Ejemplo de variables
└── README.md            # Este archivo
```

## Requisitos Previos

- Docker y Docker Compose
- Red externa `n8n_evoapi`
- Servicios objetivo ejecutándose (N8N, EvoAPI, Utilidades)

## Instalación y Uso

### 1. Configurar Variables de Entorno

```bash
cp .env.example .env
# Editar .env con las credenciales correctas
```

### 2. Iniciar Servicios

```bash
docker compose up -d
```

### 3. Acceder a las Interfaces

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (usuario: admin, contraseña: admin)

### 4. Ver Estado

```bash
docker compose ps
```

### 5. Ver Logs

```bash
docker compose logs -f
```

## Configuración

### Variables de Entorno (.env)

- `GF_SECURITY_ADMIN_PASSWORD`: Contraseña de admin de Grafana
- `DATA_SOURCE_NAME_*`: Cadenas de conexión para exporters de PostgreSQL
- `REDIS_ADDR_*`: Direcciones de Redis para exporters
- `REDIS_PASSWORD_*`: Contraseñas de Redis

### Prometheus (prometheus.yml)

Configura los jobs de scraping para cada exporter y servicio.

## Dashboards en Grafana

### Importar Dashboards

1. Acceder a Grafana
2. Ir a Dashboards > Import
3. Usar IDs de dashboards estándar:
   - Node Exporter: 1860
   - PostgreSQL: 9628
   - Redis: 763

### Configurar Data Sources

1. Ir a Configuration > Data Sources
2. Agregar Prometheus con URL: http://prometheus:9090

## Solución de Problemas

### Exporters No Conectan

- Verificar credenciales en `.env`
- Asegurar que los servicios objetivo estén ejecutándose
- Revisar logs: `docker compose logs <exporter>`

### Métricas No Aparecen

- Verificar configuración en `prometheus.yml`
- Reiniciar Prometheus después de cambios

### Grafana No Carga

- Verificar puerto 3000 disponible
- Revisar logs de Grafana

## Integración con Traefik

Los servicios incluyen labels para Traefik:
- Prometheus: `prometheus.localhost`
- Grafana: `grafana.localhost`

## Métricas Disponibles

- **Sistema**: CPU, memoria, disco, red
- **Contenedores**: Uso de recursos por contenedor (N8N, Chatwoot, Evolution API)
- **PostgreSQL**: Conexiones, queries, locks (bases de N8N, EvoAPI, Utilidades)
- **Redis**: Memoria, conexiones, operaciones (cache de N8N y EvoAPI)
- **Aplicaciones**: Métricas específicas de N8N (workflows activos, ejecuciones)

## Licencia

Parte del proyecto de monitoreo de N8N Chatwoot.