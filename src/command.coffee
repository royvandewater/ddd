DDD         = require './ddd'
HumanPlayer = require './human_player'

exports.run = ->
  player1 = new HumanPlayer name: 'Joe'
  player2 = new HumanPlayer name: 'Bob'
  ddd = new DDD players: [player1, player2]
  ddd.play()
