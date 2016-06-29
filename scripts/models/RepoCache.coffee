
Promise = require('promise')
async = require('async')
gh = require('../data/gh-node')
LabelCollection = require('./LabelCollection')
IssueCollection = require('./IssueCollection')
CommentSummary = require('./CommentSummary')
ReactionSummary = require('./ReactionSummary')

###
Builds the server-side cache to be used by the frontend.
ONLY INTENDED FOR BACKEND USE.
###
class RepoCache

	repoConfig: null
	labelsPromise: null
	issuesPromise: null
	commentsPromise: null
	reactionsPromise: null

	###
	Given a RepoConfig
	###
	constructor: (@repoConfig) ->

	###
	Generates a plain object that holds all cache information.
	The config determines what values will be stored (labels/issues/comments/reactions).
	If no items were flagged for caching, resolves to `null`.
	Returns a promise.
	###
	build: ->
		anyResults = false
		out = { start: new Date().toString() }

		# in serial
		@buildLabels().then (labels) =>
			if labels
				out.labels = labels
				anyResults = true
			@buildIssues()
		.then (issues) =>
			if issues
				out.issues = issues
				anyResults = true
			@buildComments()
		.then (comments) =>
			if comments
				out.comments = comments
				anyResults = true
			@buildReactions()
		.then (reactions) =>
			if reactions
				out.reactions = reactions
				anyResults = true
			out.end = new Date().toString()
			if anyResults
				out
			else
				null

	###
	Generates a raw array of labels to be stored in the cache.
	If labels were not configured to be cached, resolves to `null`.
	Returns a promise.
	###
	buildLabels: ->
		if @repoConfig.cacheIssues # implies that labels should be cached
			@getLabels().then (labelCollection) ->
				labelCollection.getRaw()
		else
			Promise.resolve(null)

	###
	Generates a raw array of issues to be stored in the cache.
	If issues were not configured to be cached, resolves to `null`.
	Returns a promise.
	###
	buildIssues: ->
		if @repoConfig.cacheIssues
			@getIssues().then (issueCollection) ->
				issueCollection.getRaw()
		else
			Promise.resolve(null)

	###
	Generates a raw object hash of comment data to be stored in the cache.
	If comments were not configured to be cached, resolves to `null`.
	Returns a promise.
	###
	buildComments: ->
		if @repoConfig.cacheComments
			@getComments().then (commentCollection) ->
				commentCollection.getRaw()
		else
			Promise.resolve(null)

	###
	Generates a raw object hash of reaction data to be stored in the cache.
	If reactions were not configured to be cached, resolves to `null`.
	Returns a promise.
	###
	buildReactions: ->
		if @repoConfig.cacheReactions
			@getReactions().then (reactionCollection) ->
				reactionCollection.getRaw()
		else
			Promise.resolve(null)

	###
	Generates a LabelCollection for all labels in a repo's issue tracker.
	Returns a promise. Won't fetch more than once.
	###
	getLabels: ->
		@labelsPromise ?= @fetchLabels() # TODO: not safe against recursion

	###
	Generates an IssueCollection for all issues in a repo's issue tracker.
	Returns a promise. Won't fetch more than once.
	###
	getIssues: ->
		@issuesPromise ?= @fetchIssues() # TODO: not safe against recursion

	###
	Generates a CommentSummary for all issues in a repo.
	Returns a promise. Won't fetch more than once.
	###
	getComments: ->
		@commentsPromise ?= @getIssues().then (issueCollection) =>
			@fetchComments(issueCollection)

	###
	Generates a ReactionSummary for all issues in a repo.
	Returns a promise. Won't fetch more than once.
	###
	getReactions: ->
		@reactionsPromise ?= @getIssues().then (issueCollection) =>
			@fetchReactions(issueCollection)

	###
	Fetches all label information from the Github API, as a LabelCollection.
	Returns a promise.
	###
	fetchLabels: ->
		gh.fetchLabels(@repoConfig.user.name, @repoConfig.name).then (ghLabels) =>
			labelCollection = new LabelCollection(@repoConfig)
			labelCollection.parseGithub(ghLabels)
			labelCollection

	###
	Fetches all issues from the Github API, as an IssueCollection.
	Returns a promise.
	###
	fetchIssues: ->
		gh.fetchIssues(@repoConfig.user.name, @repoConfig.name).then (ghIssues) =>
			issueCollection = new IssueCollection(@repoConfig)
			issueCollection.parseGithub(ghIssues)
			issueCollection

	###
	Fetches and summarizes comment data for all issues. Returns a promise the yields a CommentSummary.
	Will rate-limit the requests because there will be one request per-issue.
	###
	fetchComments: (issueCollection) ->
		new Promise (resolve, reject) =>
			commentCollection = new CommentSummary(@repoConfig)

			q = async.queue (issue, taskCallback) =>
				gh.fetchComments(@repoConfig.user.name, @repoConfig.name, issue.number)
					.then (ghComments) =>
						commentCollection.parseGithub(issue.number, ghComments)
						taskCallback() # move on to next issue
					.catch (err) ->
						q.kill() # stop the queue, don't call drain
						reject(err) # final callback with error

			# called when all items in queue have been processed
			# TODO: figure out why this swallows exceptions
			q.drain = ->
				resolve(commentCollection)

			q.push(issueCollection.items) # start processing

	###
	Fetches and summarizes reaction data for all issues. Returns a promise the yields a ReactionSummary.
	Will rate-limit the requests because there will be one request per-issue.
	###
	fetchReactions: (issueCollection) ->
		new Promise (resolve, reject) =>
			reactionCollection = new ReactionSummary(@repoConfig)

			q = async.queue (issue, taskCallback) =>
				gh.fetchReactions(@repoConfig.user.name, @repoConfig.name, issue.number)
					.then (ghReactions) =>
						reactionCollection.parseGithub(issue.number, ghReactions)
						taskCallback() # move on to next issue
					.catch (err) ->
						q.kill() # stop the queue, don't call drain
						reject(err) # final callback with error

			# called when all items in queue have been processed
			# TODO: figure out why this swallows exceptions
			q.drain = ->
				resolve(reactionCollection)

			q.push(issueCollection.items) # start processing


# expose
module.exports = RepoCache
