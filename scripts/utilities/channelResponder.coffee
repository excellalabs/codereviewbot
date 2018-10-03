module.exports =
class ChannelResponder

  constructor: (channelId, robot, msg)->
    @channelId = channelId
    @robot = robot
    @msg = msg
    @msgRoomId = msg.message.room
    @validateRoomId()

  validateRoomId: ()->
    if @msgRoomId != @channelId
      @robot.logger.error "Command not allowed in this channel! Allowed in room id: #{@channelId} Messge from room id: #{@msgRoomId}"
      throw new Error
