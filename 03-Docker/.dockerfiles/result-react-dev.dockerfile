FROM node:alpine

WORKDIR /src

COPY demo-react/ ./

RUN npm install

CMD [ "npm", "run", "dev" ]