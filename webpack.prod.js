const webpack = require('webpack');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
    mode: 'production',
    output: {
	publicPath: '/'
    },
    plugins: [
        new webpack.EnvironmentPlugin({
            NODE_ENV: 'production',
            MATRIX_URL: 'https://matrix.alpha.imago.pm',
            API_URL: 'https://alpha.imago.pm'
        })
    ]
});
