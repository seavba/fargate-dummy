FROM nginx
WORKDIR app/
RUN apt-get update && apt-get --assume-yes install vim
COPY app/index.html /usr/share/nginx/html/
EXPOSE 80
