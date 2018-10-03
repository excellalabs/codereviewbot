ChannelResponder = require '../utilities/channelResponder'

module.exports =
class CodeRed extends ChannelResponder

  constructor: (robot, msg)->
    channelId = ''
    super(channelId, robot, msg)

  andonResponse: () ->
    @msg.send "@here CODE RED! Stop what you're doing find out you can do to help."
