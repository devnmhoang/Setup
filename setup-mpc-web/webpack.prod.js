const HtmlWebpackPlugin = require('html-webpack-plugin');
const { EnvironmentPlugin } = require('webpack');

module.exports = {
  mode: 'production',
  devtool: 'source-map',
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true,
            },
          },
        ],
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js'],
  },
  node: {
    fs: 'empty',
    child_process: 'empty',
    readline: 'empty',
  },
  plugins: [
    new HtmlWebpackPlugin({ template: './src/index.html' }),
    new EnvironmentPlugin({ API_URL: 'https://setup-staging.aztecprotocol.com/api' }),
  ],
};