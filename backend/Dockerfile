# ============================================
# Backend Dockerfile (production-ready)
# ============================================

# ============================================
# Dependency stage for cached installs.
# ============================================
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ============================================
# Production stage.
# ============================================
FROM node:18-alpine AS prod
ENV NODE_ENV=production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Copy dependencies and app source
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs src ./src

USER nodejs
EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/', (r) => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "src/server.js"]
