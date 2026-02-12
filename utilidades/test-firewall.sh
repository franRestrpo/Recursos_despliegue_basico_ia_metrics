#!/bin/bash

echo "🔍 Test de Conectividad Cloudflare - Puerto 7844"
echo "==============================================="

# IPs de Cloudflare a probar
CLOUDFLARE_IPS=(
    "198.41.200.23"
    "198.41.192.227"
    "198.41.200.33"
    "198.41.200.113"
    "198.41.192.7"
)

echo "📋 Probando conectividad al puerto 7844 (TCP)..."
echo ""

SUCCESS_COUNT=0
TOTAL_COUNT=${#CLOUDFLARE_IPS[@]}

for ip in "${CLOUDFLARE_IPS[@]}"; do
    echo -n "Testing $ip:7844 ... "

    # Usar timeout para evitar esperas largas
    if timeout 5 bash -c "</dev/tcp/$ip/7844" 2>/dev/null; then
        echo "✅ ABIERTO"
        ((SUCCESS_COUNT++))
    else
        echo "❌ BLOQUEADO"
    fi
done

echo ""
echo "📊 Resultados:"
echo "   Conexiones exitosas: $SUCCESS_COUNT/$TOTAL_COUNT"

if [ $SUCCESS_COUNT -eq 0 ]; then
    echo ""
    echo "🚨 PROBLEMA: Todas las conexiones están bloqueadas"
    echo ""
    echo "🔧 Soluciones para pfSense/Firewall:"
    echo ""
    echo "1. Acceder al panel de pfSense"
    echo "2. Ir a Firewall → Rules → WAN"
    echo "3. Crear nueva regla:"
    echo "   - Action: Pass"
    echo "   - Interface: WAN"
    echo "   - Protocol: TCP"
    echo "   - Destination: Any"
    echo "   - Destination Port: 7844"
    echo ""
    echo "4. Aplicar cambios y probar nuevamente"
    echo ""
    echo "📞 O contactar al administrador de red"
elif [ $SUCCESS_COUNT -lt $TOTAL_COUNT ]; then
    echo ""
    echo "⚠️  Algunas conexiones funcionan, pero no todas"
    echo "   Puede ser intermitente o problemas de red"
else
    echo ""
    echo "✅ Todas las conexiones funcionan correctamente"
    echo "   El problema debe estar en la configuración de Cloudflare"
fi

echo ""
echo "🔄 Para probar el túnel después de configurar:"
echo "docker compose -f utilidades/docker-compose.yml restart cloudflared"