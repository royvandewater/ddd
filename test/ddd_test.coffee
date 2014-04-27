DDD = require '../src/ddd'
_   = require 'underscore'

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

    describe 'with two players', ->
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

  describe 'reroll', ->
    beforeEach ->
      @player1 = new FakePlayer
      @sut = new DDD players: [@player1]
      @sut.play()

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






class FakePlayer
  take_a_turn: =>
    @take_a_turn_was_called = true
    @take_a_turn_arguments = arguments


