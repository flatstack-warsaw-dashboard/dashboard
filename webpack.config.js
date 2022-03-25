import { URL } from 'node:url';
import HtmlWebpackPlugin from 'html-webpack-plugin';

const NODE_ENV = process.env.NODE_ENV || 'development';

export default {
  context: new URL('./src', import.meta.url).pathname,
  entry: {},
  mode: NODE_ENV,
  output: {
    filename: '[name].[contenthash].js',
    path: new URL('./dist', import.meta.url).pathname,
    clean: true,
    publicPath: 'auto',
  },
  module: {
    rules: [
      {
        test: /\.[jt]sx?$/,
        use: 'babel-loader',
        exclude: /\/node_modules\//,
      },
    ],
  },
  devServer: {},
  plugins: [
    new HtmlWebpackPlugin({
      template: 'index.html',
    }),
  ],
};
