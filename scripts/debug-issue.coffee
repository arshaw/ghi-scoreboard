###
Usage:
	coffee ./scripts/debug-issue.coffee <ISSUE-NUMBER>
Fetches the given issue from the first repo specified in the config.
###

ghNode = require('./data/gh-node')
RepoConfig = require('./models/RepoConfig')
RepoCache = require('./models/RepoCache')
IssueCollection = require('./models/IssueCollection')

rawConfig = require('../conf/conf')
repoConfig = RepoConfig.parseConfigs(rawConfig)[0]

issueNumber = Number(process.argv[process.argv.length - 1])
if isNaN(issueNumber)
	console.log("must provide an issue number")
else
	ghNode.fetchIssue(repoConfig.user.name, repoConfig.name, issueNumber).then (ghIssue) ->
		issueCollection = new IssueCollection(repoConfig)
		issueCollection.parseGithub([ ghIssue ])
		repoCache = new RepoCache(repoConfig)
		Promise.all([
			repoCache.fetchLabels()
			repoCache.fetchComments(issueCollection)
			repoCache.fetchReactions(issueCollection)
		])
		.then (results) ->
			console.log('labels', results[0].getRaw())
			console.log('issues', issueCollection.getRaw())
			console.log('comments', results[1].getRaw())
			console.log('reactions', results[2].getRaw())
	.catch (err) ->
		console.log(err.stack)
