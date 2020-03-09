FROM node:8

USER node

RUN mkdir /home/node/app

WORKDIR /home/node/app

COPY ./package-lock.json ./package.json /home/node/app/

RUN npm install --ignore-optional

# COPY . /home/node/app

ENV PATH=./node_modules/.bin:$PATH

# VOLUME ["/home/node/app/src"]

EXPOSE 8081

CMD rm -f .bsb.lock; npm run server
