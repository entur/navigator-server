Realtime server component for City Navigator [![CircleCI](https://circleci.com/gh/entur/navigator-server.svg?style=svg)](https://circleci.com/gh/entur/navigator-server)
============================================

navigation-server connects to the MQTT broker/proxy and maintains a state of vehicle data (lat, long, next stop, etc.). 
When a client connects initially the realtime server is able to deliver the state data not kept in the MQTT broker memory.
