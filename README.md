A Firefox extension to replace text on loaded pages with phonetic
spellings.  Currently only produces
([Handywrite](http://www.alysion.org/handy/handywrite.htm) output, and
does so in a very primitive and buggy fashion.  Don't expect much from
this archive, it's mostly here for my own personal use at this point...

You have to compile the Coffeescript portion to JS manually at the
moment.  The result goes in `src/content/generated-js` next to
the `src/content/coffee` directory.

## If you're working on the rendering component

Please don't change `src/content/coffee/handywriteOnCanvas` in
situ.  It has its own Github repository 'handywriteOnCanvas' with a
demo page and testing framework; make changes there and copy the
results to this project when you're happy with them.  I'm not really
happy with this arrangement, maybe you have a better idea?

## Why require.js?

Since this is a Firefox extension, why do I bother hacking require.js
to invoke `scriptLoadService` instead of just using
`scriptLoadService` directly?  It's mostly because I developed the
Handywrite rendering component as a reusable module using require.js
(it has its own Github repository, the code in this repo is just
copied from there).  Once the dirty work of getting require.js working
in this environment is done, it's kinda nice to have it around anyway.
