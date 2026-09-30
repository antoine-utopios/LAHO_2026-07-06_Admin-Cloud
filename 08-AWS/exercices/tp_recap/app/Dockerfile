FROM node:alpine3.24 AS builder

WORKDIR /src

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM nginx:alpine3.24-slim

COPY --from=builder /src/build /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]