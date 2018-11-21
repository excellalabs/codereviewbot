module.exports =
class ChannelResponder

  constructor: (channelId, robot, msg)->
    @channelId = channelId
    @robot = robot
    @msg = msg
    @msgRoomId = msg.message.room
    @validateRoomId()

  validateRoomId: ()->
    return if @msgRoomId == process.env.CODE_RED_SLACK_CHANNEL_ID
    if @msgRoomId != @channelId
      response = "Command not allowed in this channel! \n You called this command in channel '#{@msgRoomId}', but it is only allowed in channel '#{@channelId}'"
      @msg.send response
      @robot.logger.error response
      throw new Error
