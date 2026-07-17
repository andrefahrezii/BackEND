# Tahap 1: Build (Gunakan image Node standar)
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Instal dependencies
RUN npm ci --only=production --ignore-scripts

# Tahap 2: Runtime (Gunakan Distroless)
FROM gcr.io/distroless/nodejs22-debian12
WORKDIR /app
# Salin folder hasil build dari tahap 1
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Jalankan sebagai user node
USER 1000
EXPOSE 3091
CMD ["node", "src/index.js"]