CodeRed = require "./code_red/codeRed"
FauxPas = require "./faux_pas/fauxPas"

module.exports = (robot) ->

  # TODO Add a listener for "andon-help" and print a list of the below commands
  robot.hear /andon-help/i, (msg) ->
    msg.send "\
    *Andon Cord Help*\n\n \
    Use the word `andon` and it will respond appropriately for that channel.\n \
    `@evebot` must be added to the channel, and have a response coded for that channel.\n \
    "

  robot.hear /andon/i, (msg) ->
    slackRoom = msg.envelope.room
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndon(msg)
    if slackRoom == process.env.CODERED_SLACK_CHANNEL_ID
      codeRedAndon(msg)

  robot.hear /andoff/i, (msg) ->
    slackRoom = msg.envelope.room
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndoff(msg)
    if slackRoom == process.env.CODERED_SLACK_CHANNEL_ID
      codeRedAndon(msg)

  codeRedAndon = (msg) ->
    codeRed = new CodeRed(robot, msg)
    codeRed.andonResponse()

  fauxPasAndon = (msg) -> 
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOn();

  fauxPasAndoff = (msg) ->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOff()
