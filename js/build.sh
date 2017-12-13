
webpackcmd=./node_modules/webpack/bin/webpack.js

rm -rf build/
mkdir build/

npm update

# this builds a small version of abp-filter-parser.js directly in to Core
$webpackcmd --config webpack.config.js


# all the following builds an es2015 compatible version 

echo "require('babel-polyfill');" > build/abp-filter-parser.js
cat ../../abp-filter-parser/src/abp-filter-parser.js >> build/abp-filter-parser.js
cp ../../abp-filter-parser/src/badFingerprints.js build/


ls -l build/abp-filter-parser.js

$webpackcmd --config webpack-es2015.config.js
cat build/abp-filter-parser-packed.js | babel --presets es2015 > ../Core/abp-filter-parser-packed-es2015.js

