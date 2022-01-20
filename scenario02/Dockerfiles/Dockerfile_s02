FROM node:14-alpine

WORKDIR /app
COPY package*.json ./

RUN npm install
COPY . .
RUN chmod +x /app/dumb-init
EXPOSE 3000
CMD [ "echo", "ERROR: The main process has finished." ]