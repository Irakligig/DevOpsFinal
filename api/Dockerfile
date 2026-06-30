FROM node:20-slim AS build

WORKDIR /app
USER node

COPY --chown=node:node package*.json ./
RUN npm ci --omit=dev

COPY --chown=node:node app.js ./

FROM gcr.io/distroless/nodejs20-debian12:nonroot

WORKDIR /app
COPY --from=build --chown=nonroot:nonroot /app /app

USER nonroot:nonroot

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["/nodejs/bin/node", "-e", "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]

CMD ["app.js"]
