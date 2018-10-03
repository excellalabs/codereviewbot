ChannelResponder = require '../utilities/channelResponder'

module.exports =
class FauxPas extends ChannelResponder

  iftttKey: process.env.FAUXPAS_IFTTT_KEY

  constructor: (robot, msg)->
    channelId = 'G6WUAFP2S'
    super(channelId, robot, msg)

  lightsOn: () ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{iftttKey}"
    @robot.http(url)
      .get() (httpErr , httpRes) =>
        @msg.send "@here ANDON CORD PULLED!!!"
        @msg.send httpRes

  lightsOff: () ->
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{iftttKey}"
    @robot.http(url)
      .get() (httpErr, httpRes) =>
        @msg.send httpRes
