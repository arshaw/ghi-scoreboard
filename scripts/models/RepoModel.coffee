
$ = require('jquery')
gh = require('../data/gh-jquery')
LabelCollection = require('../collections/LabelCollection')
IssueCollection = require('../collections/IssueCollection')
DiscussionCollection = require('../collections/DiscussionCollection')

# where the JSON cache files live, relative the app's root in the browser
CACHE_PATH = 'json'

###
Holds information about a repo's issue tracker, including labels/issues/discussions.
INTENDED FOR CLIENT-SIDE USE ONLY.
For backend use, pass around a RepoConfig instead.
###
class RepoModel

	repoConfig: null
	labelPromise: null
	issuePromise: null
	discussionPromise: null
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
		@labelPromise ?= @fetchLabels() # TODO: not safe against recursion

	###
	Returns a promise for getting all the issue tracker's issues.
	Resolves to a IssueCollection. Won't fetch more than once.
	###
	getIssues: ->
		@issuePromise ?= @fetchIssues() # TODO: not safe against recursion

	###
	Returns a promise for getting compiled discussion information for all issues.
	Resolves to a DiscussionCollection. Won't fetch more than once.
	###
	getDiscussions: ->
		@discussionPromise ?= @fetchDiscussions()

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
	Fetches an DiscussionCollection from cache.
	If the `cacheDiscussions` config option is not on, resolves to an empty collection.
	Returns a promise.
	###
	fetchDiscussions: ->
		if @repoConfig.cacheDiscussions
			@getCache().then (rawData) =>
				discussionCollection = new DiscussionCollection(@repoConfig)
				discussionCollection.setRaw(rawData.discussions)
				discussionCollection
		else
			emptyCollection = new DiscussionCollection(@repoConfig)
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
