moment = require 'moment'


mqtt_match = (pattern, topic) ->
    regex = pattern.replace(/\+/g, "[^/]*").replace(/\/#$/, "/.*")
    return topic.match "^"+regex+"$"


interpret_jore = (routeId) ->
    if routeId?.match /^1019/
        [mode, routeType, route] = ["FERRY", 4, "Ferry"]
    else if routeId?.match /^1300/
        [mode, routeType, route] = ["SUBWAY", 1, routeId.substring(4,5)]
    else if routeId?.match /^300../
        [mode, routeType, route] = ["RAIL", 2, routeId.substring(4,5)]
    else if routeId?.match /^10(0.|10)/
        [mode, routeType, route] = ["TRAM", 0, routeId.replace(/^.0*/,"")]
    else if routeId?.match /^(1|2|4|5|6|7|9).../
        [mode, routeType, route] = ["BUS", 3, routeId.replace(/^.0*/,"")]
    else
        # unknown, assume bus
        [mode, routeType, route] = ["BUS", 3, routeId]

    return [mode, routeType, route]


to_mqtt_topic = (msg) ->
    x = msg.position.latitude
    y = msg.position.longitude
    digit = (x, i) -> "" + Math.floor(x*10**i)%10
    digits = (digit(x, i) + digit(y, i) for i in [1..3])
    geohash = Math.floor(x) + ";" + Math.floor(y) + "/" + digits.join '/'

    mode = msg.vehicle.mode
    headsign = msg.trip.headsign

    return "/hfp/journey/#{mode}/#{msg.vehicle.id}/#{msg.trip.route}/#{msg.trip.direction}/#{headsign}/#{msg.trip.start_time}/#{msg.position.next_stop}/"+geohash


to_mqtt_payload = (msg) ->
    now = moment().tz('Europe/Helsinki')

    # if there's start_time but no start_date, guess one
    if msg.trip.start_time? and not msg.trip.start_date?
        start_hour = parseInt msg.trip.start_time.substring(0, 2)
        now_hour = now.hour()

        oday = moment().tz('Europe/Helsinki')

        if start_hour > 16 and now_hour < 8
            # guess departure was yesterday instead of >8 hours in future
            oday.subtract(1, 'day')
        else if start_hour < 8 and now_hour > 16
            # guess departure is tomorrow instead of >8 hours ago
            oday.add(1, 'day')
        else
            oday = now
    else
        oday = undefined

    VP:
        desi: msg.trip.designation
        dir: msg.trip.direction
        dl: msg.position.delay
        jrn: msg.trip.journey
        lat: msg.position.latitude
        line: msg.vehicle.line
        long: msg.position.longitude
        oday: msg.trip.start_date or oday?.format("YYYY-MM-DD")
        oper: msg.trip.oper
        source: msg.source
        start: msg.trip.start_time
        stop_index: msg.position.next_stop_index
        trip_id: msg.trip.id
        tsi: Math.floor(msg.timestamp)
        tst: moment(msg.timestamp*1000).toISOString()
        spd: Math.round(msg.position.speed*100)/100
        hdg: msg.position.bearing
        odo: msg.position.odometer
        veh: msg.vehicle.id
        mode: msg.vehicle.mode


module.exports =
    to_mqtt_topic: to_mqtt_topic
    to_mqtt_payload: to_mqtt_payload
    mqtt_match: mqtt_match
