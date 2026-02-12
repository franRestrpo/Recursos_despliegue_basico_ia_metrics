# 🔒 Cloudflare Zero Trust - Configuración del Proyecto

## Arquitectura Híbrida Implementada

Esta configuración combina **Traefik** (proxy interno) con **Cloudflare Zero Trust** (acceso seguro externo) para proporcionar una solución robusta de acceso seguro.

### Componentes

```
Internet → Cloudflare Zero Trust → Cloudflare Tunnel → Traefik → Servicios Docker
```

## Servicios Configurados

| Servicio      | URL Zero Trust                    | Puerto Interno | Estado |
| ------------- | --------------------------------- | -------------- | ------ |
| Chatwoot      | `https://chatwoot.midominio.com`   | 3000           | ✅     |
| Evolution API | `https://api.midominio.com`        | 8080           | ✅     |
| Open WebUI    | `https://webui.midominio.com`      | 8080           | ✅     |
| Grafana       | `https://monitoring.midominio.com` | 3000           | ✅     |
| Prometheus    | `https://metrics.midominio.com`    | 9090           | ✅     |
| N8N           | `https://n8n.midominio.com`        | 5678           | ✅     |

## Configuración de Políticas Zero Trust

### 1. Acceso a Chatwoot (Público)

```yaml
# Política: Permitir acceso público con rate limiting
- Aplicación: chatwoot.midominio.com
- Política: Bypass (acceso público)
- Rate Limiting: 100 requests/minute por IP
```

### 2. Acceso a APIs (Solo Autenticado)

```yaml
# Política: Requerir autenticación para APIs sensibles
- Aplicaciones:
    - api.midominio.com (Evolution API)
    - monitoring.midominio.com (Grafana)
    - metrics.midominio.com (Prometheus)
    - n8n.midominio.com (N8N)
- Autenticación: Email + MFA
- Grupos permitidos: admin@tuempresa.com
```

### 3. Acceso a Open WebUI (Restringido)

```yaml
# Política: Solo usuarios específicos
- Aplicación: webui.midominio.com
- Autenticación: SAML/Email
- Usuarios permitidos: Lista específica
```

## Configuración en Cloudflare Dashboard

### Paso 1: Configurar Aplicaciones

1. Ve a **Cloudflare Zero Trust** → **Access** → **Applications**
2. Crea aplicaciones self-hosted para cada dominio:
   - **Type**: Self-hosted
   - **Domain**: `chatwoot.midominio.com`
   - **Policies**: Configura según arriba

### Paso 2: Configurar Políticas de Acceso

1. **Access** → **Policies**
2. Crea políticas para cada aplicación:
   ```yaml
   # Ejemplo para APIs
   Name: API Access
   Include:
     - Emails: admin@tuempresa.com
   Require:
     - MFA enabled
   ```

### Paso 3: Configurar Gateway (Opcional)

1. **Gateway** → **Policies**
2. Bloquea acceso directo a IPs:
   ```yaml
   # Bloquear acceso directo a puertos expuestos
   Block:
     - Destination IP: TU_IP_SERVIDOR
     - Destination Port: 3000, 8080, 9090
   ```

## Comandos de Gestión

### Opción 1: Configuración simple con token (Recomendado)

```bash
cd utilidades
./setup-token-only.sh
```

### Opción 2: Reparar túnel local (requiere instalación local)

```bash
cd utilidades
./fix-cloudflare-tunnel.sh
```

### Verificar estado del túnel

```bash
docker logs cloudflared
```

### Reiniciar servicios

```bash
# Reiniciar todo el stack
docker compose down
docker compose up -d

# Solo cloudflared
docker compose -f utilidades/docker-compose.yml restart cloudflared
```

### Verificar conectividad

```bash
# Verificar que los servicios respondan internamente
curl http://chatwoot:3000
curl http://evolution_api:8080

# Probar conectividad del firewall con Cloudflare
cd utilidades
./test-firewall.sh
```

## Solución de Problemas

### Error: "connection refused" en cloudflared / Túnel desconectado

#### 🔍 Diagnóstico rápido:

```bash
cd utilidades
./test-firewall.sh
```

#### Si todas las conexiones están bloqueadas (como en este caso):

### 🔧 **Solución para pfSense/Firewall:**

1. **Acceder al panel de administración de pfSense**
2. **Ir a**: Firewall → Rules → WAN
3. **Crear nueva regla**:
   - **Action**: Pass
   - **Interface**: WAN
   - **Protocol**: TCP
   - **Source**: Any
   - **Destination**: Any
   - **Destination Port**: 7844
   - **Description**: Cloudflare Tunnel
4. **Aplicar cambios** (Save y Apply)
5. **Probar conectividad**:
   ```bash
   cd utilidades
   ./test-firewall.sh
   ```
6. **Reiniciar túnel**:
   ```bash
   docker compose -f utilidades/docker-compose.yml restart cloudflared
   ```

### 📋 **Verificación final:**

```bash
# Ver logs en tiempo real
docker logs -f cloudflared

# Deberías ver:
# INF Connection established connIndex=0 ip=X.X.X.X
# INF Tunnel is ready
```

### ⚠️ **Si pfSense no es accesible:**

- Contactar al administrador de red
- Solicitar apertura del puerto TCP 7844
- Explicar que es necesario para Cloudflare Zero Trust

### Opción alternativa: Script local (requiere instalación local de cloudflared)

```bash
cd utilidades
./fix-cloudflare-tunnel.sh
```

### Error: "DNS resolution failed"

```bash
# Verificar registros DNS en Cloudflare
# Asegúrate de que los CNAME apunten a tu túnel
nslookup chatwoot.midominio.com
```

### Acceso denegado

```bash
# Verificar políticas en Zero Trust dashboard
# Revisar logs de acceso en Cloudflare
```

## Beneficios de Esta Arquitectura

✅ **Seguridad Zero Trust**: Acceso basado en identidad, no en red
✅ **Sin puertos expuestos**: Todo el tráfico va por Cloudflare
✅ **Autenticación centralizada**: MFA y políticas unificadas
✅ **Monitoreo avanzado**: Logs detallados de acceso
✅ **Escalabilidad**: Fácil agregar nuevos servicios
✅ **Resiliencia**: Failover automático a través de Cloudflare

## Migración desde Traefik Solo

Si actualmente usas solo Traefik, esta configuración es **no disruptiva**:

1. Los servicios siguen funcionando internamente
2. Se agrega una capa adicional de seguridad externa
3. Puedes mantener Traefik para enrutamiento interno
4. Gradualmente migrar dominios a Zero Trust

## Costos

- **Cloudflare Zero Trust**: Gratuito para hasta 50 usuarios
- **Cloudflare Tunnel**: Gratuito
- **Certificados SSL**: Gratuitos vía Cloudflare
- **Dominios**: Costo del registro de dominio

¡Esta configuración proporciona seguridad empresarial sin comprometer la funcionalidad!
