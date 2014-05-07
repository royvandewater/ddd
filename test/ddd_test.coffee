DDD        = require '../src/ddd'
_          = require 'underscore'
seedrandom = require 'seedrandom'

describe 'DDD', ->
  it 'should instantiate', ->
    new DDD

  describe 'bag_of_gems', ->
    beforeEach ->
      @sut = new DDD
      @counts = _.countBy @sut.bag_of_gems, (gem) -> gem

    it 'should contain a bag of gems', ->
      expect(@sut.bag_of_gems).to.be.an 'Array'

    it 'should have one diamond in the bag', ->
      expect(@counts.diamond).to.equal 1

    it 'should have four peridots in the bag', ->
      expect(@counts.peridot).to.equal 4

    it 'should have eight citrines in the bag', ->
      expect(@counts.citrine).to.equal 8

    it 'should have 14 amethysts in the bag', ->
      expect(@counts.amethyst).to.equal 14

    it 'should have 10 coals in the bag', ->
      expect(@counts.coal).to.equal 10

    it 'should have a total length of 37', ->
      expect(@sut.bag_of_gems).to.have.a.lengthOf 37

  describe 'pair', ->
    describe 'when there is no pair', ->
      beforeEach ->
        @sut = new DDD()
        @sut.dice = [1,2,3,4]

      it 'should return something falsy', ->
        expect(@sut.pair()).to.be.false

    describe 'when there is a pair', ->
      beforeEach ->
        @sut = new DDD()
        @sut.dice = [1,1,3,4]

      it 'should return true', ->
        expect(@sut.pair()).to.be.true

  describe 'play', ->
    describe 'the pot', ->
      describe 'at the start of the game', ->
        it 'should be empty', ->
          @sut = new DDD
          expect(@sut.pot).to.be.empty

      describe 'with the default bag_of_gems', ->
        beforeEach ->
          @sut = new DDD players: [new FakePlayer]
          @sut.play()

        it 'should add three gems to the pot', ->
          expect(@sut.pot).to.have.a.lengthOf 3

        it 'should remove three gems from the bag_of_gems', ->
          expect(@sut.bag_of_gems).to.have.a.lengthOf 37 - 3

      describe 'if the bag_of_gems has only three coal left', ->
        beforeEach ->
          @sut = new DDD players: [new FakePlayer]
          @sut.bag_of_gems = ['coal', 'coal', 'coal']
          @sut.play()

        it 'should take that coal and put it in the pot', ->
          expect(@sut.pot).to.deep.equal ['coal', 'coal', 'coal']

      describe 'if the bag_of_gems has only three gems left', ->
        beforeEach ->
          @sut = new DDD players: [new FakePlayer]
          @sut.bag_of_gems = ['peridot', 'diamond', 'amethyst']
          @sut.play()

        it 'should take those gems and put them in the pot', ->
          expect(@sut.pot).to.include.members ['peridot', 'diamond', 'amethyst']

    describe 'with a player', ->
      beforeEach ->
        @player1 = new FakePlayer
        @sut = new DDD players: [@player1]
        @sut.play()

      it 'should add three gems to the pot', ->
        expect(@sut.pot).to.have.a.lengthOf 3

      it 'should remove three gems from the bag_of_gems', ->
        expect(@sut.bag_of_gems).to.have.a.lengthOf 37 - 3

      it 'should notify player 1 that his turn is up', ->
        expect(@player1.take_a_turn_was_called).to.be.true

      it 'should give the player a copy of the pot', ->
        first_argument = @player1.take_a_turn_arguments[0]
        expect(first_argument).to.deep.equal @sut.pot
        expect(first_argument).to.not.equal @sut.pot

      it 'should give the player the set of 4 dice', ->
        second_argument = @player1.take_a_turn_arguments[1]
        expect(second_argument).to.have.a.lengthOf 4

      it 'should give the player a callback to call when done', ->
        third_argument = @player1.take_a_turn_arguments[2]
        expect(third_argument).to.be.a 'function'

    describe 'when last_turn is set to the player about to go', ->
      beforeEach ->
        @player = new FakePlayer
        @sut = new DDD players: [@player], console: new FakeConsole
        @sut.last_turn = @player
        @sut.play()

      it 'should end without letting the player take_a_turn', ->
        expect(@player.take_a_turn_was_called).to.be.false

  describe 'player_ends_turn', ->
    describe 'when there are two players', ->
      beforeEach ->
        @player1 = new FakePlayer
        @player2 = new FakePlayer
        @sut = new DDD players: [@player1, @player2]

      describe 'when the first player ends his turn', ->
        beforeEach ->
          @sut.current_player = @player1

        it 'should update current_player to @player2', ->
          @sut.player_ends_turn()
          expect(@sut.current_player).to.equal @player2

      describe 'when the second player ends his turn', ->
        beforeEach ->
          @sut.current_player = @player2

        it 'should update current_player to @player1', ->
          @sut.player_ends_turn()
          expect(@sut.current_player).to.equal @player1


    describe 'when the player wins nothing', ->
      beforeEach ->
        @player1 = new FakePlayer()
        @sut = new DDD players: [@player1]
        @sut.pot = ['diamond', 'coal', 'coal']
        @sut.dice = [1,3,4,5]
        @sut.player_ends_turn()

      it 'should call end_turn on the player', ->
        expect(@player1.end_turn_was_called).to.be.true

      it 'should call end_turn on the player with an empty array', ->
        expect(@player1.end_turn_arguments[0]).to.deep.equal []

    describe 'when the player has won all the coal', ->
      describe 'when there are two coal', ->
        beforeEach ->
          @player1 = new FakePlayer()
          @sut = new DDD players: [@player1], random: seedrandom('seed1')
          @sut.pot = ['diamond', 'coal', 'coal']
          @sut.dice = [1,1,4,5]
          @sut.player_ends_turn()

        it 'should call end_turn on the player with the coal', ->
          expect(@player1.end_turn_arguments[0]).to.deep.equal ['coal', 'coal']

        it 'should remove the coal from the pot', ->
          expect(@sut.pot).not.to.include 'coal'

      describe 'when there are three coal', ->
        beforeEach ->
          @player1 = new FakePlayer()
          @sut = new DDD players: [@player1]
          @sut.pot = ['diamond', 'coal', 'coal', 'coal']
          @sut.dice = [1,1,4,5]
          @sut.player_ends_turn()

        it 'should call end_turn on the player with the coal', ->
          expect(@player1.end_turn_arguments[0]).to.deep.equal ['coal', 'coal', 'coal']

    describe 'when the player has won all the amethyst', ->
      beforeEach ->
        @player1 = new FakePlayer()
        @sut = new DDD players: [@player1]
        @sut.pot = ['diamond', 'coal', 'coal', 'amethyst']
        @sut.dice = [3,3,3,5]
        @sut.player_ends_turn()

      it 'should call end_turn on the player with an the amethyst', ->
        expect(@player1.end_turn_arguments[0]).to.deep.equal ['amethyst']

      it 'should know that the player now has an amethyst', ->
        expect(@sut.winnings[@player1]).to.include 'amethyst'

    describe 'when the player has won all the citrine', ->
      beforeEach ->
        @player1 = new FakePlayer()
        @sut = new DDD players: [@player1]
        @sut.pot = ['citrine', 'coal', 'coal', 'amethyst']
        @sut.dice = [3,4,5,6]
        @sut.player_ends_turn()

      it 'should call end_turn on the player with an the citrine', ->
        expect(@player1.end_turn_arguments[0]).to.deep.equal ['citrine']

    describe 'when the player has won all the diamond', ->
      beforeEach ->
        @player1 = new FakePlayer()
        @sut = new DDD players: [@player1]
        @sut.pot = ['citrine', 'coal', 'diamond', 'amethyst']
        @sut.dice = [3,3,3,3]
        @sut.player_ends_turn()

      it 'should call end_turn on the player with an the diamond', ->
        expect(@player1.end_turn_arguments[0]).to.deep.equal ['diamond']

    describe 'when the player has won all the peridot', ->
      beforeEach ->
        @player1 = new FakePlayer()
        @sut = new DDD players: [@player1]
        @sut.pot = ['citrine', 'coal', 'peridot', 'amethyst']
        @sut.dice = [3,3,4,4]
        @sut.player_ends_turn()

      it 'should call end_turn on the player with the peridot', ->
        expect(@player1.end_turn_arguments[0]).to.deep.equal ['peridot']

  describe 'reroll', ->
    beforeEach ->
      @player1 = new FakePlayer
      @player2 = new FakePlayer
      @sut = new DDD players: [@player1, @player2], random: seedrandom('seed')
      @sut.dice = [2,2,2,2]

    describe 'when reroll is called', ->
      beforeEach ->
        @sut.reroll [false, false, false, false]

      it 'should call take_a_turn on the player', ->
        expect(@player1.take_a_turn_was_called).to.be.true

    describe 'when reroll is called for the third time', ->
      describe 'and there are no sixes', ->
        beforeEach ->
          @sut.dice = [2, 2, 2, 2]
          @sut.reroll [false, false, false, false]
          @sut.reroll [false, false, false, false]
          @player1.clear()
          @sut.reroll [false, false, false, false]

        it 'should not call take_a_turn', ->
          expect(@player1.take_a_turn_was_called).to.be.false

        it 'should instead call end_turn on the player', ->
          expect(@player1.end_turn_was_called).to.be.true

      describe 'and there is at least one 6', ->
        beforeEach ->
          @sut.dice = [2, 2, 6, 2]
          @sut.reroll [false, false, false, false]
          @sut.reroll [false, false, false, false]
          @player1.clear()
          @sut.reroll [false, false, false, false]

        it 'should call take_a_turn', ->
          expect(@player1.take_a_turn_was_called).to.be.true

    describe 'when reroll is called with falses', ->
      beforeEach ->
        @original_dice = _.clone @sut.dice
        @sut.reroll [false, false, false, false]

      it 'should not roll any dice', ->
        expect(@sut.dice).to.deep.equal @original_dice

    describe 'when reroll is called with trues', ->
      beforeEach ->
        @original_dice = _.clone @sut.dice
        @sut.reroll [true, true, true, true]

      it 'should roll all the dice', ->
        expect(@sut.dice).not.to.deep.equal @original_dice

    describe 'when reroll is called with a true and three falses', ->
      beforeEach ->
        @original_dice = _.clone @sut.dice
        @sut.reroll [true, false, false, false]

      it 'should roll the first die', ->
        expect(@sut.dice[0]).not.to.equal @original_dice[0]

      it 'should not reroll the other three die', ->
        expect(@sut.dice[1..3]).to.deep.equal @original_dice[1..3]

    describe 'when the dice contain a 1', ->
      beforeEach ->
        @sut.dice = [1,2,2,2]

      describe 'when the frozen die is asked to reroll', ->
        beforeEach ->
          @original_dice = _.clone @sut.dice
          @sut.reroll [true, false, false, false]

        it 'should not reroll it', ->
          expect(@sut.dice[0]).to.equal 1

  describe 'score', ->
    describe 'when a player has no winnings', ->
      it 'should return 0 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        expect(@sut.score(@player)).to.equal 0

    describe 'when a player has two peridot', ->
      it 'should return 14 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.winnings[@player] = ['peridot', 'peridot']
        expect(@sut.score(@player)).to.equal 14

    describe 'when a player has three citrine', ->
      it 'should return 12 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.winnings[@player] = ['citrine', 'citrine', 'citrine']
        expect(@sut.score(@player)).to.equal 12

    describe 'when a player has one citrine and one diamond', ->
      it 'should return 16 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.winnings[@player] = ['citrine', 'diamond']
        expect(@sut.score(@player)).to.equal 16

    describe 'when a player has an amethyst', ->
      it 'should return 2 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.winnings[@player] = ['amethyst']
        expect(@sut.score(@player)).to.equal 2

    describe 'when a player has an amethyst and one coal', ->
      it 'should return 1 for that player', ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.winnings[@player] = ['amethyst', 'coal']
        expect(@sut.score(@player)).to.equal 1

  describe 'straight', ->
    describe 'when there is no straight', ->
      beforeEach ->
        @sut = new DDD
        @sut.dice = [1,3,4,5]

      it 'should be false', ->
        expect(@sut.straight()).to.be.false

    describe 'when there is a straight', ->
      beforeEach ->
        @sut = new DDD
        @sut.dice = [2,3,4,5]

      it 'should be true', ->
        expect(@sut.straight()).to.be.true

  describe 'take_random_gem_from_bag', ->
    describe 'when the last gem is drawn', ->
      beforeEach ->
        @player = new FakePlayer
        @sut = new DDD players: [@player]
        @sut.bag_of_gems = ['amethyst']
        @sut.take_random_gem_from_bag()

      it 'should set last_turn to current_player', ->
        expect(@sut.last_turn).to.equal @sut.current_player

  describe 'two_pair', ->
    describe 'when there is no two pair', ->
      beforeEach ->
        @sut = new DDD
        @sut.dice = [1,2,4,5]

      it 'should return false', ->
        expect(@sut.two_pair()).to.be.false

    describe 'when there are two pair', ->
      beforeEach ->
        @sut = new DDD
        @sut.dice = [1,1,4,4]

      it 'should return true', ->
        expect(@sut.two_pair()).to.be.true

  describe 'winnings', ->
    describe 'when there are two players', ->
      beforeEach ->
        @player1 = new FakePlayer
        @player2 = new FakePlayer
        @sut = new DDD players: [@player1, @player2]

      it 'should have empty winnings for player 1', ->
        expect(@sut.winnings[@player1]).to.deep.equal []

      it 'should have empty winnings for player 2', ->
        expect(@sut.winnings[@player2]).to.deep.equal []

class FakePlayer
  constructor: ->
    @name = 'FakePlayer'
    @clear()

  clear: =>
    @take_a_turn_was_called = false
    @take_a_turn_arguments = undefined
    @end_turn_was_called = false
    @end_turn_arguments = undefined

  end_turn: =>
    @end_turn_was_called = true
    @end_turn_arguments = arguments

  take_a_turn: =>
    @take_a_turn_was_called = true
    @take_a_turn_arguments = arguments

class FakeConsole
  log: =>
