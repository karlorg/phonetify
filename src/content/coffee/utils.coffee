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

define ->

  utils = {}

  # stolen from http://forums.mozillazine.org/viewtopic.php?p=921150
  utils.readFileFromUri = (uri) ->
    ioService = window.Components.classes['@mozilla.org/network/io-service;1']
      .getService(window.Components.interfaces.nsIIOService)
    scriptableStream =
      window.Components.classes['@mozilla.org/scriptableinputstream;1']
      .getService(window.Components.interfaces.nsIScriptableInputStream)
    channel = ioService.newChannel(uri, null, null)
    input = channel.open()
    try
      scriptableStream.init(input)
      try
        str = scriptableStream.read(input.available())
      finally
        scriptableStream.close()
    finally
      input.close()
    return str

  return utils
