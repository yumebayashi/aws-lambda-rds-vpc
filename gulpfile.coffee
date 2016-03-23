gulp        = require "gulp"
zip         = require "gulp-zip"
coffee      = require "gulp-coffee"
gutil       = require "gulp-util"
lambduhGulp = require "lambduh-gulp"

lambduhGulp gulp

gulp.task "js", ->
  gulp.src("src/*.coffee")
    .pipe(coffee({bare: true})).on("error", gutil.log)
    .pipe(gulp.dest("dist"))


gulp.task "zip", ->
  gulp.src(['dist/**/*', '!dist/package.json', '!dist/test.js'])
    .pipe(zip('dist.zip'))
    .pipe(gulp.dest('./'))
