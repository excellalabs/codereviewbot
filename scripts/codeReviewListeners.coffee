CodeReview = require "./code_review/codeReview"

module.exports = (robot) ->

  # /enr-cr[\ ]?(\d*)?[\ ]?([@a-z\.\ ]*)?$/i
  robot.hear /enr-cr([ ])?([\-@a-z. 0-9]*)?$/i, (res) ->
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr called'
    codeReview.seedDataStructure()
    options = codeReview.parseOptions(res)

    if !options
      return

    if options.error
      res.send codeReview.usageString()
      return


    list = codeReview.getList()

    reviewers = []
    #add extra reviewers and put them on the back if there are any
    if options.additional_reviewers != undefined
      additional_reviewers = codeReview.cleanNames(options.additional_reviewers, list)
      while additional_reviewers.length != 0
        extra = additional_reviewers.shift()
        reviewers.push(extra)
        list.splice(list.indexOf(extra), 1)
        list.push(extra)

    # get next count reviewers
    options.igonored_reviewers.push(options.requestor)
    ignored_reviewers = codeReview.cleanNames(options.igonored_reviewers, list)
    if ignored_reviewers.count > list.count
      res.send "Too many people ignored!"
      return

    while options.count != 0
      # inorder list of available people
      available_reviewers = codeReview.subtractArray(list, ignored_reviewers)
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

    codeReview.setList(list)
    res.send codeReview.printList("Assigned Reviewers: ", reviewers, true)
    console.log 'enr-cr ended'


  robot.hear /enr-cr-set ([@a-z. ]*)+$/i, (res) ->
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr-set called'
    codeReview.seedDataStructure()
    cr_list = codeReview.cleanNames(res.match[1].split(' '))

    codeReview.setList(cr_list)
    res.send codeReview.printList("New Order: ", cr_list)
    console.log 'enr-cr-set ended'

  robot.hear /enr-cr-add ([@a-z. ]*)+$/i, (res) ->
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr-add called'
    codeReview.seedDataStructure()
    cr_list = codeReview.getList()
    names = codeReview.cleanNames(res.match[1].split(' '))
    cr_list = codeReview.addArray(cr_list, names)

    codeReview.setList(cr_list)
    res.send codeReview.printList("New Order: ", cr_list)
    console.log 'enr-cr-add ended'

  robot.hear /enr-cr-remove ([@a-z. ]*)+$/i, (res) =>
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr-remove called'
    codeReview.seedDataStructure()
    cr_list = codeReview.getList()
    names = codeReview.cleanNames(res.match[1].split(' '), cr_list)
    cr_list = codeReview.subtractArray(cr_list, names)

    codeReview.setList(cr_list)
    res.send codeReview.printList("New Order: ", cr_list)
    console.log 'enr-cr-remove ended'

  robot.hear /enr-cr-order/i, (res) ->
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr-order called'
    codeReview.seedDataStructure()
    cr_list = codeReview.getList()
    res.send codeReview.printList("Current Order: ", cr_list)
    console.log 'enr-cr-order ended'

  robot.hear /enr-cr-reset$/i, (res) ->
    codeReview = new CodeReview(robot, res)
    codeReview.startRequest(res)
    console.log 'enr-cr-reset called'
    codeReview.resetDataStructure()
    cr_list = codeReview.getList()
    res.send codeReview.printList("New Order: ", cr_list)
    console.log 'enr-cr-reset ended'
