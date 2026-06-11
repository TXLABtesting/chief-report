'use strict';

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

// API origin used during local dev (the Express server). The dev server
// proxies /api and /docs to it so the client can use same-origin paths.
const API_TARGET = process.env.API_TARGET || 'http://localhost:3001';

module.exports = (_env, argv) => {
  const isProd = argv.mode === 'production';
  return {
    entry: './src/index.js',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProd ? 'assets/[name].[contenthash:8].js' : 'assets/[name].js',
      publicPath: '/',
      clean: true,
    },
    module: {
      rules: [
        { test: /\.jsx?$/, exclude: /node_modules/, use: 'babel-loader' },
        { test: /\.css$/, use: ['style-loader', 'css-loader'] },
      ],
    },
    resolve: { extensions: ['.js', '.jsx'] },
    plugins: [
      new HtmlWebpackPlugin({ template: './public/index.html' }),
      // Copy static assets (icons, manifest, favicon) into the build; the
      // HTML template is handled by HtmlWebpackPlugin above.
      new CopyWebpackPlugin({
        patterns: [
          { from: 'public', to: '.', globOptions: { ignore: ['**/index.html'] } },
        ],
      }),
    ],
    devServer: {
      port: 3000,
      historyApiFallback: true,
      proxy: [
        { context: ['/api', '/docs'], target: API_TARGET },
      ],
    },
    devtool: isProd ? 'source-map' : 'eval-source-map',
  };
};
