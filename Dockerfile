ARG enviroment_conf

# build application
FROM node:10.15.2-alpine as build
WORKDIR /app
COPY package.json ./
COPY package-lock.json ./
RUN npm install
COPY . ./
RUN npm run build

# release application!testingPipeline
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/conf.d
#COPY $enviroment_conf /etc/nginx/$enviroment_conf
#COPY production.conf /etc/nginx/sites-enabled/production.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]