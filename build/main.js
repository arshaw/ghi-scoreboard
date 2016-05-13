// generates the JSON and HTML files based on the configs

var fs = require('fs');
var path = require('path');
var glob = require('glob');
var yargs = require('yargs').argv;
var generateIssues = require('./issue-generation').generate;
var generateHtml = require('./html-generation').generate;

// compute paths
var configDir = __dirname + '/../conf';
var outDir = __dirname + '/../out';

// iterate through config files
glob(configDir + '/*.conf.js', {}, function(err, confPaths) {
	confPaths.forEach(function(configPath) {

		// compute the config's short name, important paths
		var configName = path.basename(configPath, '.conf.js');
		var issuesPath = outDir + '/' + configName + '.json';
		var htmlPath = outDir + '/' + configName + '.html';

		// read the config data
		console.log('processing repo:', configName);
		var configData = require(configPath);

		// does the issues JSON file exist?
		fs.exists(issuesPath, function(exists) {

			var handleIssuesData = function(issuesData) {
				generateHtmlFile(configData, issuesData, htmlPath, function() {
					console.log('done.');
				});
			};

			// if command line arg -f (force), or doesn't exist
			if (yargs.f || !exists) {

				// if not, generate it
				generateIssues(configData, function(err, issuesData) {
					if (!err) {
						var issuesJson = JSON.stringify(issuesData, null, '\t'); // pretty

						// write it to disk
						fs.writeFile(issuesPath, issuesJson, function() {
							// wait for the write, then generate the HTML file
							handleIssuesData(issuesData);
						});
					} else {
						console.log('error generating issues.');
					}
				});
			} else {
				// immediately generate the HTML file
				console.log('using pre-existing issue data.');
				handleIssuesData(require(issuesPath));
			}
		});
	});
});

// generates and writes an HTML file to disk
function generateHtmlFile(configData, issuesData, writePath, done) {
	var html = generateHtml(configData, issuesData);
	fs.writeFile(writePath, html, done);
}
