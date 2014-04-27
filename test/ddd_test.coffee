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

