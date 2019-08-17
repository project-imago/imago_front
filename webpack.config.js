module.exports = {
    mode: "development",
    entry: "./lib/es6/src/main.bs.js",
    output: {
        path: __dirname+'/dist',
        filename: "[name].js"
    },
    devtool: "source-map",
    devServer: {
        contentBase: __dirname,
        https: true
    }
}
