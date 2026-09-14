# Use official Node.js 18 as base image
FROM node:18-bullseye-slim AS build

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the client code
COPY . .

RUN mv .env.example .env
RUN sed -i 's|^API_URL=.*|API_URL=/api|' .env && \
    sed -i 's|^SOCKET_URL=.*|SOCKET_URL=/|' .env

# Build the client for production
RUN npm run build


FROM nginx:alpine
# Copy the build artifacts from the build stage
COPY --from=build /usr/src/app/dist /usr/share/nginx/html
# NGINX default configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

