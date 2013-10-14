###
handywriteOnCanvas - renders handywrite text onto HTML canvas elements

Written in 2013 by Karl Naylor <kpn103@yahoo.com>

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software. If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
###

define ['./boxes'], (boxes) ->
  'use strict'

  class Grapheme
    # This is the base class for all graphemes. Most methods are included
    # here only as a form of documentation and provide fallback behaviours
    # that are essentially useless as defaults. A few methods have meaningful
    # default behaviours.

    constructor: ->
      @left = @right = null
      @_determined = true

    # `getKeywords` returns an object whose property names act as hints for
    # the layout system, eg. 'line' or 'circle'.
    getKeywords: -> {}

    # all rendering-related methods assume that we start drawing at (0,0)
    # and that an l-stroke is 1 unit long.

    # isDetermined is false iff this grapheme has more than one way of
    # rendering, and we have not yet decided which options to use
    isDetermined: -> @_determined

    # before calling `render` or any rendering-related getters,
    # clients should first set all graphemes' left and right
    # neighbours (null if there is none) and then call `decide` on
    # each grapheme to have them settle on a way of rendering.
    setLeftNeighbour: (@left) ->
    setRightNeighbour: (@right) ->
    decide: (force=false, fromLeft=false, fromRight=false) ->
      # if `force` is true, re-evaluate options even if we already did
      # `fromLeft` and `fromRight` indicate whether the request comes from
      # a neighbour, and are needed to prevent infinite mutual recursion

    # convenience methods to check whether we can find a determined
    # grapheme to our left or right
    _hasConstraintLeftward: ->
      @isDetermined() or (
        if @left then @left._hasConstraintLeftward() else false)
    _hasConstraintRightward: ->
      @isDetermined() or (
        if @right then @right._hasConstraintRightward() else false)

    getBoundingBox: -> new boxes.BoundingBox(0, 0, 0, 0)

    # the point where this grapheme attaches to its successor
    getFinishPoint: -> { x: 0, y: 0 }

    # the angles of this grapheme's stroke at its start and finish points;
    # 0 is along the +ve x axis, angle increases clockwise and is in radians.
    getEntryAngle: -> 0
    getExitAngle: -> 0
    
    # `ctx` should be pre-transformed so that implementations can render using
    # the co-ordinate system described above.
    render: (ctx) ->

  return Grapheme
