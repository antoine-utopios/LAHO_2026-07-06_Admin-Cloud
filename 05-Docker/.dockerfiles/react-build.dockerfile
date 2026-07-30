FROM node:alpine AS builder

WORKDIR /src

COPY demo-react/ ./

RUN npm install

RUN npm run build

FROM nginx:alpine

COPY --from=builder /src/dist/ /usr/share/nginx/html/

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]