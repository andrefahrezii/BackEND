# Gunakan base image yang ringan, aman, dan sudah dioptimasi
FROM node:20-alpine

# Buat direktori kerja
WORKDIR /app

# Copy package.json dan package-lock.json terlebih dahulu untuk efisiensi layer
COPY package*.json ./

# Install hanya dependencies produksi (bukan devDependencies)
RUN npm ci --only=production

# Copy sisa source code aplikasi
COPY . .

# SECURITY: Jangan gunakan root. Gunakan user 'node' yang sudah ada di image
USER node

# Port aplikasi
EXPOSE 3091

# Jalankan aplikasi
CMD ["node", "src/index.js"]