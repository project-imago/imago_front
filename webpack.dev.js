// const webpack = require('webpack');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
    mode: 			'development',
    output: {
	publicPath: '/dist'
    },
    devtool: 			'inline-source-map',
    devServer: {
        contentBase: 		'./dist',
        disableHostCheck: 	true,
        host: 			'0.0.0.0',
        hot: 			true,
        liveReload: 		false,
        port: 			9000,
        publicPath: 		'/dist/',
        historyApiFallback: {
            disableDotRule: 	true
        },
        writeToDisk: 		true
        // allowedHosts: ['imago-dev.img', 'localhost'],
        // headers: {
        //     'Access-Control-Allow-Origin': '*',
        // },
        // http2: true,
        // https: true,
        // inline: true,
        // public: 'imago-dev.img',
        // sockHost: 'imago-dev.img',
        // useLocalIp: false,
    },
    plugins: [
    ]
});
