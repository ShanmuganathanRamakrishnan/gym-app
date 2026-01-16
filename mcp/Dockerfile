# Dockerfile for Gym App MCP Server
# 
# This is a template for containerizing the MCP server.
# Uncomment and customize as needed.
#
# Build:
#   docker build -t gym-mcp-server ./mcp
#
# Run:
#   docker run -p 3845:3845 -v $(pwd)/design:/app/design:ro gym-mcp-server

# FROM node:18-alpine
# 
# WORKDIR /app
# 
# # Copy package files
# COPY package*.json ./
# 
# # Install dependencies
# RUN npm ci --only=production
# 
# # Copy server code
# COPY server.js ./
# 
# # Expose port
# EXPOSE 3845
# 
# # Health check
# HEALTHCHECK --interval=30s --timeout=3s \
#   CMD wget --no-verbose --tries=1 --spider http://localhost:3845/health || exit 1
# 
# # Start server
# CMD ["node", "server.js"]
