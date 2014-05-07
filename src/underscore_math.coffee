_ = require 'underscore'

add = (first, second) -> first + second

exports.sum = (collection) ->
  _.reduce collection, add, 0
