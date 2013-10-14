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

  sWidth = zWidth = sHeight = zHeight = 0.15
  hWidth = hHeight = 0.4
  lWidth = 1

  graphemes.classes.h = class H extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, 0, hWidth, hHeight)
    getFinishPoint: -> { x: hWidth, y: hHeight }
    getEntryAngle: -> 0
    getExitAngle: -> TAU / 4
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        hWidth, 0,
        hWidth, hHeight)
      ctx.stroke()
      return

  graphemes.classes.s = class S extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, 0, - sWidth, sHeight)
    getFinishPoint: -> { x: - sWidth, y: sHeight }
    getEntryAngle: -> TAU / 4
    getExitAngle: -> TAU / 2
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        0, sHeight,
        - sWidth, sHeight)
      ctx.stroke()
      return

  graphemes.classes.th = class VoicedTH extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, - hHeight, hWidth, 0)
    getFinishPoint: -> { x: hWidth, y: - hHeight }
    getEntryAngle: -> 0
    getExitAngle: -> 3 * TAU / 4
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        hWidth, 0,
        hWidth, - hHeight)
      ctx.stroke()
      return

  graphemes.classes.Th = class UnvoicedTH extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, - hHeight, hWidth, 0)
    getFinishPoint: -> { x: hWidth, y: - hHeight }
    getEntryAngle: -> 3 * TAU / 4
    getExitAngle: -> 0
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        0, - hHeight,
        hWidth, - hHeight)
      ctx.stroke()
      return

  graphemes.classes.w = class W extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, 0, hWidth, hHeight)
    getFinishPoint: -> { x: hWidth, y: hHeight }
    getEntryAngle: -> TAU / 4
    getExitAngle: -> 0
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        0, hHeight,
        hWidth, hHeight)
      ctx.stroke()
      return

  graphemes.classes.z = class Z extends Grapheme
    getBoundingBox: -> new boxes.BoundingBox(0, 0, sWidth, sHeight)
    getFinishPoint: -> { x: sWidth, y: sHeight }
    getEntryAngle: -> TAU / 4
    getExitAngle: -> 0
    render: (ctx) ->
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.quadraticCurveTo(
        0, sHeight,
        sWidth, sHeight)
      ctx.stroke()
      return

  return graphemes
  