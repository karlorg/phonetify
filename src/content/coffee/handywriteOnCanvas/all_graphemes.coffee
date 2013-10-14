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

define ['./graphemes/quadratic_beziers', './graphemes/cubic_beziers', './graphemes/circles', './graphemes/lines', './graphemes/misc'], (quads, cubics, circles, lines, misc) ->
  'use strict'

  graphemes = {}
  graphemes.classes = {}

  mergeInto = (existing, other) ->
    for own key, value of other
      existing[key] = value
    return

  mergeInto(graphemes.classes, other.classes) for other in [
    quads, cubics, circles, lines, misc]

  return graphemes
