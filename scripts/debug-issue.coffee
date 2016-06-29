###
Usage:
	coffee ./scripts/debug-issue.coffee <ISSUE-NUMBER>
Fetches the given issue from the first repo specified in the config.
###

RepoConfig = require('./models/RepoConfig')
RepoCache = require('./models/RepoCache')
ghNode = require('./data/gh-node')
IssueCollection = require('./collections/IssueCollection')

rawConfig = require('../conf/conf')
repoConfig = RepoConfig.parseConfigs(rawConfig)[0]

issueNumber = Number(process.argv[process.argv.length - 1])
if isNaN(issueNumber)
	console.log("must provide an issue number")
else
	ghNode.fetchIssue(repoConfig.user.name, repoConfig.name, issueNumber).then (singleRawIssue) ->
		issueCollection = new IssueCollection(repoConfig)
		issueCollection.parseGithub([ singleRawIssue ])

		console.log('issues', issueCollection.getRaw())

		repoCache = new RepoCache(repoConfig)
		Promise.all([
			repoCache.fetchComments(issueCollection)
			repoCache.fetchReactions(issueCollection)
		])
	.then (results) ->
		console.log('comments', results[0].getRaw())
		console.log('reactions', results[1].getRaw())
	.catch (err) ->
		console.log(err.stack)
