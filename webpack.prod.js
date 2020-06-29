const webpack = require('webpack');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');
const ClosurePlugin = require('closure-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');

module.exports = merge(common, {
    mode: 'production',
    output: {
	publicPath: '/'
    },
    devtool: 'source-map',
    optimization: {
	// minimizer: [
	//     new ClosurePlugin({mode: 'STANDARD', childCompilations: true}, {
	//     })
	// ],
	splitChunks: { chunks: "all" }
    },
    plugins: [
        new webpack.EnvironmentPlugin({
            NODE_ENV: 'production',
            MATRIX_URL: 'https://matrix.alpha.imago.pm',
            API_URL: 'https://alpha.imago.pm'
        }),
	new CompressionPlugin()
    ]
});
