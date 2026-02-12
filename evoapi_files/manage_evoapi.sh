#!/bin/bash

# Script para iniciar o detener los contenedores de EvoAPI
# Valida la existencia de la red externa y la crea si es necesario

NETWORK_NAME="n8n_evoapi"
COMPOSE_FILE="docker-compose.yml"

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

# Función para iniciar contenedores
start_containers() {
    echo "Iniciando contenedores..."
    docker compose -f ${COMPOSE_FILE} up -d
    if [ $? -eq 0 ]; then
        echo "Contenedores iniciados exitosamente."
    else
        echo "Error al iniciar los contenedores."
        exit 1
    fi
}

# Función para detener contenedores
stop_containers() {
    echo "Deteniendo contenedores..."
    docker compose -f ${COMPOSE_FILE} down
    if [ $? -eq 0 ]; then
        echo "Contenedores detenidos exitosamente."
    else
        echo "Error al detener los contenedores."
        exit 1
    fi
}

# Verificar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 {start|stop}"
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
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    *)
        echo "Acción inválida. Usa 'start' o 'stop'."
        exit 1
        ;;
esac