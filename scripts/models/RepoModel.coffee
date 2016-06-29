
$ = require('jquery')
gh = require('../data/gh-jquery')
LabelCollection = require('./LabelCollection')
IssueCollection = require('./IssueCollection')
CommentSummary = require('./CommentSummary')
ReactionSummary = require('./ReactionSummary')

# where the JSON cache files live, relative the app's root in the browser
CACHE_PATH = 'json'

###
Holds information about a repo's issue tracker, including labels/issues/comments/reactions.
INTENDED FOR CLIENT-SIDE USE ONLY.
For backend use, pass around a RepoConfig instead.
###
class RepoModel

	repoConfig: null
	labelsPromise: null
	issuesPromise: null
	commentsPromise: null
	reactionsPromise: null
	cachePromise: null

	###
	Given a RepoConfig
	###
	constructor: (@repoConfig) ->

	###
	Returns a promise for getting all the issue tracker's labels.
	Resolves to a LabelCollection. Won't fetch more than once.
	###
	getLabels: ->
		@labelsPromise ?= @fetchLabels() # TODO: not safe against recursion

	###
	Returns a promise for getting all the issue tracker's issues.
	Resolves to a IssueCollection. Won't fetch more than once.
	###
	getIssues: ->
		@issuesPromise ?= @fetchIssues() # TODO: not safe against recursion

	###
	Returns a promise for getting compiled comment information for all issues.
	Resolves to a CommentSummary. Won't fetch more than once.
	###
	getComments: ->
		@commentsPromise ?= @fetchComments()

	###
	Returns a promise for getting compiled reaction information for all issues.
	Resolves to a ReactionSummary. Won't fetch more than once.
	###
	getReactions: ->
		@reactionsPromise ?= @fetchReactions()

	###
	Returns a promise for getting the raw data of the server-side cache,
	already assumed to be generated. Resolves to a raw object with keys.
	###
	getCache: ->
		@cachePromise ?= @fetchCache() # TODO: not safe against recursion

	###
	Fetches a LabelCollection from either Github API or the cache,
	Returns a promise.
	###
	fetchLabels: ->
		if @repoConfig.cacheIssues # implies that labels are cached
			@getCache().then (rawData) =>
				labelCollection = new LabelCollection(@repoConfig)
				labelCollection.setRaw(rawData.labels)
				labelCollection
		else
			@fetchLabelsFromGithub()

	###
	Fetches an IssueCollection from either Github API or the cache,
	Returns a promise.
	###
	fetchIssues: ->
		if @repoConfig.cacheIssues
			@getCache().then (rawData) =>
				issueCollection = new IssueCollection(@repoConfig)
				issueCollection.setRaw(rawData.issues)
				issueCollection
		else
			@fetchIssuesFromGithub()

	###
	Fetches an CommentSummary from cache.
	If the `cacheComments` config option is not on, resolves to an empty collection.
	Returns a promise.
	###
	fetchComments: ->
		if @repoConfig.cacheComments
			@getCache().then (rawData) =>
				commentCollection = new CommentSummary(@repoConfig)
				commentCollection.setRaw(rawData.comments)
				commentCollection
		else
			emptyCollection = new CommentSummary(@repoConfig)
			$.Deferred().resolve(emptyCollection).promise()

	###
	Fetches an ReactionSummary from cache.
	If the `cacheReactions` config option is not on, resolves to an empty collection.
	Returns a promise.
	###
	fetchReactions: ->
		if @repoConfig.cacheReactions
			@getCache().then (rawData) =>
				reactionCollection = new ReactionSummary(@repoConfig)
				reactionCollection.setRaw(rawData.reactions)
				reactionCollection
		else
			emptyCollection = new ReactionSummary(@repoConfig)
			$.Deferred().resolve(emptyCollection).promise()

	###
	Fetches the raw cache data from the server, as a plain object.
	Returns a promise.
	###
	fetchCache: ->
		$.ajax
			url: CACHE_PATH + '/' + @repoConfig.name + '.json'
			dataType: 'json'

	###
	Fetches a LabelCollection from Github API. Returns a promise.
	###
	fetchLabelsFromGithub: ->
		gh.fetchLabels(@repoConfig.user.name, @repoConfig.name).then (ghLabels) =>
			labelCollection = new LabelCollection(@repoConfig)
			labelCollection.parseGithub(ghLabels)
			labelCollection

	###
	Fetches an IssueCollection from Github API. Returns a promise.
	###
	fetchIssuesFromGithub: ->
		gh.fetchIssues(@repoConfig.user.name, @repoConfig.name).then (ghIssues) =>
			issueCollection = new IssueCollection(@repoConfig)
			issueCollection.parseGithub(ghIssues)
			issueCollection

# expose
module.exports = RepoModel
