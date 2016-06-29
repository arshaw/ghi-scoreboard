
_ = require('lodash')

###
Holds aggregated reaction information for each issue in a repo.
###
class ReactionCollection # TODO: rename to ReactionSummary

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
		usernameHash = {}

		for ghReaction in ghReactions
			if ghReaction.content == '+1'
				usernameHash[ghReaction.user.login] = true

		# TODO: don't set empty keys
		{
			pluses: _.keys(usernameHash)
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
	Gets the reaction summary for a specific issue
	###
	getByNumber: (issueNumber) ->
		@hash[issueNumber]

# make public
module.exports = ReactionCollection
