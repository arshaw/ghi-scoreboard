_ = require('lodash')
gulp = require('gulp')
gutil = require('gulp-util')
rename = require('gulp-rename')
sourcemaps = require('gulp-sourcemaps')
source = require('vinyl-source-stream')
buffer = require('vinyl-buffer')
browserify = require('browserify')
coffeeify = require('coffeeify')
watchify = require('watchify')


gulp.task('default', [ 'build' ])

gulp.task('build', [ 'buildScripts', 'copy' ])

gulp.task('watch', [ 'watchScripts' ])


# Static Files

gulp.task('copy', [ 'copyJs', 'copyCss', 'copyFonts', 'copyHtml' ])

gulp.task 'copyJs', ->
	gulp.src([
		'./node_modules/jquery/dist/jquery.js'
		'./node_modules/bootstrap/dist/js/bootstrap.js'
		])
		.pipe gulp.dest('./out/js/')

gulp.task 'copyCss', ->
	gulp.src([
		'./node_modules/bootstrap/dist/css/bootstrap.css'
		'./styles/dashboard.css'
		])
		.pipe gulp.dest('./out/css/')

gulp.task 'copyFonts', ->
	gulp.src('./node_modules/bootstrap/dist/fonts/*')
		.pipe gulp.dest('./out/fonts/')

gulp.task 'copyHtml', ->
	gulp.src('./templates/index.tpl')
		.pipe rename('index.html')
		.pipe gulp.dest('./out/')


# Scripts
# https://github.com/gulpjs/gulp/blob/master/docs/recipes/browserify-transforms.md
# https://github.com/gulpjs/gulp/blob/master/docs/recipes/fast-browserify-builds-with-watchify.md

gulp.task 'buildScripts', ->
	bundleScripts()

gulp.task 'watchScripts', ->
	bundleScripts(true)

bundleScripts = (isWatch=false) ->
	options = {
		entries: './scripts/ui.coffee'
		debug: true
		transform: [ coffeeify ] # FYI, browserify-shim and hbsfy are defined in package.json
		extensions: [ '.coffee' ]
	}

	bundle = ->
		bundler.bundle()
			.on('error', gutil.log.bind(gutil, 'Browserify Error'))
			.pipe source('dashboard.js')
			.pipe buffer()
			.pipe sourcemaps.init({ loadMaps: true })
			.pipe sourcemaps.write('./') # where to write sourcemaps, relative to output JS
			.pipe gulp.dest('./out/js/')

	if isWatch
		options = _.assign({}, watchify.args, options)
		bundler = watchify(browserify(options))
		bundler.on('update', bundle) # on any dep update, runs the bundler
	else
		bundler = browserify(options)

	bundler.on('log', gutil.log) # output build logs to terminal
	bundle()
