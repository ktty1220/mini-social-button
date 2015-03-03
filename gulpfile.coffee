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

gulp.task 'default', [ 'help' ]
