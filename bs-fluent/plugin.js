// module.exports = require('./src/plugin.bs.js');
const glob = require('glob');
const plugin = require('./src/plugin.bs.js')

module.exports = class BsFluentPlugin {
  constructor(options = {}) {
    this.fileList = []
    this.destFile = options.destFile
    if (options.includeFiles) {
      this.importFiles(options.includeFiles);
    }
  }

  importFiles(includePaths) {
    const filesToInclude = includePaths
      .reduce((acc, includePath) => {
        const matchPaths = glob.sync(includePath);
        if (matchPaths.length === 0) {
          console.warn(`WARNING : No file match with regex path "${includePath}"`);
        }
        return acc.concat(matchPaths);
      }, [])

    filesToInclude.forEach(filePath => {
      this.handleFile(filePath);
    });
  }

  handleFile(filePath) {
    const maybePath = this.fileList.find(item => item === filePath);
    const isAlreadyLoaded = !!maybePath;

    if (!isAlreadyLoaded) {
      this.pushPath(filePath);
    }

    // return `export default '#${symbolId}'`;
  }

  pushPath(filePath) {
    this.fileList = [...this.fileList, filePath];
  }

  apply(compiler) {
    plugin.process_files(this.fileList, this.destFile)
  }
}
