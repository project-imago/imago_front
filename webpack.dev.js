const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',
    devServer: {
        //allowedHosts: ['imago-dev.img', 'localhost'],
        contentBase: './dist',
        disableHostCheck: true,
        //headers: {
        //    'Access-Control-Allow-Origin': '*',
        //},
        host: '0.0.0.0',
        hot: true,
        //http2: true,
        //https: true,
        //inline: true,
        liveReload: false,
        port: 9000,
        //public: 'imago-dev.img',
        publicPath: '/dist/',
        historyApiFallback: {
            disableDotRule: true
        },
        //sockHost: 'imago-dev.img',
        //useLocalIp: false,
        writeToDisk: true
    }
});
