
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
	parseGithub: (issueNumber, ghComments, ghReactions) ->

		# preset computations
		discussion = @computeDiscussion(ghComments, ghReactions)

		# hook for the configs to provide a function for further computations
		if @repoConfig.parseDiscussion
			@repoConfig.parseDiscussion(discussion, ghComments)

		@hash[issueNumber] = discussion

	###
	Returns stats about an issue's participants and reactions.
	TODO: rename to "details"
	###
	computeDiscussion: (ghComments, ghReactions) ->
		participantHash = @buildParticipantHash(ghComments) # TODO: don't include comment-pluses?
		commentPlusHash = @buildCommentPlusHash(ghComments)
		strictPlusHash = @buildStrictPlushHash(ghReactions)

		combinedHash = _.assign({}, participantHash, commentPlusHash, strictPlusHash)
		usernames = _.keys(combinedHash)
		totalScore = 0

		for username in usernames
			totalScore += Math.max(
				(if participantHash[username] then 1 else 0) * 0.8 # TODO: participantWeight
				(if commentPlusHash[username] then 1 else 0) * 0.9 # TODO: commentPlusWeight
				(if strictPlusHash[username] then 1 else 0) * 1.0 # TODO: strictPlusWeight
			)

		{
			participants: _.keys(participantHash).length
			commentPluses: _.keys(commentPlusHash).length
			strictPluses: _.keys(strictPlusHash).length
			score: totalScore
		}

	###
	Generates a hash of { username: true } for every user participating in an issue's conversation.
	###
	buildParticipantHash: (ghComments) ->
		usernameHash = {}
		for ghComment in ghComments
			usernameHash[ghComment.user.login] = true # TODO: filter with blacklist
		usernameHash

	###
	Generates a hash of { username: true } for every user who has commented with a "+1" or thumbsup
	in the content of a comment.
	###
	buildCommentPlusHash: (ghComments) ->
		usernameHash = {}
		for ghComment in ghComments
			# "+1" (text, at beginning) or ":+1:" (thumbsup emoji, anywhere)
			if /(^\s*\+1|\:\+1\:)/.test(ghComment.body)
				usernameHash[ghComment.user.login] = true # TODO: filter with blacklist
		usernameHash

	###
	Generates a hash of { username: true } for every user who has reacted with a thumbsup
	on the main issue.
	###
	buildStrictPlushHash: (ghReactions) ->
		usernameHash = {}
		for ghReaction in ghReactions
			if ghReaction.content == '+1'
				usernameHash[ghReaction.user.login] = true # TODO: filter with blacklist
		usernameHash

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
