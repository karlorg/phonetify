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

  geometry = {}

  TAU = Math.PI * 2  # TAU is one full turn in radians

  # do not modify existing Vectors or their constituent points, kk?
  geometry.Vector = class Vector
    constructor: (@p0, @p1) ->

    normalized: ->
      len = Math.sqrt(
          (@p1.x - @p0.x) * (@p1.x - @p0.x)
        + (@p1.y - @p0.y) * (@p1.y - @p0.y))
      scale = 1 / len
      return new Vector(
        @p0,
        { x: ((@p1.x - @p0.x) * scale) + @p0.x
          y: ((@p1.y - @p0.y) * scale) + @p0.y })

    angle: ->
      # since 'true' arctangent is multivalued and `Math.atan` is limited
      # to +/- TAU/4, we need to rotate the result by TAU/2 if p1 is to
      # the left of p0
      return Math.atan( (@p1.y - @p0.y) / (@p1.x - @p0.x) ) +
        if @p1.x < @p0.x then TAU / 2 else 0

  geometry.rotatePoint = (p, theta) ->
    {x, y} = p
    cosTheta = Math.cos theta
    sinTheta = Math.sin theta
    return {
      x: x * cosTheta - y * sinTheta
      y: y * cosTheta + x * sinTheta
      }

  geometry.vectorFromAngle = (angle) ->
    { x, y } = geometry.rotatePoint({x:1, y:0}, angle)
    return new Vector({ x: 0, y: 0 }, { x: x, y: y })

  geometry.pointSum = (points) ->
    return {
        x: (p.x for p in points).reduce( (a,b) -> a+b )
        y: (p.y for p in points).reduce( (a,b) -> a+b )
      }

  return geometry
  