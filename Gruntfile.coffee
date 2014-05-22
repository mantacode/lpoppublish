module.exports = (g) ->
  g.initConfig
    spec:
      unit:
        options:
          specs: 'spec/**/*.{js,coffee}'
      e2e:
        options:
          specs: 'spec-e2e/**/*.{js,coffee}'

  g.loadNpmTasks 'grunt-jasmine-bundle'
  g.registerTask 'default', ['spec:unit', 'spec:e2e']
