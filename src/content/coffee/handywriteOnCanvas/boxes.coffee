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

define ->
  'use strict'

  boxes = {}

  boxes.BoundingBox = class BoundingBox
    constructor: (@_left, @_top, @_right, @_bottom, @_transformed=false) ->
      # @transformed should be false if this bounding box is in the default
      # grapheme co-ordinate system, true otherwise
    
    left: -> @_left
    top: -> @_top
    right: -> @_right
    bottom: -> @_bottom

    scale: (sx, sy) -> new BoundingBox(
      @_left * sx, @_top * sy,
      @_right * sx, @_bottom * sy,
      true)

    translate: (dx, dy) -> new BoundingBox(
      @_left + dx, @_top + dy,
      @_right + dx, @_bottom + dy,
      true)

  boxes.boxFromPoints = (pointList) ->
    unless pointList.length then return new BoundingBox(0, 0, 0, 0)
    left = Math.min((point.x for point in pointList)...)
    top = Math.min((point.y for point in pointList)...)
    right = Math.max((point.x for point in pointList)...)
    bottom = Math.max((point.y for point in pointList)...)
    return new BoundingBox(left, top, right, bottom)

  boxes.combineBoundingBoxes = (boxList) ->
    unless boxList.length then return new BoundingBox(0, 0, 0, 0)
    left = Math.min((box.left() for box in boxList)...)
    top = Math.min((box.top() for box in boxList)...)
    right = Math.max((box.right() for box in boxList)...)
    bottom = Math.max((box.bottom() for box in boxList)...)
    return new BoundingBox(left, top, right, bottom, boxList[0]._transformed)
  
  return boxes
  