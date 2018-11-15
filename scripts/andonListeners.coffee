CodeRed = require "./code_red/codeRed"
FauxPas = require "./faux_pas/fauxPas"
BigSillies = require "./big_sillies/bigSillies"
BitsPlease = require "./bits_please/bitsPlease"
module.exports = (robot) ->

  # TODO Add a listener for "andon-help" and print a list of the below commands
  robot.hear /andon-help/i, (msg) ->
    msg.send "\
    *Andon Cord Help*\n\n \
    Use the word `andon` and it will respond appropriately for that channel.\n \
    `@evebot` must be added to the channel, and have a response coded for that channel.\n \
    "

  robot.hear /^( *andon.*|.*andon *)$/i, (msg) ->
    slackRoom = msg.envelope.room
    console.log("Message sent: ")
    console.log(msg.envelope.message.text)
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndon(msg)
    if slackRoom == process.env.CODERED_SLACK_CHANNEL_ID
      codeRedAndon(msg)
    if slackRoom == process.env.BIGSILLIES_SLACK_CHANNEL_ID
      bigSilliesAndon(msg)
    if slackRoom == process.env.BITSPLEASE_SLACK_CHANNEL_ID
      bitsPleaseAndon(msg)

  robot.hear /^( *andoff.*|.*andoff *)$/i, (msg) ->
    slackRoom = msg.envelope.room
    if slackRoom == process.env.FAUXPAS_SLACK_CHANNEL_ID
      fauxPasAndoff(msg)
    if slackRoom == process.env.BITSPLEASE_SLACK_CHANNEL_ID
      bitsPleaseAndoff(msg)

  codeRedAndon = (msg) ->
    codeRed = new CodeRed(robot, msg)
    codeRed.andonResponse()

  fauxPasAndon = (msg) ->
    text = msg.envelope.message.text
    regex = /^((andon)+.*)*(.*(andon) *)*$/i
    if (regex.test(text))
      fauxPas = new FauxPas(robot, msg)
      fauxPas.lightsOn();

  fauxPasAndoff = (msg) ->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOff()

  bigSilliesAndon = (msg) ->
    bigSillies = new BigSillies(robot, msg)
    bigSillies.lightsOn();

  bitsPleaseAndon = (msg) ->
    bitsPlease = new BitsPlease(robot, msg)
    bitsPlease.lightsOn()

  bitsPleaseAndoff = (msg) ->
    bitsPlease = new BitsPlease(robot, msg)
    bitsPlease.lightsOff()
