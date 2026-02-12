#!/bin/bash

# Script maestro para iniciar o detener todos los servicios Docker Compose
# Servicios: evoapi, monitoring, utilidades, chatwoot, n8n

NETWORK_NAME="n8n_evoapi"

# Función para verificar si la red existe
check_network() {
    docker network ls --format "{{.Name}}" | grep -q "^${NETWORK_NAME}$"
}

# Función para crear la red
create_network() {
    echo "Creando la red externa ${NETWORK_NAME}..."
    docker network create ${NETWORK_NAME}
    if [ $? -eq 0 ]; then
        echo "Red ${NETWORK_NAME} creada exitosamente."
    else
        echo "Error al crear la red ${NETWORK_NAME}."
        exit 1
    fi
}

# Función para iniciar todos los servicios
start_all() {
    echo "Iniciando todos los servicios..."

    # N8N (primero para que Traefik esté disponible)
    if [ -f "n8n_files/docker-compose.yml" ]; then
        echo "Iniciando N8N..."
        docker compose -f n8n_files/docker-compose.yml up -d
        if [ $? -ne 0 ]; then echo "Error en N8N"; exit 1; fi
    fi

    # EvoAPI
    echo "Iniciando EvoAPI..."
    docker compose -f evoapi_files/docker-compose.yml up -d
    if [ $? -ne 0 ]; then echo "Error en EvoAPI"; exit 1; fi

    # Monitoring
    echo "Iniciando Monitoring..."
    docker compose -f monitoring/docker-compose.yml up -d
    if [ $? -ne 0 ]; then echo "Error en Monitoring"; exit 1; fi

    # Utilidades
    echo "Iniciando Utilidades..."
    docker compose -f utilidades/docker-compose.yml up -d
    if [ $? -ne 0 ]; then echo "Error en Utilidades"; exit 1; fi

    # Chatwoot
    if [ -f "chatwoot_files/docker-compose.yml" ]; then
        echo "Iniciando Chatwoot..."
        docker compose -f chatwoot_files/docker-compose.yml up -d
        if [ $? -ne 0 ]; then echo "Error en Chatwoot"; exit 1; fi
    fi

    echo "Todos los servicios iniciados exitosamente."
}

# Función para detener todos los servicios
stop_all() {
    echo "Deteniendo todos los servicios..."

    # Chatwoot
    if [ -f "chatwoot_files/docker-compose.yml" ]; then
        echo "Deteniendo Chatwoot..."
        docker compose -f chatwoot_files/docker-compose.yml down
    fi

    # Utilidades
    echo "Deteniendo Utilidades..."
    docker compose -f utilidades/docker-compose.yml down

    # Monitoring
    echo "Deteniendo Monitoring..."
    docker compose -f monitoring/docker-compose.yml down

    # EvoAPI
    echo "Deteniendo EvoAPI..."
    docker compose -f evoapi_files/docker-compose.yml down

    # N8N (último para mantener Traefik disponible hasta el final)
    if [ -f "n8n_files/docker-compose.yml" ]; then
        echo "Deteniendo N8N..."
        docker compose -f n8n_files/docker-compose.yml down
    fi

    echo "Todos los servicios detenidos."
}

# Función para mostrar estado
status_all() {
    echo "Estado de todos los servicios:"

    echo "=== EvoAPI ==="
    docker compose -f evoapi_files/docker-compose.yml ps

    echo "=== Monitoring ==="
    docker compose -f monitoring/docker-compose.yml ps

    echo "=== Utilidades ==="
    docker compose -f utilidades/docker-compose.yml ps

    if [ -f "chatwoot_files/docker-compose.yml" ]; then
        echo "=== Chatwoot ==="
        docker compose -f chatwoot_files/docker-compose.yml ps
    fi

    if [ -f "n8n_files/docker-compose.yml" ]; then
        echo "=== N8N ==="
        docker compose -f n8n_files/docker-compose.yml ps
    fi
}

# Verificar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 {start|stop|status}"
    exit 1
fi

ACTION=$1

case $ACTION in
    start)
        # Verificar y crear red si no existe
        if ! check_network; then
            create_network
        else
            echo "La red ${NETWORK_NAME} ya existe."
        fi
        start_all
        ;;
    stop)
        stop_all
        ;;
    status)
        status_all
        ;;
    *)
        echo "Acción inválida. Usa 'start', 'stop' o 'status'."
        exit 1
        ;;
esac