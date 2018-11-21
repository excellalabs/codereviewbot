ChannelResponder = require '../utilities/channelResponder'

module.exports =
class FauxPas extends ChannelResponder

  constructor: (robot, msg)->
    channelId = process.env.FAUXPAS_SLACK_CHANNEL_ID
    super(channelId, robot, msg)

  iftttKey: process.env.FAUXPAS_IFTTT_KEY

  lightsOn: () ->
    console.log("calling it")
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{@iftttKey}"
    @robot.http(url)
      .get() (httpErr , httpRes) =>
        @msg.send "@here ANDON CORD PULLED!!!"
        @msg.send httpRes
        callback = @lightsOff.bind(this)
        setTimeout callback, 30000

  lights: () ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{@iftttKey}"
    @robot.http(url)
      .get() (httpErr , httpRes) =>
        @msg.send httpRes      

  lightsOff: () ->
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{@iftttKey}"
    @robot.http(url)
      .get() (httpErr, httpRes) =>
        @msg.send httpRes
