# Use the official Nginx base image
FROM nginx:alpine

# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy static website files into the container
COPY ./dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

# Expose Nginx's default HTTP port
EXPOSE 80

# Run Nginx in the foreground (default in the base image)
CMD ["nginx", "-g", "daemon off;"]
