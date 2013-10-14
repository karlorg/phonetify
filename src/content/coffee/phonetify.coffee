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

define [
  'handywriteOnCanvas/handywriteOnCanvas',
  'utils'], (handywriteOnCanvas, utils) ->

  'use strict'

  arpabetRawFileUri = 'chrome://phonetify/content/pronunciations.txt'
  # the arpabet dictionary is loaded asynchronously since it could
  # take a while, so we initialise it empty and use a flag to signal
  # when it's ready.
  arpabetDictionary = {}
  arpabetDictReady = false

  init = ->
    button = window.document.getElementById 'phonetify-button'
    button?.addEventListener 'command', onToolbarButton, false
    window.setTimeout loadDictionary, 0
    return true

  onToolbarButton = ->
    if arpabetDictReady
      phonetifyDocument gBrowser.selectedBrowser.contentDocument.documentElement
      return true
    else
      # try again in half a second
      window.setTimeout onToolbarButton, 500
      return false

  loadDictionary = ->
    raw = utils.readFileFromUri arpabetRawFileUri
    lineRe = /// ^
      ([\w\']+) # term
      \s+
      (.*)      # definition
      $ ///
    for line in raw.match /^.*$/gm
      lineMatch = line.match lineRe
      continue unless lineMatch
      [term, definition] = lineMatch[1..]
      arpabetDictionary[term] = definition.match /\b\w\w?\d?\b/g
    arpabetDictReady = true
    return true

  handywriteFromArpabet = {
    # monophthongs
    AO0: ['aw'], AO1: ['aw'], AO2: ['aw']
    AA0: ['a'], AA1: ['a'], AA2: ['a']
    IY0: ['i'], IY1: ['i'], IY2: ['i']
    UW0: ['u'], UW1: ['u'], UW2: ['u']
    EH0: ['eh'], EH1: ['eh'], EH2: ['eh']
    IH0: ['ih'], IH1: ['ih'], IH2: ['ih']
    UH0: ['uh'], UH1: ['c'], UH2: ['c']
    AH0: ['uh'], AH1: ['a'], AH2: ['a']
    AX0: ['uh']
    AE0: ['ae'], AE1: ['ae'], AE2: ['ae']
    # diphthongs
    EY0: ['ey'], EY1: ['ey'], EY2: ['ey'], AY0: ['ay'], AY1: ['ay'], AY2: ['ay']
    OW0: ['o'], OW1: ['o'], OW2: ['o']
    AW0: ['a', 'u'], AW1: ['a', 'u'], AW2: ['a', 'u']
    OY0: ['o', 'ih'], OY1: ['o', 'ih'], OY2: ['o', 'ih']
    # r coloured vowels
    ER: ['r'], ER0: ['r'], ER1: ['r'], ER2: ['r']

    # stops
    P: ['p'], B: ['b'], T: ['t'], D: ['d'], K: ['k'], G: ['g']
    # affricates
    CH: ['ch'], JH: ['j']
    # fricatives
    F: ['f'], V: ['v'], TH: ['Th'], DH: ['th'],
    S: ['s'], Z: ['z'], SH: ['sh'], ZH: ['zh'], HH: ['h']
    # nasals
    M: ['m'], EM: ['m'], N: ['n'], EN: ['n'], NG: ['ng'], ENG: ['ng']
    # liquids
    L: ['l'], EL: ['l'], R: ['r'], DX: ['t'], NX: ['n', 't']
    # semivowels
    Y: ['y'], W: ['w']
    }

  phonemesFromWord = (word) ->
    upcaseWord = word.toUpperCase()
    return null unless upcaseWord of arpabetDictionary
    arpabetSpelling = arpabetDictionary[upcaseWord]
    result = []
    for arpaPhoneme in arpabetSpelling
      continue unless arpaPhoneme of handywriteFromArpabet
      result = result.concat handywriteFromArpabet[arpaPhoneme]
    return result

  # tags that we can recurse into and replace text with text
  allowedTags = [
    'a', 'address', 'article', 'aside', 'b', 'big', 'blockquote', 'body'
    'button', 'caption', 'center', 'cite', 'command', 'datagrid', 'datalist'
    'dd', 'del', 'dialog', 'div', 'dl', 'dt', 'em', 'fieldset', 'figure'
    'footer', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
    'head', 'header', 'html', 'i', 'iframe', 'input', 'ins', 'kbd', 'label'
    'legend', 'li', 'mark', 'menu', 'nav', 'noframes', 'noscript', 'ol'
    'optgroup', 'option', 'output', 'p', 'q', 's', 'section', 'select'
    'small', 'span', 'strike', 'strong', 'sub', 'sup', 'table', 'tbody'
    'td', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul'
    ]

  # tags that we can recurse into and replace text with arbitrary html
  embedFriendlyTags = [
    'a', 'article', 'aside', 'b', 'big', 'blockquote', 'body', 'button'
    'center', 'cite', 'command', 'dd', 'del', 'dialog', 'div', 'dl', 'dt'
    'em', 'fieldset', 'footer', 'form', 'frame', 'frameset', 'h1', 'h2'
    'h3', 'h4', 'h5', 'h6', 'header', 'html', 'i', 'iframe', 'ins', 'label'
    'legend', 'li', 'mark', 'menu', 'nav', 'noframes', 'noscript', 'ol'
    'p', 'q', 's', 'section', 'small', 'span', 'strike', 'strong', 'table'
    'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'u', 'ul'
    ]

  phonetifyDocument = (document) ->
    # as we traverse the DOM we'll build a list of replacements to perform
    # (we can't replace while looping without messing up the loop logic).
    # A replacement has the form:
    #
    # { old: <node to replace>,
    #   new: <array of nodes to insert> }
    domReplacements = []

    renderer = new handywriteOnCanvas.DocumentRenderer document.ownerDocument

    phonetifyTextNode = (node, canEmbedHtml) ->
      if canEmbedHtml
        newContent = []
        # capture any space before the first word as a text node
        if match = /^([^\w]+)/.exec node.textContent
          space = match[1]
          spaceTextNode = window.document.createTextNode space
          newContent.push spaceTextNode
        # then capture each word and its succeeding whitespace for the
        # remainder of the input node
        wordSpaceRe = /([\w\'\u2019\u02BC]+)([^\w\']*)/g
        while match = wordSpaceRe.exec node.textContent
          [word, space] = match[1..2]
          # replace non-ASCII apostrophes with ASCII
          word = word.replace /[\u2019\u02BC]/g, "'"
          phonemes = phonemesFromWord word
          if phonemes
            canvas = renderer.createCanvas(
              phonemes, "#{word} (#{arpabetDictionary[word.toUpperCase()].join '-'})")
            canvas.setAttribute 'style', 'vertical-align: middle'
            newContent.push canvas
            spaceTextNode = window.document.createTextNode space
            newContent.push spaceTextNode
          else
            newContent.push window.document.createTextNode word + space
        domReplacements.push(
          old: node
          new: newContent)
      else
        node.textContent = node.textContent.replace(/[\w\']+/g, phonetifyWord)
      return true

    phonetifyNodeRecursive = (node, canEmbedHtml) ->
      switch node.nodeType
        when Node.TEXT_NODE then phonetifyTextNode(node, canEmbedHtml)
        when Node.ELEMENT_NODE, Node.DOCUMENT_NODE
          name = node.nodeName.toLowerCase()
          if name in allowedTags
            canEmbedNext = canEmbedHtml and (name in embedFriendlyTags)
            for child in node.childNodes
              phonetifyNodeRecursive(child, canEmbedNext)
      return true

    phonetifyNodeRecursive(document, true)

    for replacement in domReplacements
      oldNode = replacement.old
      parent = oldNode.parentNode
      for newNode in replacement.new
        parent.insertBefore(newNode, oldNode)
      parent.removeChild(oldNode)

    return true

  phonetifyWord = (word) ->
    phonemes = phonemesFromWord word
    return if phonemes then phonemes.join('') else word

  init()
  return
