
Promise = require('promise')
async = require('async')
gh = require('../data/gh-node')
LabelCollection = require('../collections/LabelCollection')
IssueCollection = require('../collections/IssueCollection')
DiscussionCollection = require('../collections/DiscussionCollection')

###
Builds the server-side cache to be used by the frontend.
ONLY INTENDED FOR BACKEND USE.
###
class RepoCache

	repoConfig: null
	labelPromise: null
	issuePromise: null
	discussionsPromise: null

	###
	Given a RepoConfig
	###
	constructor: (@repoConfig) ->

	###
	Generates a plain object that holds all cache information.
	The config determines what values will be stored (label/issue/discussion).
	If no items were flagged for caching, resolves to `null`.
	Returns a promise.
	###
	build: ->
		startDate = new Date()

		Promise.all([
			@buildLabels()
			@buildIssues()
			@buildDiscussions()
		]).then (inputs) -> # receives an array of 3 values

			# record timing information
			endDate = new Date()
			out = {
				start: startDate.toString()
				end: endDate.toString()
			}

			# store non-null values
			anyResults = false
			[ 'labels', 'issues', 'discussions' ].forEach (propName, i) ->
				if inputs[i]?
					out[propName] = inputs[i]
					anyResults = true

			if not anyResults
				null
			else
				out

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
	Generates a raw object hash of discussion data to be stored in the cache.
	If discussions were not configured to be cached, resolves to `null`.
	Returns a promise.
	###
	buildDiscussions: ->
		if @repoConfig.cacheDiscussions
			@getDiscussions().then (discussionCollection) ->
				discussionCollection.getRaw()
		else
			Promise.resolve(null)

	###
	Generates a LabelCollection for all labels in a repo's issue tracker.
	Returns a promise. Won't fetch more than once.
	###
	getLabels: ->
		@labelPromise ?= @fetchLabels() # TODO: not safe against recursion

	###
	Generates an IssueCollection for all issues in a repo's issue tracker.
	Returns a promise. Won't fetch more than once.
	###
	getIssues: ->
		@issuePromise ?= @fetchIssues() # TODO: not safe against recursion

	###
	Generates a DiscussionCollection for all discussion data in a repo's issue tracker.
	Returns a promise. Won't fetch more than once.
	###
	getDiscussions: ->
		@discussionsPromise ?= @getIssues().then (issueCollection) =>
			@fetchDiscussions(issueCollection)

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
	Fetches all discussion data from the Github API, for all issues, as a DiscussionCollection.
	Returns a promise.
	Will rate-limit the requests because there will be one request per-issue.
	###
	fetchDiscussions: (issueCollection) ->
		new Promise (resolve, reject) =>
			discussionCollection = new DiscussionCollection(@repoConfig)

			q = async.queue (issue, taskCallback) =>
				gh.fetchComments(@repoConfig.user.name, @repoConfig.name, issue.number)
					.then (ghComments) =>

						# TODO: make this parallelizable with the comments fetch
						# TODO: have all fetching everywhere go through the same async queue
						gh.fetchReactions(@repoConfig.user.name, @repoConfig.name, issue.number)
							.then (ghReactions) =>
								discussionCollection.parseGithub(issue.number, ghComments, ghReactions)
								taskCallback() # move on to next issue

					.catch (err) ->
						q.kill() # stop the queue, don't call drain
						reject(err) # final callback with error

			# called when all items in queue have been processed
			# TODO: figure out why this swallows exceptions
			q.drain = ->
				resolve(discussionCollection)

			q.push(issueCollection.items) # start processing

# expose
module.exports = RepoCache
