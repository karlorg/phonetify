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

define ['../grapheme', '../boxes', '../geometry'], (Grapheme, boxes, geometry) ->
  'use strict'

  graphemes = {}
  graphemes.classes = {}

  TAU = 2 * Math.PI  # TAU is one full turn in radians

  iRadius = eRadius = 0.05
  aRadius = oRadius = 0.1
  lWidth = 1

  class Circle extends Grapheme
    _radius: 0  # base classes should override
    _fixedDirection: false  # base classes to override

    constructor: ->
      super
      @_determined = false
      @_entryAngle = 0
      @_exitAngle = TAU
      @_anticlockwise = false  # base classes should override

    getKeywords: ->
      obj = super()
      obj.circle = true
      return obj

    # convenience method to normalize entry and exit angles to lie between
    # 0--TAU, and to set `@_determined`
    #
    # Also, if exit angle can't be made to fall within 0.35 TAU of
    # entry angle in the direction we're drawing, we set it to equal
    # to entry, otherwise we risk the next stroke intersecting an
    # earlier one.
    #
    # TODO: prevent intersections more accurately using knowledge of
    # other graphemes' shapes, or some other means
    _finalizeAngles: ->
      @_entryAngle += TAU while @_entryAngle < 0
      @_entryAngle -= TAU while @_entryAngle >= TAU
      @_exitAngle += TAU while @_exitAngle < 0
      @_exitAngle -= TAU while @_exitAngle >= TAU
      difference = (@_exitAngle - @_entryAngle) *
        (if @_anticlockwise then -1 else 1)
      difference += TAU while difference < 0
      unless 0 <= difference < 0.35 * TAU
        @_exitAngle = @_entryAngle
      @_determined = true
      return

    decide: (force=false, fromLeft=false, fromRight=false) ->
      return if @_determined and not force

      if fromLeft or not @left
        if @right and not fromRight
          @right.decide(force, true, false)
          @_exitAngle = @_entryAngle = @right.getEntryAngle()
        else
          @_entryAngle = @_exitAngle = 0
      else # not fromLeft, left neighbour exists
        @left.decide(force, false, true)
        @_entryAngle = @left.getExitAngle()
        if fromRight or not @right
          @_exitAngle = @_entryAngle
        else
          @right.decide(force, true, false)
          @_exitAngle = @right.getEntryAngle()
      @_finalizeAngles()
      return

    getBoundingBox: ->
      r = @_radius
      theta = @_entryAngle
      sinTheta = Math.sin(theta)
      cosTheta = Math.cos(theta)
      clockwise = if @_anticlockwise then -1 else 1
      return new boxes.BoundingBox(
        - r - r * sinTheta,
          (r * cosTheta * clockwise) - r,
          r - r * sinTheta,
          r * cosTheta + (r * clockwise) )

    getFinishPoint: ->
      bbox = @getBoundingBox()
      offset = { x: bbox.left(), y: bbox.top() }
      r = @_radius
      theta = @_exitAngle
      sinTheta = Math.sin(theta)
      cosTheta = Math.cos(theta)
      clockwise = if @_anticlockwise then -1 else 1
      return {
        x: r * sinTheta + r + offset.x
        y: r - clockwise * r * cosTheta + offset.y }

    getEntryAngle: -> @_entryAngle
    getExitAngle: -> @_exitAngle

    render: (ctx) ->
      ctx.save()
      ctx.rotate(@_entryAngle)
      ctx.beginPath()
      ctx.arc(
        0, @_radius * (if @_anticlockwise then -1 else 1),
        @_radius,
        0, TAU,
        @_anticlockwise)
      ctx.stroke()
      ctx.restore()
      return

  graphemes.classes.a = class A extends Circle
    _radius: aRadius
    _fixedDirection: true
    constructor: ->
      super
      @_anticlockwise = false

  graphemes.classes.ae = class AE extends Circle
    _radius: aRadius
    _fixedDirection: false
    getFinishPoint: ->
      bbox = @getBoundingBox()
      return {
        x: (bbox.left() + bbox.right()) * 0.5
        y: (bbox.top() + bbox.bottom()) * 0.5 }

  graphemes.classes.eh = class EH extends Circle
    _radius: iRadius
    _fixedDirection: true
    constructor: ->
      super
      @_anticlockwise = true

  graphemes.classes.ey = class EY extends Circle
    _radius: aRadius
    _fixedDirection: false
    render: (ctx) ->
      ctx.save()
      ctx.rotate(@_entryAngle)
      ctx.beginPath()
      ctx.arc(
        0, aRadius * (if @_anticlockwise then -1 else 1),
        aRadius,
        0, TAU,
        @_anticlockwise)
      ctx.stroke()
      ctx.beginPath()
      ctx.arc(
        0, iRadius * (if @_anticlockwise then -1 else 1),
        iRadius,
        0, TAU,
        @_anticlockwise)
      ctx.stroke()
      ctx.restore()
      return

  graphemes.classes.ih = class IH extends Circle
    _radius: iRadius
    _fixedDirection: true
    constructor: ->
      super
      @_anticlockwise = false

  graphemes.classes.uh = class UH extends Circle
    _radius: aRadius
    _fixedDirection: true
    constructor: ->
      super
      @_anticlockwise = true

  return graphemes
  