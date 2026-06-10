# ---------- Stage 1: build the React (Babel + Webpack) client ----------
FROM node:20-alpine AS client
WORKDIR /app/client
COPY client/package.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# ---------- Stage 2: server runtime (Express serves API + client) ----------
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY db ./db
COPY docs ./docs
COPY server/package.json ./server/
RUN cd server && npm install --omit=dev
COPY server ./server
COPY --from=client /app/client/dist ./client/dist

WORKDIR /app/server
EXPOSE 3001
CMD ["node", "src/index.js"]
