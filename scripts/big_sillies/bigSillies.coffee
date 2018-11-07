ChannelResponder = require '../utilities/channelResponder'

module.exports =
class BigSillies extends ChannelResponder

  constructor: (robot, msg)->
    channelId = process.env.BIGSILLIES_SLACK_CHANNEL_ID
    super(channelId, robot, msg)

  lightsOn: () ->
    @msg.send "@here ANDON CORD PULLED!!!"
