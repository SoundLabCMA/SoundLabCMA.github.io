# Use a standard Node 20 image (smaller and more stable than Nixpacks)
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Copy package files first (better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of your app
COPY . .

# Build the VitePress site
RUN npm run docs:build

# --- Stage 2: Serve the site ---
# Use a lightweight Nginx server to serve the static files
FROM nginx:alpine

# Copy the build output from the previous stage
# Note: Verify if your output is 'docs/.vitepress/dist' or just 'dist'
COPY --from=builder /app/docs/.vitepress/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]