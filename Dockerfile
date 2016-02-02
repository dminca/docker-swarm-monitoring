FROM node:0.12
MAINTAINER Ross Kukulinski <ross@kukulinski.com>

COPY ./package.json /app/package.json
RUN cd /app && npm install
COPY . /app

CMD ["node", "/app/index.js"]
