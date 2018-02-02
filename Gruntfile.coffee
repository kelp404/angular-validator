module.exports = (grunt) ->
    require('time-grunt') grunt
    
    grunt.config.init
        coffee:
            source:
                files:
                    'dist/angular-validator.js': ['src/*.coffee']
            rules:
                files:
                    'dist/angular-validator-rules.js': ['rules/*.coffee']
            demo:
                files:
                    'example/demo.js': 'example/demo.coffee'
                    
        uglify:
            build:
                files:
                    'dist/angular-validator.min.js': 'dist/angular-validator.js'
                    'dist/angular-validator-rules.min.js': 'dist/angular-validator-rules.js'

        watch:
            coffee:
                files: ['src/*.coffee', 'rules/*.coffee', 'example/*.coffee']
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
            angular:
                configFile: 'test/karma.config.coffee'

    # -----------------------------------
    # register task
    # -----------------------------------
    grunt.registerTask 'dev', [
        'coffee'
        'connect'
        'watch'
    ]
    grunt.registerTask 'build', [
        'coffee'
        'uglify'
    ]
    grunt.registerTask 'test', ['karma']

    # -----------------------------------
    # Plugins
    # -----------------------------------
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-karma'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
