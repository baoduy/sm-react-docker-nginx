# Build The Node Js Application
FROM node:latest as build
WORKDIR app

COPY ./package.json ./
RUN npm install
COPY . .
RUN npm run build

# Hosting the dist folder as static side.
FROM nginx as runtime
WORKDIR /app
#WORKDIR /var/www
#Copy the required files from Build.
COPY --from=0 /app/dist ./
COPY --from=0 /app/sm-react-docker-nginx/default.conf /etc/nginx/conf.d/
#Copy SSL file
COPY --from=0 /app/sm-react-docker-nginx/localhost.pem /etc/ssl/localhost.pem

#Environment variables
ENV PORT=80
ENV PORT_SSL=443

#Expose the port.
EXPOSE ${PORT}:${PORT_SSL}

#The endpoint of Image.
#The NOTE from https://hub.docker.com/_/nginx/
#If you add a custom CMD in the Dockerfile, be sure to include -g daemon off; 
# in the CMD in order for nginx to stay in the foreground, so that Docker can track the process properly
# (otherwise your container will stop immediately after starting)!
CMD ["nginx", "-g", "daemon off;"]