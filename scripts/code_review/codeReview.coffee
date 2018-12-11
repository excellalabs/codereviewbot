ChannelResponder = require '../utilities/channelResponder'

module.exports =
class CodeReview extends ChannelResponder

  constructor: (robot, msg)->
    channelId = process.env.ENR_CR_REQUESTS_SLACK_CHANNEL_ID
    super(channelId, robot, msg)

  startRequest: (res) ->
    @robot.requestor = "#{res.message.user.name}"
    @robot.display_name = "#{res.message.user.slack.profile.display_name}"

  usageString: () ->
    "enr-cr -n <number_of_random_reviewers> -i <list_of_ignored_users> -a <list_of_additional_reviewers>"

  parseOptions: (res) ->
    if (res.match[1] == undefined && res.match[2] == undefined)
      return @parseArgs(res)

    if (res.match[1] != ' ' || res.match[2] == undefined)
      return false

    return @parseArgs(res)

  parseArgs: (res) ->
    options = {
      requestor: @robot.requestor
      count: 1
      error: false
      igonored_reviewers: []
    }
    return options if res.match[2] == undefined

    args = res.match[2].split(' ')
    commands = {}
    while args.length != 0
      key = args.shift()
      if key[0] != '-'
        options.error = true
      value = ""
      while args.length != 0 && args[0][0] != '-'
        value += args.shift()
        value += " "
      value.substring(-1)
      commands[key] = value

    for k,v of commands
      switch k
        when '-n'
          if isFinite(v)
            options.count = parseInt(v)
          else
            options.error = true
        when '-a'
          options.additional_reviewers = v.split(' ')
        when '-i'
          options.igonored_reviewers = v.split(' ')

    return options

  getList: ->
    lists = @robot.brain.get('enr-cr')
    requestedList = lists.filter (list) =>
      list.some (name) =>
        name == @robot.display_name
    requestedList[0].slice(0) # this clones the array, it was doing weird things

  setList: (list) ->
    lists = @robot.brain.get('enr-cr')
    updateList = lists.filter (list) =>
      list.some (name) =>
        name == @robot.requestor

    index = lists.indexOf(updateList[0])
    lists[index] = list
    @robot.brain.set('enr-cr', lists)

  seedDataStructure: ->
    data = @robot.brain.get('enr-cr')
    if data == null
      @resetDataStructure()

  resetDataStructure: ->
    data =[
      ['andrew.eason', 'Josh Cohen', 'Nice.rson']
    ]
    @robot.brain.set('enr-cr', data)

  printList: (prefix, list, tagUsers = false) ->
    if tagUsers
      list = list.map (l) -> "@#{l}"
    else
      # splice in a random character to prevent slack for tagging everyone
      list = list.map (l) -> l.substring(0, 1) + '_' + l.substring(1)

    response = prefix
    console.log(list)
    for l in list
      response += (l + ", ")
    if list.count > 0
      response = response.substring(-1)
    console.log(response)
    return response

  cleanNames: (names, allowedValues = null) ->
    cleaned_names = []
    for name in names
      if !!name
        if name.indexOf('@') != -1
          name = name.substring(1)
        if allowedValues != null && allowedValues.indexOf(name) != -1
          cleaned_names.push(name)
        else
          cleaned_names.push(name)
    return cleaned_names

  subtractArray: (lhs, rhs) ->
    return lhs.filter( (n) -> rhs.indexOf(n) == -1)

  addArray: (lhs, rhs) ->
    for r in rhs
      lhs.push(r)
    return lhs
