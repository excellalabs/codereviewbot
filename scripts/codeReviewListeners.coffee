module.exports = (robot) ->

  # /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i
  robot.hear /enr-cr([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    robot.startRequest(res)
    console.log 'enr-cr called'
    robot.seedDataStructure()
    options = robot.parseOptions(res)

    if !options
      return

    if options.error
      res.send robot.usageString()
      return


    list = robot.getList()

    reviewers = []
    #add extra reviewers and put them on the back if there are any
    if options.additional_reviewers != undefined
      additional_reviewers = robot.cleanNames(options.additional_reviewers, list)
      while additional_reviewers.length != 0
        extra = additional_reviewers.shift()
        reviewers.push(extra)
        list.splice(list.indexOf(extra), 1)
        list.push(extra)

    # get next count reviewers
    options.igonored_reviewers.push(options.requestor)
    ignored_reviewers = robot.cleanNames(options.igonored_reviewers, list)
    if ignored_reviewers.count > list.count
      res.send "Too many people ignored!"
      return

    while options.count != 0
      # inorder list of available people
      available_reviewers = robot.subtractArray(list, ignored_reviewers)
      if available_reviewers.count < 1
        res.send "No available reviewers!"
        return

      next_reviewer = available_reviewers[0]

      # remove them
      list.splice(list.indexOf(next_reviewer), 1)

      # get the reviewer
      reviewers.push(next_reviewer)

      # put reviewer on back
      list.push(next_reviewer)

      # next request
      options.count--

    robot.setList(list)
    res.send robot.printList("Assigned Reviewers: ", reviewers, true)
    console.log 'enr-cr ended'


  robot.hear /enr-cr-set ([@a-z. ]*)+$/i, (res) ->
    robot.startRequest(res)
    console.log 'enr-cr-set called'
    robot.seedDataStructure()
    cr_list = robot.cleanNames(res.match[1].split(' '))

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    console.log 'enr-cr-set ended'

  robot.hear /enr-cr-add ([@a-z. ]*)+$/i, (res) ->
    robot.startRequest(res)
    console.log 'enr-cr-add called'
    robot.seedDataStructure()
    cr_list = robot.getList()
    names = robot.cleanNames(res.match[1].split(' '))
    cr_list = robot.addArray(cr_list, names)

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    console.log 'enr-cr-add ended'

  robot.hear /enr-cr-remove ([@a-z. ]*)+$/i, (res) =>
    robot.startRequest(res)
    console.log 'enr-cr-remove called'
    robot.seedDataStructure()
    cr_list = robot.getList()
    names = robot.cleanNames(res.match[1].split(' '), cr_list)
    cr_list = robot.subtractArray(cr_list, names)

    robot.setList(cr_list)
    res.send robot.printList("New Order: ", cr_list)
    console.log 'enr-cr-remove ended'

  robot.hear /enr-cr-order/i, (res) ->
    robot.startRequest(res)
    console.log 'enr-cr-order called'
    robot.seedDataStructure()
    cr_list = robot.getList()
    res.send robot.printList("Current Order: ", cr_list)
    console.log 'enr-cr-order ended'

  robot.hear /enr-cr-reset$/i, (res) ->
    robot.startRequest(res)
    console.log 'enr-cr-reset called'
    robot.resetDataStructure()
    cr_list = robot.getList()
    res.send robot.printList("New Order: ", cr_list)
    console.log 'enr-cr-reset ended'

#### HELPERS ###
  robot.startRequest = (res) ->
    robot.requestor = "#{res.message.user.name}"

  robot.usageString = () ->
    "enr-cr -n <number_of_random_reviewers> -i <list_of_ignored_users> -a <list_of_additional_reviewers>"

  robot.parseOptions = (res) ->
    if (res.match[1] == undefined && res.match[2] == undefined)
      return robot.parseArgs(res)

    if (res.match[1] != ' ' || res.match[2] == undefined)
      return false

    return robot.parseArgs(res)

  robot.parseArgs = (res) ->

    options = {
      requestor: robot.requestor
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

  robot.getList = ->
    lists = robot.brain.get('enr-cr')
    requestedList = lists.filter (list) ->
      list.some (name) ->
        name == robot.requestor
    requestedList[0].slice(0) # this clones the array, it was doing weird things


  robot.setList = (list) ->
    lists = robot.brain.get('enr-cr')
    updateList = lists.filter (list) ->
      list.some (name) ->
        name == robot.requestor

    index = lists.indexOf(updateList[0])
    lists[index] = list
    robot.brain.set('enr-cr', lists)

  robot.seedDataStructure = ->
    data = robot.brain.get('enr-cr')
    if data == null
      robot.resetDataStructure()

  robot.resetDataStructure = ->
    data =[
      ['brian.palladino', 'cameron.ivey', 'daniel.herndon',
      'justdroo', 'daneweber', 'dchang',
      'hugh.gardiner', 'khoi',
      'joehunt', 'jenpen', 'glenn.espinosa', 'josh.cohen',
      'Nick Bristow', 'Andy Whitely', 'andrew', 'jay_danielian']
    ]
    robot.brain.set('enr-cr', data)

  robot.printList = (prefix, list, tagUsers = false) ->
    if tagUsers
      list = list.map (l) -> "@#{l}"
    else
      # splice in a random character to prevent slack for tagging everyone
      list = list.map (l) -> l.substring(0, 1) + '_' + l.substring(1)

    response = prefix
    for l in list
      response += (l + ", ")
    if list.count > 0
      response = response.substring(-1)
    return response


  robot.cleanNames = (names, allowedValues = null) ->
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

  robot.subtractArray = (lhs, rhs) ->
    return lhs.filter( (n) -> rhs.indexOf(n) == -1)

  robot.addArray = (lhs, rhs) ->
    for r in rhs
      lhs.push(r)
    return lhs
