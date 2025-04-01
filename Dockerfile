
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code
COPY . .

# Create .env file if not exists (you'll need to update client_id later)
RUN if [ ! -f .env ]; then cp .env.sample .env || echo "VITE_APP_NAVERMAPS_CLIENT_ID=your-client-id" > .env; fi

# Build the Vite application
RUN npm run build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Install serve globally
RUN npm install -g serve

# Copy the built files from the build stage
COPY --from=builder /app/dist ./dist

# Expose the port the app runs on (serve defaults to 3000)
EXPOSE 3000

# Start the application with serve
CMD ["serve", "-s", "dist", "-l", "3000"]
