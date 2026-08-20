FROM nginx:alpine

COPY website/ /usr/share/nginx/html/

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]

# docker build -f website.dockerfile -t siteweb .

# docker run -d -p 3000:80 siteweb