# 1. Gunakan versi Node.js LTS terbaru (v22) dan Alpine terbaru
FROM node:22-alpine

# 2. Update sistem paket Alpine untuk menambal kerentanan OS (CVE-2026-*)
RUN apk update && apk upgrade --no-cache

# 3. Buat direktori kerja dengan hak akses yang benar
WORKDIR /app

# 4. Copy file konfigurasi dependensi
COPY package*.json ./

# 5. Install dependencies dengan bersih
# Tambahkan --ignore-scripts jika Anda tidak memerlukan *build* khusus untuk mencegah *supply chain attack*
RUN npm ci --only=production && npm cache clean --force

# 6. Copy source code setelah install dependencies agar layer tidak sering berubah
COPY . .

# 7. Pastikan semua file milik user 'node'
RUN chown -R node:node /app

# 8. Gunakan user 'node'
USER node

EXPOSE 3091

CMD ["node", "src/index.js"]