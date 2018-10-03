CodeRed = require "./code_red/codeRed"
FauxPas = require "./faux_pas/fauxPas"

module.exports = (robot) ->

  # TODO Add a listener for "andon" and print a list of the below commands

  robot.hear /codered andon$/i, (msg) ->
    codeRed = new CodeRed(robot, msg)
    codeRed.andonResponse()

  robot.hear /fauxpas andon/i, (msg)->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOn()

  robot.hear /fauxpas andoff/i, (msg) ->
    fauxPas = new FauxPas(robot, msg)
    fauxPas.lightsOff()
