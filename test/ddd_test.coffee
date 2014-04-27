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
    describe 'with two players', ->
      beforeEach ->
        @player1 = new FakePlayer
        @player2 = new FakePlayer
        @sut = new DDD players: [@player1, @player2]
        @sut.play()

      it 'should add three gems to the pot', ->
        expect(@sut.pot).to.have.a.lengthOf 3

      it 'should remove three gems from the bag_of_gems', ->
        expect(@sut.bag_of_gems).to.have.a.lengthOf 37 - 3

  describe 'pot', ->
    describe 'at the start of the game', ->
      it 'should be empty', ->
        @sut = new DDD
        expect(@sut.pot).to.be.empty

    describe 'if the bag_of_gems has only three coal left', ->
      beforeEach ->
        @sut = new DDD
        @sut.bag_of_gems = ['coal', 'coal', 'coal']
        @sut.play()

      it 'should take that coal and put it in the pot', ->
        expect(@sut.pot).to.deep.equal ['coal', 'coal', 'coal']

    describe 'if the bag_of_gems has only three gems left', ->
      beforeEach ->
        @sut = new DDD
        @sut.bag_of_gems = ['peridot', 'diamond', 'amethyst']
        @sut.play()

      it 'should take those gems and put them in the pot', ->
        expect(@sut.pot).to.include.members ['peridot', 'diamond', 'amethyst']


class FakePlayer


