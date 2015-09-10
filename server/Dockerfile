FROM node

ENV NODE_ENV production

ADD build/package.json /package.json
RUN cd / && npm install && npm install -g nodemon

ADD build /app
WORKDIR /app

CMD nodemon index.js
