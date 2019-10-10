FROM node:8
USER node
WORKDIR /home/node/app
COPY ./package.js /home/node/app
RUN npm install
COPY . /home/node/app
VOLUME [/home/node/app]
EXPOSE 8081
CMD npm run server