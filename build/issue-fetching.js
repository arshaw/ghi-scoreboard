
var github = require('octonode');

exports.fetch = function(repoName, done) {
	var client = github.client();
	var repo = client.repo(repoName);

	repo.issues({
		page: 1,
		per_page: 10, // temporary
	}, function (err, issuesData) {
		done(err, err ? null : issuesData);
	});
};
