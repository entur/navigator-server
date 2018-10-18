FROM node:6.10.3
# https://hub.docker.com/_/node/
# Can it run with 7.10.0 ? Or 6.10.3-alpine?

RUN wget --quiet https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb

RUN mkdir -p /opt/navigatorserver
WORKDIR /opt/navigatorserver

COPY . .

RUN npm install grunt-cli
ADD package.json /opt/navigatorserver/package.json
RUN npm install

ENV NODE_OPTS=''
ENV MQTT='mqtt://mqtt:1883'
ENV PORT=9002

# Strangely not working. TODO follow up later: CMD [ "node", "$NODE_OPTS", "./node_modules/.bin/grunt", "server", "--port", "${PORT}" "--MQTT", "${MQTT}" "--stack" ]

CMD dumb-init node $NODE_OPTS ./node_modules/.bin/grunt server --port ${PORT} --MQTT ${MQTT} --stack
