module.exports = {
  publicPath: process.env.VUE_APP_PRODUCTION === 'true' ? '/program-pmi/' : '/',
  pluginOptions: {
    quasar: {
      importStrategy: 'kebab',
      rtlSupport: false
    }
  },
  transpileDependencies: [
    'quasar'
  ]
}
