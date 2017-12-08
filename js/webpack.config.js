
module.exports = {
  entry: '../../abp-filter-parser/src/abp-filter-parser.js',
  output: {
    filename: 'abp-filter-parser-packed.js',
    path: __dirname + '/../Core/',
    library: "ABPFilterParser"
  },
  node: {
    fs: 'empty'
  }
};

