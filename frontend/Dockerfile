# ============================================
# Overview: Multi-stage build for the Next.js frontend.
# ============================================

# ============================================
# Dependency stage for cached installs.
# ============================================
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ============================================
# Build stage for compiling the Next.js app.
# ============================================
FROM node:18-alpine AS build
WORKDIR /app
ARG NEXT_PUBLIC_API_URL=/backend
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# ============================================
# Production stage for serving built assets.
# ============================================
FROM node:18-alpine AS prod
ENV NODE_ENV=production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Copy standalone output and static assets only
COPY --from=build --chown=nodejs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nodejs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nodejs:nodejs /app/public ./public

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/', (r) => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "server.js"]
