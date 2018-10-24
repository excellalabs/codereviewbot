CodeRed = require "./code_red/codeRed"
FauxPas = require "./faux_pas/fauxPas"

module.exports = (robot) ->

  # TODO Add a listener for "andon" and print a list of the below commands

  robot.hear /andon$/i, (msg) ->
    slackRoom = msg.envelope.room
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndon(msg)

  robot.hear /andoff/i, (msg) -> 
    slackRoom = msg.envelope.room
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndoff(msg)

  robot.hear /codered andon$/i, (msg) ->
    codeRed = new CodeRed(robot, msg)
    codeRed.andonResponse()

  fauxPasAndon = (msg) ->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOn();
  
  fauxPasAndoff = (msg) ->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOff()

