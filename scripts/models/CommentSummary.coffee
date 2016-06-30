
_ = require('lodash')

###
Holds aggregated comment information for each issue in a repo.
###
class CommentSummary

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
		plusHash = {} # by username
		nonPlusHash = {} # by username

		for ghComment in ghComments
			username = ghComment.user.login

			# "+1" (text) or ":+1:" (thumbsup emoji)
			if /\+1/.test(ghComment.body)
				plusHash[username] = true
			else
				nonPlusHash[username] = true

		plusUsernames = _.keys(plusHash)
		nonPlusUsernames = _.keys(nonPlusHash)

		# compile into an object and return
		out = {}
		if plusUsernames.length
			out.plus = plusUsernames
		if nonPlusUsernames.length
			out.nonPlus = nonPlusUsernames
		out

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
module.exports = CommentSummary
