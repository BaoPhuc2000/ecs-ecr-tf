FROM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY package.json index.js ./

USER node
EXPOSE 8080
CMD ["node", "index.js"]
