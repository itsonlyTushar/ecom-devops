# Use official Node.js 18 as base image
FROM node:18-bullseye-slim

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
# Note: --omit=dev breaks seed.js at container startup (utils/seed.js requires
# the devDependency 'chalk'), so all deps are installed here.
RUN npm ci

# Copy the rest of the server code
COPY . .

# Expose port 3000 for the server
EXPOSE 3000

# Default command to start the application
CMD ["npm", "start"]
