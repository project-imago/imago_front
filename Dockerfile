FROM node:8

USER node

RUN mkdir /home/node/app

WORKDIR /home/node/app

COPY ./package.json /home/node/app

RUN npm install

COPY . /home/node/app

ENV PATH=./node_modules/.bin:$PATH

VOLUME ["/home/node/app"]

EXPOSE 8081

CMD npm run server
