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
  iRadius = eRadius = 0.05

  graphemes.classes.i = class I extends Grapheme
    constructor: ->
      super()
      @_entryAngle = @_exitAngle = 0
      @_determined = false
      return

    getKeywords: ->
      obj = super()
      obj.circle = true
      return obj

    _withinHalfTurnOf: (angle, target) ->
      halfTurn = TAU * 0.5
      angle += TAU while angle < target - halfTurn
      angle -= TAU while angle >= target + halfTurn
      return angle

    decide: (force=false, fromLeft=false, fromRight=false) ->
      return if @_determined and not force

      # `angles` will contain the angles at which our neighbours enter
      # and leave us. If one or both neighbours are missing or
      # undecided, we will have less than two angles.
      angles = []
      if @left and not fromLeft
        @left.decide(force, false, true)
        angles.push(@left.getExitAngle())
      if @right and not fromRight
        @right.decide(force, true, false)
        angles.push(@right.getEntryAngle())
      switch angles.length
        when 0
          @_entryAngle = @_exitAngle = 0
          @_determined = true
          return
        when 1
          @_entryAngle = @_exitAngle = angles[0]
          @_determined = true
          return
        when 2
          angles[1] = @_withinHalfTurnOf(angles[1], angles[0])
          # if angle between a0 and a1 is obtuse, flip a1 to make it acute
          theta = Math.min(
            Math.abs(angles[1] - angles[0]),
            Math.abs(angles[0] - angles[1]))
          if theta > TAU / 4
            angles[1] = @_withinHalfTurnOf(angles[1] + TAU / 2, angles[0])
          # average the two angles to get our entry/exit angle
          @_entryAngle = @_exitAngle = (angles[0] + angles[1]) * 0.5
          @_determined = true
          return

    getBoundingBox: ->
      r = iRadius
      theta = @_entryAngle
      sinTheta = Math.sin(theta)
      cosTheta = Math.cos(theta)
      boxC = new boxes.BoundingBox(
          - r - r * sinTheta,
            r * cosTheta - r,
            r - r * sinTheta,
            r * cosTheta + r )
      boxCc = new boxes.BoundingBox(
          - r - r * sinTheta,
          - r * cosTheta - r,
            r - r * sinTheta,
            r * cosTheta - r )
      return boxes.combineBoundingBoxes [boxC, boxCc]

    getEntryAngle: -> @_entryAngle
    getExitAngle: -> @_exitAngle          
    getFinishPoint: -> { x: 0, y: 0 }

    render: (ctx) ->
      ctx.save()
      ctx.rotate(@_entryAngle)
      ctx.beginPath()
      ctx.arc(
        0, iRadius,
        iRadius,
        0, TAU,
        0) # anticlockwise
      ctx.stroke()
      ctx.beginPath()
      ctx.arc(
        0, - iRadius,
        iRadius,
        0, TAU,
        1) # anticlockwise
      ctx.stroke()
      ctx.restore()
      return

  graphemes.classes.aw = class AW extends Grapheme
    constructor: ->
      super()
      @_midlineAngle = 0
      @_determined = false
      return

    getKeywords: ->
      obj = super()
      obj.circle = true  # for now, OO is considered circle-like
      return obj

    decide: (force=false, fromLeft=false, fromRight=false) ->
      return if @_determined and not force

      # `angles` will contain the angles at which our neighbours enter
      # us. If one or both neighbours are missing or undecided, we
      # will have less than two angles.
      angles = []
      if @left and not fromLeft
        @left.decide(force, false, true)
        angles.push @left.getExitAngle()
      if @right and not fromRight
        @right.decide(force, true, false)
        angles.push @right.getEntryAngle() + TAU / 2
      switch angles.length
        when 0
          @_midlineAngle = TAU / 4
          @_determined = true
          return
        when 1
          @_midlineAngle = angles[0] - TAU / 4
          @_determined = true
          return
        when 2
          points = (geometry.vectorFromAngle(angle).p1 for angle in angles)
          midlineVector = new geometry.Vector(
            { x: 0, y: 0 },
            geometry.pointSum(points)
            )
          @_midlineAngle = midlineVector.angle()
          @_determined = true
          return

    _getControlPoints: ->
      return [
        { x: 0, y: 0 }
        geometry.rotatePoint(
          { x: lWidth / 3, y: - (lWidth / 6) }, @_midlineAngle)
        geometry.rotatePoint(
          { x: lWidth / 3, y: (lWidth / 6) }, @_midlineAngle)
        { x: 0, y: 0 }
        ]

    getBoundingBox: ->
      return boxes.boxFromPoints(@_getControlPoints())

    getEntryAngle: -> @_midLineAngle
    getExitAngle: -> @_midLineAngle
    getFinishPoint: -> { x: 0, y: 0 }

    render: (ctx) ->
      cp = @_getControlPoints()
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.bezierCurveTo(
        cp[1].x, cp[1].y,
        cp[2].x, cp[2].y,
        cp[3].x, cp[3].y)
      ctx.stroke()
      return

  return graphemes
  