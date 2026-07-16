# 1. Gunakan versi Node.js LTS terbaru (v22) dan Alpine terbaru
FROM node:22-alpine

# 2. Update sistem paket Alpine dan upgrade npm ke versi terbaru untuk menambal kerentanan di tool bawaan
RUN apk update && apk upgrade --no-cache && \
    npm install -g npm@latest

# 3. Buat direktori kerja
WORKDIR /app

# 4. Copy file konfigurasi dependensi
COPY package*.json ./

# 5. Install dependencies dengan bersih
# Menambahkan --ignore-scripts untuk keamanan rantai pasok (supply chain)
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# 6. Copy source code aplikasi
COPY . .

# 7. Pastikan semua file milik user 'node'
RUN chown -R node:node /app

# 8. Gunakan user 'node'
USER node

EXPOSE 3091

CMD ["node", "src/index.js"]