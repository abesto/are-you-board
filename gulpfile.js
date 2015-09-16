var gulp = require('gulp');
var ts = require('gulp-typescript');
var tslint = require('gulp-tslint');
var merge = require('merge2');
var changed = require('gulp-changed');
var rsync = require('gulp-rsync');
var clean = require('gulp-clean');


gulp.task('client:compileTypeScript', function () {
    const outDir = 'client/build/js';
    return gulp.src(['client/src/ts/**/*.ts', '!**/*.d.ts'])
        .pipe(changed(outDir, {extension: '.js'}))
        .pipe(tslint())
        .pipe(ts({module: "amd"}))
        .pipe(gulp.dest(outDir));
});

gulp.task('client:copyStaticResources', function () {
    return gulp.src('client/src/static')
        .pipe(rsync({
            root: 'client/src/static',
            destination: 'client/build',
            recursive: true,
            clean: true,
            exclude: ['lib', 'js'],
            silent: true,
            update: true
        }));
});

gulp.task('client:copyLibs', function () {
    return gulp.src('client/lib/bower_components')
        .pipe(rsync({
            root: 'client/lib/bower_components',
            destination: 'client/build/lib',
            recursive: true,
            clean: true,
            silent: true,
            update: true
        }));
});

gulp.task('client', ['client:compileTypeScript', 'client:copyStaticResources', 'client:copyLibs']);
gulp.task('client:clean',  function () {
    return gulp.src('client/build', {read: false}).pipe(clean());
});

gulp.task('server:compileTypeScript', function () {
    const outDir = 'server/build';
    return gulp.src(['server/src/ts/**/*.ts', '!**/*.d.ts'])
        .pipe(changed(outDir, {extension: '.js'}))
        .pipe(tslint())
        .pipe(ts({module: 'commonjs'}))
        .pipe(gulp.dest(outDir));
});

gulp.task('server:copyPackageJson', function () {
    const outDir = 'server/build';
    return gulp.src('server/src/package.json')
        .pipe(changed(outDir))
        .pipe(gulp.dest(outDir));
});

gulp.task('server:copyTemplates', function () {
    return gulp.src('server/src/views/**/*')
        .pipe(gulp.dest('server/build/views'));
});

gulp.task('server:copySwagger', function () {
    return merge([
        gulp.src('server/src/swagger/api/swagger/swagger.yaml').pipe(gulp.dest('server/build/api/swagger')),
        gulp.src('server/src/swagger/config/default.yaml').pipe(gulp.dest('server/build/api/config'))
    ]);
});

gulp.task('server', ['server:compileTypeScript', 'server:copyPackageJson', 'server:copySwagger', 'server:copyTemplates']);
gulp.task('server:clean',  function () {
    return gulp.src('server/build', {read: false}).pipe(clean());
});

gulp.task('default', ['server', 'client']);
gulp.task('clean', ['server:clean', 'client:clean']);

gulp.task('watch', ['default'], function () {
    gulp.watch(['client/src/ts/**/*.ts', '!**/*.d.ts'], ['client:compileTypeScript']);
    gulp.watch(['server/src/ts/**/*.ts', '!**/*.d.ts'], ['server:compileTypeScript']);
    gulp.watch(['shared/**/*.ts', '!**/*.d.ts'], ['client:compileTypeScript', 'server:compileTypeScript']);
    gulp.watch(['client/src/static/**/*.html', 'client/src/static/**/*.css', 'client/src/static/**/*.js', 'client/src/static/**/*.map'], ['client:copyStaticResources']);
    gulp.watch(['client/lib/bower_components/**/*.js', 'client/lib/bower_components/**/*.map', 'client/lib/bower_components/**/*.css'], ['client:copyLibs']);
    gulp.watch(['server/src/swagger/api/swagger/swagger.yaml', 'server/src/swagger/config/default.yaml'], ['server:copySwagger']);
    gulp.watch(['server/src/views/**'], ['server:copyTemplates']);
});
