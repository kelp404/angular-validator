module.exports = (grunt) ->
    # -----------------------------------
    # Options
    # -----------------------------------
    grunt.config.init
        compass:
            dev:
                options:
                    sassDir: './example'
                    cssDir: './example'
                    outputStyle: 'compressed'

        coffee:
            source:
                files:
                    './dist/angular-validator.js': ['./src/*.coffee']
            rules:
                files:
                    './dist/angular-validator-rules.js': ['./rules/*.coffee']
            demo:
                files:
                    './example/demo.js': './example/demo.coffee'

        watch:
            compass:
                files: ['./example/*.scss']
                tasks: ['compass']
                options:
                    spawn: no
            coffee:
                files: ['./src/*.coffee', './rules/*.coffee', './example/*.coffee']
                tasks: ['coffee']
                options:
                    spawn: no

        connect:
            server:
                options:
                    protocol: 'http'
                    hostname: '*'
                    port: 8000
                    base: '.'

        karma:
            ng1_2:
                configFile: './test/karma-ng1.2.config.coffee'
            ng1_2_min:
                configFile: './test/karma-ng1.2.min.config.coffee'

    # -----------------------------------
    # register task
    # -----------------------------------
    grunt.registerTask 'dev', ['connect', 'watch']
    grunt.registerTask 'test', ['karma']

    # -----------------------------------
    # Plugins
    # -----------------------------------
    grunt.loadNpmTasks 'grunt-contrib-compass'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-karma'