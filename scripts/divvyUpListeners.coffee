utilities = require("./utilities/utilities")

module.exports = (robot) ->
  robot.hear /^divvy-up$/,  (res) ->
    robot.divvyUpHelpResponse(res)

  robot.hear /divvy-up([ ])+([a-z. 0-9,_,&,!,@,#,\$,%,\^,\*,\(,\)]*)?([\-@_a-z. 0-9]*)*$/i, (res) ->

    console.log("divvy-up called")

    robot.requestor = "#{res.message.user.name}"
    robot.setTeamMembers()

    options = robot.getOptions(res)
    teamMembers = robot.getTeamMembers(res, options.ignoredTeamMembers, options.addedTeamMembers, options.teams)
    items = robot.getItems(res)

    randomizedItems = utilities.shuffleArray(items)
    randomizedMembers = utilities.shuffleArray(teamMembers)

    assignedItems = robot.assign(randomizedItems, randomizedMembers)

    if Object.keys(assignedItems).length == 0
      robot.divvyUpHelpResponse(res)
    else
      res.send "Assignments \n" + robot.printAssignments(assignedItems) + "\n\n" + robot.printTeams(options.teams)

    console.log 'divvy-up ended'

  robot.hear /divvy-up-help$/i, (res) ->
    robot.divvyUpHelpResponse(res)

  robot.hear /^divvy-up-teams([ ])+([a-z. 0-9,_,&,!,@,#,\$,%,\^,\*,\(,\)]*)?([\-@_a-z. 0-9]*)*$/i,  (res) ->
    console.log("divvy-up-teams called")
    robot.setTeamMembers()
    teams = robot.getTeams()
    items = robot.getItems(res)
    assignments = robot.assign(items, teams)
    res.send "Assignments \n" + robot.printAssignments(assignments)
    robot.printAssignments(assignments)

  robot.getTeams = () =>
    teamsObject = robot.brain.get('teamMembers')
    Object.keys(teamsObject)

  robot.divvyUpHelpResponse = (res) ->
    startHelpMessage = "Need help using divvy-up?\n\n"
    usageString = "Usage:\ndivvy-up <list of items> -i <team members to ignore> -a <list of team members to add (one time only, not remembered)> -t <list of teams to pull users from>\n"
    helpText = "\nAll assignments are random.\nAll lists are space delimited.\nIf no teams are given with the -t option then it will draw team members from all teams.\n"
    res.send startHelpMessage + usageString + helpText

  robot.setTeamMembers = ->
    teamMembers = {
      fauxPas: ['brian.palladino', 'justdroo', 'joehunt', 'andrew', 'Andy Whitely', 'Nick Bristow'],
      bitsPlease: ['cameron.ivey', 'daneweber', 'hugh.gardiner', 'jenpen', 'jay_danielian'],
      bigSillies: ['daniel.herndon', 'dchang', 'khoi', 'glenn.espinosa', 'josh.cohen']
    }
    robot.brain.set('teamMembers', teamMembers)

  robot.getOptions = (res) ->
    if res.match[3] == undefined
      return {}
    allOptions = res.match[3].split("-").splice(1)
    ignoredTeamMembers = []
    addedTeamMembers = []
    teams = []
    allOptions.forEach (o) ->
      if o[0] == "i"
        ignoredTeamMembers = ignoredTeamMembers.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))
        ignoredTeamMembers.forEach (ignoredMember, index) ->
          ignoredTeamMembers[index] = ignoredMember.replace('@', '')
      else if o[0] == "a"
        addedTeamMembers = addedTeamMembers.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))
        addedTeamMembers.forEach (addedMember, index) ->
          addedTeamMembers[index] = addedMember.replace('@', '')
      else if o[0] == "t"
        teams = teams.concat(o.substring(1).split(" ").filter( (word) => return word != "" ))

    { "ignoredTeamMembers" : ignoredTeamMembers, "addedTeamMembers" : addedTeamMembers, "teams": teams}

  robot.getTeamMembers = (res, ignored = [], added = [], teams = []) ->
    allTeamMembers = robot.brain.get('teamMembers')
    requestedMembers = []

    if teams.length > 0
      teams.forEach (team) ->
        requestedMembers = requestedMembers.concat(allTeamMembers[team])
    else
      requestedMembers = utilities.getValues(allTeamMembers)
      requestedMembers = utilities.flattenArray(requestedMembers)

    ignored.forEach (ignoredMember) ->
      index = requestedMembers.indexOf(ignoredMember)
      if index != -1
        requestedMembers.splice(index, 1)

    requestedMembers.concat(added)

  robot.getItems = (res) ->
    if res.match[2] == undefined
      return []
    res.match[2].replace(/^\s+|\s+$/g, "").split(' ');

  robot.printAssignments = (assignedItems) ->
    assignmentString = ""
    for k, v of assignedItems
      assignmentString += '@' + k + ": " + v.toString(', ') + "\n"
    assignmentString

  robot.printTeams = (teams) ->
    teamsString = "Teams included in this divvy up:\n"
    allTeamMembers = robot.brain.get('teamMembers')

    if teams == undefined || teams == "" || teams.length == 0
      teams = Object.keys(allTeamMembers)

    teams.forEach (team) ->
      teamsString += team + ": " + allTeamMembers[team].join(', ') + "\n"

    return teamsString

  robot.assign = (items, teamMembers, assignedItems={}, itemIndex=0) ->
    teamMembers.forEach (member) ->
      if items[itemIndex] != undefined
        if assignedItems[member] == undefined
          assignedItems[member] = [items[itemIndex]]
        else
          assignedItems[member].push(items[itemIndex])
        itemIndex += 1

    rawValues = utilities.getValues(assignedItems)

    if rawValues.length == 0
      return {}

    assignedValues = rawValues.reduce (a, b) ->
      a.concat(b)

    if items.length > assignedValues.length
      robot.assign(items, teamMembers, assignedItems, itemIndex)

    assignedItems
