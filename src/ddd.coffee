_ = require 'underscore'
_.mixin require './underscore_math'
Table = require 'cli-table'

GEM_VALUES =
  diamond:  12
  peridot:   7
  citrine:   4
  amethyst:  2
  coal:     -1

class DDD
  constructor: (options={}) ->
    @players = options.players
    @random_funtion = options.random ? Math.random
    @print = options.console?.log ? console.log

    @bag_of_gems = ['diamond']
    @add_to_bag 4,  'peridot'
    @add_to_bag 8,  'citrine'
    @add_to_bag 14, 'amethyst'
    @add_to_bag 10, 'coal'

    @pot = []
    @reset_dice()
    @roll_count = 0

    @winnings = {}
    _.each @players, (player) =>
      @winnings[player] = []

    @current_player = _.first @players

  add_to_bag: (quantity, gem) =>
    _.times quantity, => @bag_of_gems.push gem

  end_game: =>
    @print 'Game Over'
    @print '========='
    @print ''
    @print @score_table()

  extract: (desired_gem) =>
    _.where @pot, desired_gem

  n_of_a_kind: (n) =>
    _.any _.countBy(@dice), (count) -> count == n

  next_player: =>
    index = @players.indexOf @current_player
    next_index = (index + 1) % _.size(@players)
    @players[next_index]

  pair: =>
    @n_of_a_kind 2

  play: =>
    return @end_game() if @last_turn == @current_player
    @roll_count = 0
    _.times 3, => @pot.push @take_random_gem_from_bag()
    @roll_the_dice()
    @player_takes_a_turn()

  player_ends_turn: =>
    prize = @prize()

    @pot = _.difference @pot, prize
    _.each prize, (gem) => @winnings[@current_player].push gem
    @current_player.end_turn prize
    @current_player = @next_player()
    @reset_dice()
    @play()

  player_takes_a_turn: =>
    @current_player.take_a_turn _.clone(@pot), _.clone(@dice), @reroll

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

    random_number = @random_funtion()

    return min + Math.floor(random_number * (max - min + 1))

  reroll: (rerolls) =>
    @roll_the_dice rerolls

    if @roll_count < 3
      @player_takes_a_turn()
    else if _.any(rerolls) && _.contains(@dice, 6)
      @player_takes_a_turn()
    else
      @player_ends_turn()

  reset_dice: =>
    @dice = [6,6,6,6]

  roll_the_dice: (rerolls=[true,true,true,true]) =>
    @roll_count++
    _.each @dice, (val, i) =>
      if val != 1 && rerolls[i]
        @dice[i] = @random 1, 6

  score: (player) =>
    _.sum _.map @winnings[player], (gem) -> GEM_VALUES[gem]

  score_table: =>
    table = new Table head: ['Player', 'Score']
    _.each @players, (player) =>
      table.push [player.name, @score(player)]
    table.toString()


  straight: =>
    min = _.min(@dice)
    max = _.max(@dice)
    unique_dice = _.uniq @dice
    max - min == 3 && _.size(unique_dice) == 4

  take_random_gem_from_bag: =>
    index = @random 0, @bag_of_gems.length - 1
    gem = @bag_of_gems[index]
    @bag_of_gems.splice index, 1
    if _.isEmpty @bag_of_gems
      @last_turn = @current_player
    return gem

  trips: =>
    @n_of_a_kind 3

  two_pair: =>
    _.all _.countBy(@dice), (count) -> count == 2

module.exports = DDD
