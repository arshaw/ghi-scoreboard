
_ = require('lodash')

###
Holds aggregated comment information for each issue in a repo.
###
class CommentCollection # TODO: rename to CommentSummary

	repoConfig: null
	hash: null # keyed by issue number

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->
		@hash = {}

	###
	Process comments for a single issue from the Github API. Store the compiled data.
	###
	parseGithub: (issueNumber, ghComments) ->
		summary = @computeSummary(ghComments)

		# hook for computing additional properties
		if @repoConfig.parseComments
			@repoConfig.parseComments(ghComments, summary, issueNumber)

		@hash[issueNumber] = summary

	###
	Returns a stats object about a single issue's comments
	###
	computeSummary: (ghComments) ->
		normalHash = {}
		plusHash = {}

		for ghComment in ghComments
			username = ghComment.user.login

			# "+1" (text, at beginning) or ":+1:" (thumbsup emoji, anywhere)
			# TODO: make it so that whole comment contents needs to match
			if /(^\s*\+1|\:\+1\:)/.test(ghComment.body)
				plusHash[username] = true
			else
				normalHash[username] = true

		# TODO: don't set empty keys
		{
			normal: _.keys(normalHash)
			pluses: _.keys(plusHash)
		}

	###
	For serialization
	###
	getRaw: ->
		@hash

	###
	For deserializes
	###
	setRaw: (@hash) ->

	###
	Gets the comment summary for a specific issue
	###
	getByNumber: (issueNumber) ->
		@hash[issueNumber]

# make public
module.exports = CommentCollection
