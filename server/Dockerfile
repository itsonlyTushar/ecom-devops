FROM node:18-bullseye-slim

WORKDIR /usr/src/app

COPY package*.json ./
# seed.js at container startup requires 'chalk'
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]

