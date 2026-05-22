# Use the official Nginx image as base
FROM nginx:alpine

# Copy the static HTML file to the Nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 (Internal container port)
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]