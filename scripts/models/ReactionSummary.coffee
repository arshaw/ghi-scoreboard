
_ = require('lodash')

###
Holds aggregated reaction information for each issue in a repo.
###
class ReactionSummary

	repoConfig: null
	hash: null # keyed by issue number

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->
		@hash = {}

	###
	Process reactions for a single issue from the Github API. Store the compiled data.
	Accepts the expanded reaction information from Github, not merely the summary on the main issue request.
	###
	parseGithub: (issueNumber, ghReactions) ->
		summary = @computeSummary(ghReactions)

		# hook for computing additional properties
		if @repoConfig.parseReactions
			@repoConfig.parseReactions(ghReactions, summary, issueNumber)

		@hash[issueNumber] = summary

	###
	Returns a stats object about a single issue's reactions
	###
	computeSummary: (ghReactions) ->
		plusHash = {} # by username

		for ghReaction in ghReactions
			if ghReaction.content == '+1'
				plusHash[ghReaction.user.login] = true

		plusUsernames = _.keys(plusHash)

		# compile into an object and return
		out = {}
		if plusUsernames.length
			out.plus = plusUsernames
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
	Gets the reaction summary for a specific issue
	###
	getByNumber: (issueNumber) ->
		@hash[issueNumber]

# make public
module.exports = ReactionSummary
