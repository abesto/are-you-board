var gulp = require('gulp');
var ts = require('gulp-typescript');
var tslint = require('gulp-tslint');
var merge = require('merge2');

gulp.task('compileClientTs', function () {
    return gulp.src('client/src/ts/**/*.ts')
        .pipe(tslint())
        .pipe(tslint.report('verbose'))
        .pipe(ts({out: 'app.js'}))
        .pipe(gulp.dest('client/build/js/'));
});

gulp.task('copyClientResources', function () {
    return gulp.src([
            'client/src/**/*.html',
            'client/src/**/*.css',
            'client/src/**/*.js',
            'client/src/**/*.map'
    ]).pipe(gulp.dest('client/build/'));
});

gulp.task('copyClientLibs', function () {
    return gulp.src([
        'client/lib/bower_components/**/*.js',
        'client/lib/bower_components/**/*.map',
        'client/lib/bower_components/**/*.css'
    ]).pipe(gulp.dest('client/build/lib'));
});

gulp.task('buildClient', ['compileClientTs', 'copyClientResources', 'copyClientLibs']);

gulp.task('compileServerTs', function () {
    return gulp.src('server/src/ts/**/*.ts')
        .pipe(tslint())
        .pipe(tslint.report('verbose'))
        .pipe(ts({out: 'app.js'}))
        .pipe(gulp.dest('server/build/'));
});

gulp.task('copyServerPackageJson', function () {
    return gulp.src('server/src/package.json')
        .pipe(gulp.dest('server/build/'));
});

gulp.task('buildServer', ['compileServerTs', 'copyServerPackageJson']);

gulp.task('default', ['buildClient', 'buildServer'], function() {
});
