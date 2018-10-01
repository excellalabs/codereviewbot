module.exports = (robot) ->

  robot.hear /andon$/i, (msg) ->
    if msg.message.room == 'G6WUAFP2S'
      robot.lights_on(msg)
      setTimeout robot.lights_off, 30000

  robot.hear /andoff$/i, (msg) ->
    if msg.message.room == 'G6WUAFP2S'
      robot.lights_off(msg)

  robot.lights_on = (msg) ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    robot.http(url)
      .get() (httpErr, httpRes) ->
        msg.send "@here ANDON CORD PULLED!!!"
        msg.send httpRes

  robot.lights_off = (msg) ->
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    robot.http(url)
      .get() (httpErr, httpRes) ->
        msg.send httpRes
