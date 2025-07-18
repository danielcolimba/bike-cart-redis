# Multi-stage build para optimizar la imagen
FROM python:3.10-slim as builder

# Instalar dependencias de construcción
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copiar requirements y crear wheels
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /build/wheels -r requirements.txt

# Imagen final de producción
FROM python:3.10-slim

# Metadatos de la imagen
LABEL maintainer="danielcolimba" \
      description="Cart Redis Service for Royal Bike" \
      version="1.0.0"

# Instalar solo dependencias necesarias en runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Crear usuario no-root para seguridad
RUN addgroup --system appgroup && adduser --system --group appuser

WORKDIR /app

# Copiar wheels y instalar dependencias
COPY --from=builder /build/wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache --find-links /wheels -r requirements.txt \
    && rm -rf /wheels

# Copiar código de la aplicación
COPY app/ ./app/
COPY entrypoint.sh .

# Configurar permisos
RUN chown -R appuser:appgroup /app \
    && chmod +x entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8002/health || exit 1

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE 8002

# Configurar entrypoint
ENTRYPOINT ["./entrypoint.sh"]
