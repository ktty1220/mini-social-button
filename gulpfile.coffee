gulp = require 'gulp'
pkg = require('gulp-packages') gulp, [
  'task-listing'
  'coffee'
  'shell'
]

gulp.task 'help', () -> pkg.taskListing()

gulp.task 'coffee', ->
  gulp.src 'src/*.coffee'
  .pipe pkg.coffee()
  .pipe gulp.dest 'app/lib'

gulp.task 'run', [ 'coffee' ], pkg.shell.task [ 'cd app && cfx run' ]
gulp.task 'xpi', [ 'coffee' ], pkg.shell.task [ 'cd app && cfx xpi' ]
gulp.task 'update', [ 'xpi' ], pkg.shell.task [
  'wget --post-file=app/mini-social-button.xpi http://127.0.0.1:8888/'
], ignoreErrors: true

gulp.task 'watch', ->
  gulp.watch [ 'src/**/*', 'app/package.json' ], [ 'update' ]

gulp.task 'default', [ 'help' ]
