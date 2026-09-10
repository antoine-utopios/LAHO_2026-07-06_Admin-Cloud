FROM node:24-alpine AS builder

WORKDIR /app

ADD package*.json .

RUN npm install

ADD . . 

RUN npm run build 

FROM nginx:alpine AS prod

COPY --from=builder /app/build /usr/share/nginx/html

CMD ["nginx","-g","daemon off;"]