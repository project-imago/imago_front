const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const SvgSpriteHtmlWebpackPlugin = require('svg-sprite-html-webpack');
// const SpriteLoaderPlugin = require('svg-sprite-loader/plugin');
// const CopyPlugin = require('copy-webpack-plugin');
// const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    mode: "development",
    entry: {
        main: [
            "./lib/es6/src/main.bs.js",
            "./styles/main.scss"
        ]
    },
    output: {
        publicPath: '/dist/',
        path: __dirname+'/dist',
        filename: "[name].js"
    },
    plugins: [
        new CleanWebpackPlugin(),
        new HtmlWebpackPlugin({
            filename: './index.html',
            template: './src/index.ejs',
            title: 'Imago'
        }),
        new SvgSpriteHtmlWebpackPlugin({
            includeFiles: ['node_modules/bytesize-icons/dist/icons/*.svg']
            // generateSymbolId: function(svgFilePath, svgHash, svgContent) {
            //     return svgContent.id;
            // }
        }),
        // new SpriteLoaderPlugin()
        // new CopyPlugin({
        //     patterns: [{from: 'bytesize-symbols.svg', context: 'node_modules/bytesize-icons/dist'}]
        // })
        // new MiniCssExtractPlugin()
        new webpack.EnvironmentPlugin({
            NODE_ENV: 'development',
            MATRIX_URL: 'http://matrix.imago.local:8008',
            API_URL: 'http://api.imago.local:4000'
        })
    ],
    module: {
        rules: [
            {
                test:/\.(s*)css$/,
                use:['style-loader', 'css-loader', 'sass-loader']
            },
            {
                test: /\.svg$/,
                use: SvgSpriteHtmlWebpackPlugin.getLoader()
            }
        ]
    },
    devtool: "eval-source-map",
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
}
