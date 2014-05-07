Table  = require 'cli-table'
prompt = require 'prompt'
_      = require 'underscore'

class HumanPlayer
  constructor: (options) ->
    @name = options.name
    @winnings = []

  end_turn: (prize) =>
    _.each prize, (gem) =>
      @winnings.push gem

    console.log "You won: ", prize
    console.log "Current winnings: ", @winnings
    console.log "==================="

  input_to_boolean: (input) ->
    _.contains ['1', 'true', 'y', 'yes'], input.toLowerCase()

  take_a_turn: (pot, dice, cb) =>
    console.log "==================="
    console.log "#{@name}'s turn"

    table = new Table head: ['dice', 'pot'], colWidths: [20, 100]
    table.push [dice, pot]
    console.log table.toString()
    prompt.start()
    console.log "Which dice to reroll?"
    prompt.get ['die_1', 'die_2', 'die_3', 'die_4'], (err, results) =>
      freezes =  [
        @input_to_boolean results.die_1
        @input_to_boolean results.die_2
        @input_to_boolean results.die_3
        @input_to_boolean results.die_4
      ]
      cb freezes

module.exports = HumanPlayer
