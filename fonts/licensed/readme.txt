This folder contains empty placeholder fonts which are replaced with licensed versions by Jenkins during a release.

Developers: you may replace the placeholder font files with their licensed counterparts locally however you must not commit these to source control. You can run `git update-index --assume-unchanged *.otf` to stop git tracking changes you make to these files.

The build will now fail if you do not have the fonts in a standard location, which is:

~/DuckDuckGo/Fonts/proximanova

You can copy the fonts from this project in to that folder in order to build and run locally.
