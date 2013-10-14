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

  rWidth = 0.5
  lWidth = 1

  class CubicBezier extends Grapheme
    # a base class for a grapheme rendered as a single, fixed cubic bezier
    # curve. Subclasses should override _p[1..3] with their control points
    # (_p[0] should always be (0,0)).
    _p: [
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 } ]
    getBoundingBox: ->
      # for now just use the control points. TODO: compute the bounding
      # box correctly
      new boxes.BoundingBox(
        Math.min((p.x for p in @_p)...),
        Math.min((p.y for p in @_p)...),
        Math.max((p.x for p in @_p)...),
        Math.max((p.y for p in @_p)...))
    getFinishPoint: -> { x: @_p[3].x, y: @_p[3].y }
    getEntryAngle: -> new geometry.Vector(@_p[0], @_p[1]).angle()
    getExitAngle: -> new geometry.Vector(@_p[2], @_p[3]).angle()
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.bezierCurveTo(
        @_p[1].x, @_p[1].y,
        @_p[2].x, @_p[2].y,
        @_p[3].x, @_p[3].y)
      ctx.stroke()
      return

  graphemes.classes.b = class B extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: - 3 * lWidth / 12, y: lWidth / 2 },
      { x: - lWidth / 3, y: 11 * lWidth / 12 },
      { x: - lWidth / 4, y: lWidth } ]

  graphemes.classes.c = class C extends CubicBezier
    _p: [
      { x: 0, y: 0 }
      { x: - rWidth / 2, y: 0 }
      { x: - rWidth / 2, y: rWidth / 3 }
      { x: 0, y: rWidth / 3 } ]

  graphemes.classes.f = class F extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: rWidth / 12, y: rWidth / 12 },
      { x: lWidth / 10, y: rWidth / 2 },
      { x: - lWidth / 6, y: rWidth } ]

  graphemes.classes.g = class G extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: lWidth / 6, y: - lWidth / 6 },
      { x: lWidth / 2, y: - lWidth / 6 },
      { x: lWidth, y: 0 } ]

  graphemes.classes.l = class L extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: lWidth / 6, y: lWidth / 6 },
      { x: lWidth / 2, y: lWidth / 6 },
      { x: lWidth, y: 0 } ]

  graphemes.classes.k = class K extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: rWidth / 6, y: - lWidth / 6 },
      { x: rWidth / 2, y: - lWidth / 6 },
      { x: rWidth, y: 0 } ]

  graphemes.classes.o = class O extends CubicBezier
    _p: [
      { x: 0, y: 0}
      { x: rWidth / 2, y: - rWidth / 4 }
      { x: rWidth / 2, y: 0 }
      { x: rWidth / 4, y: rWidth / 3 } ]

  graphemes.classes.p = class P extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: - 3 * lWidth / 12, y: rWidth / 2 },
      { x: - lWidth / 3, y: 11 * rWidth / 12 },
      { x: - lWidth / 4, y: rWidth } ]

  graphemes.classes.r = class R extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: rWidth / 6, y: lWidth / 6 },
      { x: rWidth / 2, y: lWidth / 6 },
      { x: rWidth, y: 0 } ]

  graphemes.classes.u = class U extends CubicBezier
    _p: [
      { x: 0, y: 0 }
      { x: 0, y: rWidth / 2 }
      { x: rWidth / 3, y: rWidth / 2 }
      { x: rWidth / 3, y: 0 } ]

  graphemes.classes.v = class V extends CubicBezier
    _p: [
      { x: 0, y: 0 },
      { x: lWidth / 12, y: lWidth / 12 },
      { x: lWidth / 10, y: lWidth / 2 },
      { x: - 3 * lWidth / 8, y: lWidth } ]

  graphemes.classes.y = class Y extends CubicBezier
    _p: [
      { x: 0, y: 0 }
      { x: lWidth / 10, y: 0 }
      { x: lWidth / 8, y: 0 }
      { x: lWidth / 6, y: lWidth } ]

  return graphemes
