import { URL } from 'node:url';
import { readFile } from 'node:fs/promises';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';

const NODE_ENV = process.env.NODE_ENV || 'development';

const packageJson = JSON.parse(
  await readFile(new URL('./package.json', import.meta.url), {
    encoding: 'utf8',
  }),
);

const deps = packageJson.dependencies;

export default {
  context: new URL('./src', import.meta.url).pathname,
  entry: { main: './index.ts' },
  mode: NODE_ENV,
  output: {
    filename: '[name].[contenthash].js',
    path: new URL('./dist', import.meta.url).pathname,
    clean: true,
    publicPath: 'auto',
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
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
    new webpack.container.ModuleFederationPlugin({
      name: 'dashboard',
      shared: {
        ...deps,
        react: {
          singleton: true,
          requiredVersion: deps.react,
        },
        'react/jsx-runtime': { singleton: true },
        'react-dom': {
          singleton: true,
          requiredVersion: deps['react-dom'],
        },
        'styled-components': {
          singleton: true,
          requiredVersion: deps['styled-component'],
        },
      },
    }),
  ],
};
