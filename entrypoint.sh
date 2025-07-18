#!/bin/bash
set -e

echo "🚀 Iniciando Cart Redis Service..."

# Variables por defecto
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
MAX_RETRIES=${MAX_RETRIES:-30}
RETRY_INTERVAL=${RETRY_INTERVAL:-2}

echo "📊 Configuración:"
echo "  Redis Host: $REDIS_HOST"
echo "  Redis Port: $REDIS_PORT"
echo "  Max Retries: $MAX_RETRIES"

# Función para verificar Redis
check_redis() {
    nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null
}

# Esperar a que Redis esté disponible
echo "⏳ Esperando conexión a Redis..."
retry_count=0
while ! check_redis; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -gt $MAX_RETRIES ]; then
        echo "❌ Error: No se pudo conectar a Redis después de $MAX_RETRIES intentos"
        exit 1
    fi
    echo "   Intento $retry_count/$MAX_RETRIES - Redis no disponible, reintentando en ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
done

echo "✅ Redis disponible!"

# Verificar conexión Python-Redis
echo "🔍 Verificando conexión Python-Redis..."
python -c "
import redis
import os
import sys

try:
    r = redis.Redis(
        host=os.getenv('REDIS_HOST', 'localhost'), 
        port=int(os.getenv('REDIS_PORT', 6379)),
        socket_connect_timeout=5,
        socket_timeout=5
    )
    r.ping()
    print('✅ Conexión Redis exitosa')
except Exception as e:
    print(f'❌ Error conectando a Redis: {e}')
    sys.exit(1)
"

echo "🌟 Iniciando FastAPI Cart Service en modo producción..."

# Ejecutar con configuración optimizada para producción
exec uvicorn app.main:app \
    --host 0.0.0.0 \
    --port 8002 \
    --workers 1 \
    --log-level info \
    --access-log
