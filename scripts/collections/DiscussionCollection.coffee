
_ = require('lodash')

###
Holds information about all the comment threads in all issues of an issue tracker.
Holds a compact compiled information, not every single comment.
###
class DiscussionCollection

	repoConfig: null
	hash: null # keyed by issue number

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->
		@hash = {}

	###
	Process comments for a single issue from the Github API and store the compiled data
	###
	parseGithub: (issueNumber, ghComments) ->

		# preset computations
		discussion = {
			participants: @computeParticipants(ghComments)
			commentPluses: @computeUniquePluses(ghComments)
		}

		# hook for the configs to provide a function for further computations
		if @repoConfig.parseDiscussion
			@repoConfig.parseDiscussion(discussion, ghComments)

		@hash[issueNumber] = discussion

	###
	Counts unique users who comment in an issue's thread
	###
	computeParticipants: (ghComments) ->
		usernameHash = {}
		for ghComment in ghComments
			usernameHash[ghComment.user.login] = true
		_.keys(usernameHash).length

	###
	Counts the number of +1 or thumbsups IN COMMENTS, unique by user
	###
	computeUniquePluses: (ghComments) ->
		usernameHash = {}
		for ghComment in ghComments
			# "+1" (text) or ":+1:" (thumbsup emoji)
			if /^\s*(\+1|\:\+1\:)/.test(ghComment.body)
				usernameHash[ghComment.user.login] = true
		_.keys(usernameHash).length

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
	Gets the discussion information for a specific issue
	###
	getByNumber: (issueNumber) ->
		@hash[issueNumber]

# expose
module.exports = DiscussionCollection
