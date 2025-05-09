# Dockerfile for Next.js App on Railway

# ---- Base Stage: Install Dependencies ----
# Use Node.js 20 Alpine for a smaller image size
FROM node:20-alpine AS deps
WORKDIR /app

# Install OS packages needed for sharp (often used by Next.js image optimization)
# If you don't use next/image or sharp directly, you might remove this RUN line
RUN apk add --no-cache libc6-compat

# Copy package files
COPY package.json package-lock.json* ./

# Install production dependencies using npm ci for consistency
RUN npm ci --omit=dev

# ---- Builder Stage: Build the Application ----
FROM node:20-alpine AS builder
WORKDIR /app

# Copy installed dependencies from the previous stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the rest of the application code
COPY . .

# Set NODE_ENV to production for the build process (can optimize build)
ENV NODE_ENV production

# Build the Next.js application
# This uses the `output: 'standalone'` setting in next.config.mjs
RUN npm run build

# ---- Runner Stage: Setup the Production Image ----
FROM node:20-alpine AS runner
WORKDIR /app

# Set environment to production
ENV NODE_ENV production
# Optionally set the NEXT_TELEMETRY_DISABLED env variable to disable telemetry
ENV NEXT_TELEMETRY_DISABLED 1

# Copy the standalone output from the builder stage
# This includes the minimal Node.js server and necessary code
COPY --from=builder /app/.next/standalone ./

# Copy the public assets folder
# Standalone output requires this to be copied separately
COPY --from=builder /app/public ./public

# Copy the static assets generated by Next.js (.next/static)
# Standalone output also requires this for client-side assets
COPY --from=builder /app/.next/static ./.next/static

# Expose the port Next.js will run on.
# Railway injects the PORT environment variable, which `next start` respects.
# Setting it here is good practice but Railway's value takes precedence.
EXPOSE 3000

# The command to run the Node.js server generated by the standalone output
CMD ["node", "server.js"] 