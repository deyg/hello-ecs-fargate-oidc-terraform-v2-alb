# Imagem mínima, rápida e segura
FROM node:20-alpine
WORKDIR /app
COPY app/package*.json ./
RUN npm install --omit=dev
COPY app/ ./
EXPOSE 3000
CMD ["npm","start"]
