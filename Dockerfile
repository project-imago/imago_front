FROM node:13

USER node

RUN mkdir /home/node/app

WORKDIR /home/node/app

COPY ./package-lock.json ./package.json /home/node/app/

RUN npm install --ignore-optional

ENV PATH=./node_modules/.bin:$PATH

RUN mkdir -p /home/node/app/lib/bs

EXPOSE 8081

CMD rm -f .bsb.lock; npm run server
