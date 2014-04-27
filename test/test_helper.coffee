chai          = require 'chai'
sinon         = require 'sinon'
sinonChai     = require 'sinon-chai'
async         = require 'async'

chai.use(sinonChai);

global.expect   = chai.expect
global.sinon    = sinon

