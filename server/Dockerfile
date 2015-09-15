FROM node

ENV NODE_ENV production

ADD build/package.json /package.json
RUN cd / && npm install

ADD build /app
WORKDIR /app

CMD node index.js
