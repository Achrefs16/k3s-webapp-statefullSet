# ---- 1. Build Stage ----
    FROM node:20-alpine AS builder

    WORKDIR /app
    
    # Copy package files and install deps
    COPY package*.json ./
    RUN npm install
    
    # Copy the rest of your project files
    COPY . .
    
    # Build the Next.js app (Turbopack will handle optimization)
    RUN npm run build
    
    # ---- 2. Run Stage ----
    FROM node:20-alpine AS runner
    
    WORKDIR /app
    
    # Copy necessary files from builder
    COPY --from=builder /app/package*.json ./
    COPY --from=builder /app/.next ./.next
    COPY --from=builder /app/node_modules ./node_modules
    COPY --from=builder /app/next.config.* ./
    COPY --from=builder /app/app ./app
    COPY --from=builder /app/lib ./lib
    
    # Environment variables
    ENV PORT=3000
    EXPOSE 3000
    
    # Start the production server
    CMD ["npm", "start"]
    