###
phonetify - Firefox extension to replace text with phonetic spelling

Written in 2013 by Karl Naylor <kpn103@yahoo.com>

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software. If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
###

window.itiskarl ?= {}
window.itiskarl.phonetify ?= {}
phonetify = window.itiskarl.phonetify

handywriteOnCanvas = null

# setup require.js and use it to load handywriteOnCanvas

load = ->

  scriptLoadService = Components
  .classes["@mozilla.org/moz/jssubscript-loader;1"]
  .getService(Components.interfaces.mozIJSSubScriptLoader)
  scriptLoadService.loadSubScript 'chrome://phonetify/content/js/require.js'

  # we need to override the default (browser) implementation of `require.load`
  # to work in the Firefox extension environment
  window.require.load = (context, moduleName, url) ->
    try
      scriptLoadService.loadSubScript url
      context.completeLoad moduleName
    catch originalError
      error = new Error(
        "failed to import #{url} using subscript loader" +
        " at #{originalError.fileName}:#{originalError.lineNumber}: " +
        originalError.message)
      alert error.message
      error.requireModules = [moduleName]
      error.originalError = originalError
      context.onError error
    return

  require.config baseUrl: 'chrome://phonetify/content/generated-js'
  window.removeEventListener('load', load, false)
  require ['phonetify']
  return

window.addEventListener('load', load, false)
