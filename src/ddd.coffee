_ = require 'underscore'

class DDD
  constructor: (options={}) ->
    @players = options.players
    @random_funtion = options.random ? Math.random

    @bag_of_gems = ['diamond']
    @add_to_bag 4,  'peridot'
    @add_to_bag 8,  'citrine'
    @add_to_bag 14, 'amethyst'
    @add_to_bag 10, 'coal'

    @pot = []
    @dice = [1,1,1,1]

  add_to_bag: (quantity, gem) =>
    _.times quantity, => @bag_of_gems.push gem

  play: =>
    _.times 3, => @pot.push @take_random_gem_from_bag()
    @roll_the_dice()
    _.first(@players).take_a_turn _.clone(@pot), @dice, @reroll

  random: (min, max) =>
    unless max?
      max = min
      min = 0

    return min + Math.floor(@random_funtion() * (max - min + 1))

  reroll: (rerolls) =>
    _.each rerolls, (reroll, i) =>
      if reroll
        @dice[i] = @random 0, 6

  roll_the_dice: =>
    _.each @dice, (val, i) =>
      @dice[i] = @random 0, 6

  take_random_gem_from_bag: =>
    index = @random 0, @bag_of_gems.length - 1
    gem = @bag_of_gems[index]
    @bag_of_gems.splice index, 1
    return gem


module.exports = DDD
