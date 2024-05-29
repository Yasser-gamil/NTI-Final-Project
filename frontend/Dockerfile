FROM node:14-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV PATH /app/node_modules/.bin:$PATH

RUN npm run build

RUN npm install -g serve

EXPOSE 3000

CMD ["npm", "start"]

