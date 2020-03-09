const HtmlWebpackPlugin = require('html-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

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
            template: './src/index.ejs'
        }),
        new MiniCssExtractPlugin()
    ],
    module: {
        rules: [
            {
                test:/\.(s*)css$/,
                use:[MiniCssExtractPlugin.loader, 'css-loader']
            }
        ]
    },
    devtool: "source-map",
    devServer: {
        //allowedHosts: ['imago-dev.img', 'localhost'],
        contentBase: './dist',
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
