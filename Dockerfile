# ----------- STAGE 1: BUILD ----------- #
FROM node:18-alpine AS builder

# Install Hugo Extended + build dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    python3 \
    make \
    g++ \
    go \
    libc6-compat \
    && wget https://github.com/gohugoio/hugo/releases/download/v0.125.6/hugo_extended_0.125.6_linux-amd64.tar.gz \
    && tar -xvzf hugo_extended_0.125.6_linux-amd64.tar.gz \
    && mv hugo /usr/local/bin/ \
    && chmod +x /usr/local/bin/hugo \
    && rm -rf hugo_extended_0.125.6_linux-amd64.tar.gz README.md LICENSE

# Set working directory
WORKDIR /app

# Copy package.json + lock file and install deps
COPY package*.json ./
RUN npm install

# Copy entire app
COPY . .

# Clean old public dir and build the static site
RUN npx rimraf public && npm run build

# ----------- STAGE 2: SERVE ----------- #
FROM node:18-alpine

# Install lightweight static server
RUN npm install -g http-server

# Set working directory
WORKDIR /app

# Copy built static site from builder stage
COPY --from=builder /app/public .

# Expose port for access
EXPOSE 5173  

# Serve the site
CMD ["http-server", "-p", "5173"]
