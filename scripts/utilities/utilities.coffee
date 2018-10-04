flattenArray = (array) ->
  array.reduce (a, b) ->
    a.concat(b)

getValues = (object) ->
  Object.keys(object).map (key) ->
    object[key]

shuffleArray = (array) ->
  return array.sort () =>
    Math.random() - 0.5

module.exports =
  flattenArray: flattenArray
  getValues: getValues
  shuffleArray: shuffleArray
