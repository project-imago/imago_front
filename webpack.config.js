module.exports = {
    mode: "development",
    entry: "./lib/es6/src/main.bs.js",
    output: {
        publicPath: __dirname+'/dist',
        path: __dirname+'/dist',
        filename: "[name].js"
    },
    devtool: "source-map",
    devServer: {
        //allowedHosts: ['imago-dev.img', 'localhost'],
        contentBase: __dirname,
        disableHostCheck: true,
        //headers: {
        //    'Access-Control-Allow-Origin': '*',
        //},
        host: '0.0.0.0',
        //hot: false,
        //http2: true,
        //https: true,
        //inline: true,
        //liveReload: true,
        port: 9000,
        //public: 'imago-dev.img',
        publicPath: '/dist/',
        //sockHost: 'imago-dev.img',
        //useLocalIp: false,
        writeToDisk: true
    }
}
