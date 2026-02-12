# 🚀 Guía de Despliegue y Troubleshooting

Esta guía proporciona instrucciones detalladas para la instalación, configuración y resolución de problemas de la infraestructura Zero Trust.

## 📋 Requisitos del Sistema

- **Docker** y **Docker Compose** (últimas versiones).
- **Dominio personalizado** configurado en Cloudflare.
- **Cuenta Cloudflare** con Zero Trust habilitado.
- **Red externa** `n8n_evoapi` (se crea automáticamente con el script maestro).

## ⚙️ Configuración Inicial

### 1. Clonar y Preparar

```bash
git clone <repository>
cd "Recursos_despliegue_basico_ia_metrics"
```

### 2. Variables de Entorno

Para cada servicio, copia el archivo de ejemplo y edita las variables:

```bash
cp evoapi_files/.env.example evoapi_files/.env
cp chatwoot_files/.env.example chatwoot_files/.env
cp n8n_files/.env.example n8n_files/.env
cp monitoring/.env.example monitoring/.env
cp utilidades/.env.example utilidades/.env
```

### 3. Configurar Cloudflare Zero Trust

```bash
cd utilidades
./setup-token-only.sh
```

---

## 🚀 Inicio de Servicios

### Gestión con Script Maestro

El script `manage_all.sh` facilita la gestión de todo el stack:

```bash
./manage_all.sh start    # Iniciar todos los servicios
./manage_all.sh stop     # Detener todos los servicios
./manage_all.sh status   # Ver estado de los contenedores
./manage_all.sh logs     # Ver logs en tiempo real
```

### Gestión Individual

Si necesitas iniciar un componente específico:

- **N8N**: `cd n8n_files && docker compose up -d`
- **Chatwoot**: `cd chatwoot_files && docker compose up -d`
- **Evolution API**: `cd evoapi_files && docker compose up -d`
- **Monitoring**: `cd monitoring && docker compose up -d`

---

## 🚨 Solución de Problemas (Troubleshooting)

### Túnel Cloudflare Desconectado

1. Verificar conectividad: `cd utilidades && ./test-firewall.sh`
2. Si el puerto 7844 está bloqueado, asegúrate de permitir tráfico TCP saliente en tu firewall (pfSense/Router).
3. Reiniciar el túnel: `docker compose -f utilidades/docker-compose.yml restart cloudflared`

### Error de Base de Datos en Chatwoot

Si Chatwoot no inicia por errores de base de datos, puedes intentar resetear los volúmenes (⚠️ Perderás los datos):

```bash
cd chatwoot_files
docker compose down
docker volume rm chatwoot_files_chatwoot_postgres_data
docker compose up -d
```

### Red Docker no encontrada

Si recibes un error indicando que la red `n8n_evoapi` no existe:

```bash
docker network create n8n_evoapi
```

### Diagnóstico General

- **Estado**: `./manage_all.sh status`
- **Logs**: `docker compose -f <archivo> logs -f <servicio>`
- **Redes**: `docker network ls`
