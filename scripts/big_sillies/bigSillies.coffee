ChannelResponder = require '../utilities/channelResponder'

module.exports =
class BigSillies extends ChannelResponder

  constructor: (robot, msg)->
    channelId = process.env.BIGSILLIES_SLACK_CHANNEL_ID
    super(channelId, robot, msg)

  silliesIftttKey: process.env.SILLIES_IFTTT_KEY

  lightsOn: () ->
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{@silliesIftttKey}"
    @robot.http(url)
      .get() (httpErr , httpRes) =>
        @msg.send "quiet ANDON CORD PULLED!!!"
        @msg.send httpRes
        console.log(httpErr)
    