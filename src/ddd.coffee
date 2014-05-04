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

    @winnings = []
    _.each @players, (player) =>
      @winnings[player] = []

  add_to_bag: (quantity, gem) =>
    _.times quantity, => @bag_of_gems.push gem

  extract: (desired_gem) =>
    _.where @pot, desired_gem

  n_of_a_kind: (n) =>
    _.any _.countBy(@dice), (count) => count == n

  pair: =>
    @n_of_a_kind 2

  play: =>
    @roll_count = 0
    _.times 3, => @pot.push @take_random_gem_from_bag()
    @roll_the_dice()
    @player_takes_a_turn()

  player_ends_turn: =>
    prize = @prize()
    player = _.first @players

    @pot = _.difference @pot, prize
    _.each prize, (gem) => @winnings[player].push gem
    player.end_turn prize

  player_takes_a_turn: =>
    _.first(@players).take_a_turn _.clone(@pot), @dice, @reroll

  prize: =>
    if @quads()    then return @extract 'diamond'
    if @two_pair() then return @extract 'peridot'
    if @straight() then return @extract 'citrine'
    if @trips()    then return @extract 'amethyst'
    if @pair()     then return @extract 'coal'
    return []

  quads: =>
    @n_of_a_kind 4

  random: (min, max) =>
    unless max?
      max = min
      min = 0

    return min + Math.floor(@random_funtion() * (max - min + 1))

  reroll: (rerolls) =>
    @roll_the_dice rerolls
    if @roll_count < 3 || _.contains(@dice, 6)
      @player_takes_a_turn()
    else
      @player_ends_turn()

  roll_the_dice: (rerolls=[true,true,true,true]) =>
    @roll_count++
    _.each @dice, (val, i) =>
      if val != 1 && rerolls[i]
        @dice[i] = @random 0, 6

  straight: =>
    min = _.min(@dice)
    max = _.max(@dice)
    unique_dice = _.uniq @dice
    max - min == 3 && _.size(unique_dice) == 4

  take_random_gem_from_bag: =>
    index = @random 0, @bag_of_gems.length - 1
    gem = @bag_of_gems[index]
    @bag_of_gems.splice index, 1
    return gem

  trips: =>
    @n_of_a_kind 3

  two_pair: =>
    _.all _.countBy(@dice), (count) => count == 2



module.exports = DDD
