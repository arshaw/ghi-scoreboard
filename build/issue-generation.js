// Generates data for a Github repos's issues.
// Accesses data from the Github API as well as scraping.
// Defers parsing of the issue HTML files to issue-parsing.js

var request = require('request');
var async = require('async');
var parseIssueHtml = require('./issue-parsing').parseHtml;

// Given a config object for a repo, generates data for all its issues.
exports.generate = function(configData, done) {
	var issuesData = configData.issues;

	scrapeIssues(issuesData, function(err) {
		done(err, err ? null : issuesData);
	});
};

// Fetches data for issue objects by scraping their HTML source code.
// Mutates the original issue objects with additional properties.
function scrapeIssues(issuesData, allDone) {

	// create a structure that queues up requests for issue HTML source code,
	// and then processes the result
	var q = async.queue(function(issueData, qDone) { // process one issue...

		// do retrying for unresponsive network connections
		async.retry({
			times: 3,
			interval: 1000
		}, function(retryDone) { // execute an async action for an issue...

			// get the HTML source code
			var url = issueData.url;
			console.log('requesting', url);
			request(url, function(err, response, html) {
				if (!err) {
					// success!
					var result = parseIssueHtml(html);
					retryDone(null, result); // report result, cease retrying
				} else {
					// error!
					console.log('failed.');
					retryDone(err, null); // report error
				}
			});

		}, function(err, result) { // one issue has been processed...

			if (!err) {
				// success!
				// store the result
				issueData.scraped = result;
				qDone(err); // move on to the next issue
			} else {
				// failure!
				q.kill(); // stop the queue, don't call drain
				allDone(err); // final callback with error
			}
		});
	});

	// called when no more items in the queue
	q.drain = function() {
		allDone(null); // final callback. null = no error
	};

	q.push(issuesData); // queue up all issues
}
