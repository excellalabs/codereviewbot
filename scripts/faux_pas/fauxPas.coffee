ChannelResponder = require '../utilities/channelResponder'

module.exports =
class FauxPas extends ChannelResponder

  constructor: (robot, msg)->
    channelId = 'G6WUAFP2S'
    super(channelId, robot, msg)

  lightsOn: () ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    @robot.http(url)
      .get() (httpErr , httpRes) =>
        @msg.send "@here ANDON CORD PULLED!!!"
        @msg.send httpRes

  lightsOff: () ->
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/dI-HX-mjviMAz715B5ahqae5XJ1oM_hQg6ttG_UA0HP"
    @robot.http(url)
      .get() (httpErr, httpRes) =>
        @msg.send httpRes
