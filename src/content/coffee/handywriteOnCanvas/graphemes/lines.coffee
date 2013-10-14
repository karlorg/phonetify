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

  lWidth = 1

  shAngle = zhAngle = TAU / 3
  dAngle = tAngle = - TAU / 12
  ngAngle = nkAngle = TAU / 12
  dLength = lWidth
  ayHeight = lWidth * 0.2
  jHeight = lWidth * 0.8
  shHeight = zhHeight = lWidth * 0.4
  mWidth = lWidth
  nWidth = lWidth * 0.4
  tLength = lWidth * 0.4

  class Line extends Grapheme
    # subclasses should override `_endPoint`
    getKeywords: ->
      obj = super()
      obj.line = true
      return obj
    _endPoint: { x: 0, y: 0 }
    getBoundingBox: -> new boxes.BoundingBox(
      Math.min(0, @_endPoint.x), Math.min(0, @_endPoint.y),
      Math.max(0, @_endPoint.x), Math.max(0, @_endPoint.y))
    getFinishPoint: -> { x: @_endPoint.x, y: @_endPoint.y }
    getEntryAngle: -> new geometry.Vector({x:0,y:0}, @_endPoint).angle()
    getExitAngle: -> new geometry.Vector({x:0,y:0}, @_endPoint).angle()
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0, 0)
      ctx.lineTo(@_endPoint.x, @_endPoint.y)
      ctx.stroke()
      return

  graphemes.classes.ay = class AY extends Line
    _endPoint:
      # default value, may be modified by `decide()`
      x: 0
      y: ayHeight

    constructor: ->
      super
      @_determined = false
      return
    
    _chooseAngle: (constraints) ->
      # `constraints` is an array of angles we want to avoid (because our
      # neighbours are entering/exiting us at these angles)
      candidates = [
        { angle: 5 * TAU / 16, badness: 0 }
        { angle: 4 * TAU / 16, badness: 0 }
        { angle: 3 * TAU / 16, badness: 0 }
        ]
      for constraint in constraints
        for candidate in candidates
          delta = Math.abs(constraint - candidate.angle)
          badness = if delta == 0 then 100 else Math.min(100, 1 / delta)
          candidate.badness = Math.max(candidate.badness, badness)
      # add a mild artificial bias for the vertical line, as it is more
      # 'standard'
      candidates[1].badness -= 1
      choice = candidates[0]
      for candidate in candidates[1..] when candidate.badness < choice.badness
        choice = candidate
      # now we have our choice, apply it
      @_endPoint =
        x: ayHeight * Math.cos(choice.angle)
        y: ayHeight * Math.sin(choice.angle)
      @_determined = true
      return

    decide: (force=false, fromLeft=false, fromRight=false) ->
      return if @_determined and not force

      if fromLeft or not @left
        if @right and not @right.getKeywords().circle?
          @right.decide(force, true, false)
          @_chooseAngle [@right.getEntryAngle()]
          return
        else
          @_chooseAngle []
          return
      else # not fromLeft, left neighbour exists
        unless @left.getKeywords().circle?
          @left.decide(force, false, true)
          if fromRight or not @right or @right.getKeywords().circle?
            @_chooseAngle [@left.getExitAngle()]
            return
          else # both sides provide constraints
            @right.decide(force, true, false)
            @_chooseAngle [@left.getExitAngle(), @right.getEntryAngle()]
            return
      # shouldn't be reachable, but...
      @_determined = true
      return

  graphemes.classes.ch = class CH extends Line
    _endPoint:
      x: jHeight * Math.cos(shAngle)
      y: jHeight * Math.sin(shAngle)

  graphemes.classes.d = class D extends Line
    _endPoint:
      x: dLength * Math.cos(dAngle)
      y: dLength * Math.sin(dAngle)

  graphemes.classes.j = class J extends Line
    _endPoint: { x: 0, y: jHeight }

  graphemes.classes.m = class M extends Line
    _endPoint: { x: mWidth, y: 0 }

  graphemes.classes.n = class N extends Line
    _endPoint: { x: nWidth, y: 0 }

  graphemes.classes.ng = class NG extends Line
    _endPoint:
      x: nWidth * Math.cos(ngAngle)
      y: nWidth * Math.sin(ngAngle)

  graphemes.classes.nk = class NK extends Line
    _endPoint:
      x: mWidth * Math.cos(nkAngle)
      y: mWidth * Math.sin(nkAngle)

  graphemes.classes.sh = class SH extends Line
    _endPoint:
      x: shHeight * Math.cos(shAngle)
      y: shHeight * Math.sin(shAngle)

  graphemes.classes.t = class T extends Line
    _endPoint:
      x: tLength * Math.cos(tAngle)
      y: tLength * Math.sin(tAngle)

  graphemes.classes.zh = class ZH extends Line
    _endPoint: { x: 0, y: zhHeight }

  return graphemes
  