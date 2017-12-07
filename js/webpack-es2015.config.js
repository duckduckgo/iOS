
module.exports = {
  entry: './build/abp-filter-parser.js',
  output: {
    filename: 'abp-filter-parser-packed.js',
    path: __dirname + '/build',
    library: "ABPFilterParser"
  },
  node: {
    fs: 'empty'
  }
};

