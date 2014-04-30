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
    @roll_count = 0

  add_to_bag: (quantity, gem) =>
    _.times quantity, => @bag_of_gems.push gem

  play: =>
    @roll_count = 0
    _.times 3, => @pot.push @take_random_gem_from_bag()
    @roll_the_dice()
    @player_takes_a_turn()

  player_takes_a_turn: =>
    _.first(@players).take_a_turn _.clone(@pot), @dice, @reroll

  random: (min, max) =>
    unless max?
      max = min
      min = 0

    return min + Math.floor(@random_funtion() * (max - min + 1))

  reroll: (rerolls) =>
    @roll_the_dice rerolls
    @player_takes_a_turn() if @roll_count < 3

  roll_the_dice: (rerolls=[true,true,true,true]) =>
    @roll_count++
    _.each @dice, (val, i) =>
      if rerolls[i]
        @dice[i] = @random 0, 6

  take_random_gem_from_bag: =>
    index = @random 0, @bag_of_gems.length - 1
    gem = @bag_of_gems[index]
    @bag_of_gems.splice index, 1
    return gem


module.exports = DDD
