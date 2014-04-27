_ = require 'underscore'

class DDD
  constructor: ->
    @bag_of_gems = ['diamond']
    @add_to_bag 4,  'peridot'
    @add_to_bag 8,  'citrine'
    @add_to_bag 14, 'amethyst'
    @add_to_bag 10, 'coal'

  add_to_bag: (quantity, gem) =>
    _.times quantity, => @bag_of_gems.push gem

module.exports = DDD
