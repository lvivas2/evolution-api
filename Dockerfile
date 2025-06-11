FROM node:18-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    && rm -rf /var/cache/apk/*

# Variables de entorno para Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Crear directorio de trabajo
WORKDIR /evolution

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar código fuente
COPY . .

# Crear directorios necesarios
RUN mkdir -p /evolution/instances /evolution/store

# Compilar TypeScript
RUN npm run build

# Exponer puerto
EXPOSE 8080

# Usuario no root por seguridad
RUN addgroup -g 1001 -S evolution && \
    adduser -S evolution -u 1001 -G evolution && \
    chown -R evolution:evolution /evolution

USER evolution

# Comando de inicio
CMD ["node", "./dist/src/main.js"]
