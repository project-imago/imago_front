const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const SvgSpriteHtmlWebpackPlugin = require('svg-sprite-html-webpack');
// const SpriteLoaderPlugin = require('svg-sprite-loader/plugin');
// const CopyPlugin = require('copy-webpack-plugin');
// const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const BsFluentPlugin = require ('bs-fluent/plugin')

module.exports = {
    entry: {
        main: [
            "./lib/es6/src/main.bs.js",
            "./styles/main.scss"
        ]
    },
    output: {
        // publicPath: '/dist/',
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
        new BsFluentPlugin({
            includeFiles: ['locales/*.ftl'],
            destFile: 'src/t.ml',
            defaultLocale: 'en'
        })
    ],
    module: {
        rules: [
            {
                test:/\.(s*)css$/,
                use:['style-loader', 'css-loader', 'sass-loader']
            }
            // {
            //     test: /\.svg$/,
            //     use: SvgSpriteHtmlWebpackPlugin.getLoader()
            // }
        ]
    },
    devtool: "eval-source-map",
}
