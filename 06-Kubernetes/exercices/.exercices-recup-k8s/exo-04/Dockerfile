FROM node:alpine

WORKDIR /app

COPY api/package*.json .

RUN npm ci

COPY api/ .

EXPOSE 3000

CMD ["npm", "start"]
