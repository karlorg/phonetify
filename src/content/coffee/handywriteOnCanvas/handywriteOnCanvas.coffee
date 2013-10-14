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

define ['./all_graphemes', './boxes'], (allGraphemes, boxes) ->
  'use strict'

  hoc = {}

  hoc.DocumentRenderer = class DocumentRenderer
    constructor: (@doc) ->

    # the length of an 'l' curve in pixels
    elLength: 30

    setElLength: (@elLength) ->

    createCanvas: (phonemes, titleText=null) ->
      cRenderer = new CanvasRenderer(this, phonemes, titleText)
      return cRenderer.canvas

  class CanvasRenderer
    constructor: (@docRenderer, @phonemes, titleText=null) ->
      doc = @docRenderer.doc
      @canvas = doc.createElement('canvas')
      if titleText then @canvas.setAttribute('title', titleText)
      @ctx = @canvas.getContext('2d')
      @render()

    render: ->
      graphemes = []
      last = null
      for phoneme in @phonemes
        if allGraphemes.classes[phoneme]?
          newGrapheme = new allGraphemes.classes[phoneme]
          last.setRightNeighbour(newGrapheme) if last
          newGrapheme.setLeftNeighbour(last) if last
          graphemes.push(newGrapheme)
          last = newGrapheme
      for grapheme in graphemes
        grapheme.decide()
      bbox = boundsOfGraphemes(graphemes)
      @canvas.width = (bbox.right() - bbox.left()) * @docRenderer.elLength + 10
      @canvas.height = (bbox.bottom() - bbox.top()) * @docRenderer.elLength + 10
      @ctx.save()
      @ctx.scale(@docRenderer.elLength, @docRenderer.elLength)
      # scale down the line width manually, otherwise it will be scaled
      # along with the rest of the context
      @ctx.lineWidth /= @docRenderer.elLength
      @ctx.translate(
        - bbox.left() + @ctx.lineWidth, - bbox.top() + @ctx.lineWidth)
      for grapheme in graphemes
        grapheme.render(@ctx)
        endPoint = grapheme.getFinishPoint()
        @ctx.translate(endPoint.x, endPoint.y)
      @ctx.restore()

  # returns the overall bounding box of the given graphemes (which should
  # already have been `decide`d). Origin is the starting point of the first
  # grapheme, and 1 unit is the width of an l-curve.
  boundsOfGraphemes = (graphemes) ->
    boundingBoxes = []
    x = y = 0
    for g in graphemes
      boundingBoxes.push(g.getBoundingBox().translate(x, y))
      { x: dx, y: dy } = g.getFinishPoint()
      x += dx
      y += dy
    return boxes.combineBoundingBoxes(boundingBoxes)

  return hoc
