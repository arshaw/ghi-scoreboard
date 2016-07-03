
_ = require('lodash')

###
Assembles a list of issue rows, to be used in future tables.
Provides utilities for accessing sorted, and by label.
###
class RowCollection

	repoConfig: null

	###
	Each of these items is a "row", which is a merging of the following:
	- issue
	- commentBreakdown
	- reactionBreakdown
	- valueHash (computed cells)
	###
	items: null

	constructor: (@repoConfig) ->

	###
	Assembles and stores preliminary row objects,
	given processed issue objects, comment summary, and reaction summary
	###
	processCollections: (issueCollection, commentCollection, reactionCollection) ->
		@items = for issue in issueCollection.items
			commentBreakdown = commentCollection.getByNumber(issue.number)
			reactionBreakdown = reactionCollection.getByNumber(issue.number)

			# make a new object for the row. a superset of the issue object
			row = _.clone(issue)
			if commentBreakdown
				row.commentBreakdown = commentBreakdown
			if reactionBreakdown
				row.reactionBreakdown = reactionBreakdown

			# precompute some stats
			_.extend(row, @computeStockValues(row))

			row.valueHash = @computeValueHash(row)
			row

	###
	Assembles and returns a hash of computed cell values.
	Each corresponds to a column in the dashboard UI.
	###
	computeValueHash: (issue) ->
		hash = {}

		for column in @repoConfig.columns
			if not column.isSpecial
				hash[column.name] =
					if column.prop
						issue[column.prop] # easy property
					else
						column.value(issue) # function that computes the values
		hash

	###
	Compute import stock cell values available to the row. Returns a new object.
	###
	computeStockValues: (row) ->

		# FYI, might be duplicates between arrays, or within a single array
		nonPlusCommentUsernames = (row.commentBreakdown or {}).nonPlus or []
		plusCommentUsernames = (row.commentBreakdown or {}).plus or []
		plusReactionUsernames = (row.reactionBreakdown or {}).plus or []

		# ensure author of the issue is considered a comment participant
		nonPlusCommentUsernames.unshift(row.username)

		# hashes
		nonPlusCommentHash = @buildUsernameHash(nonPlusCommentUsernames)
		plusCommentHash = @buildUsernameHash(plusCommentUsernames)
		plusReactionHash = @buildUsernameHash(plusReactionUsernames)
		combinedHash = _.assign({}, nonPlusCommentHash, plusCommentHash, plusReactionHash)

		# username lists
		allUsernames = _.keys(combinedHash)
		participantUsernames = _.keys(_.assign({}, nonPlusCommentHash, plusCommentHash))
		plusCommentUsernames = _.keys(plusCommentHash) # reset original value
		plusReactionUsernames = _.keys(plusReactionHash) # reset original value

		# weights
		participantWeight = @repoConfig.participantWeight
		plusCommentWeight = @repoConfig.plusCommentWeight
		plusReactionWeight = @repoConfig.plusReactionWeight

		# scores
		participantScore = 0
		plusScore = 0
		totalScore = 0

		for username in allUsernames
			participantScore += Math.max(
				(if nonPlusCommentHash[username] then 1 else 0) * participantWeight
				(if plusCommentHash[username] then 1 else 0) * plusCommentWeight
			)
			plusScore += Math.max(
				(if plusCommentHash[username] then 1 else 0) * plusCommentWeight
				(if plusReactionHash[username] then 1 else 0) * plusReactionWeight
			)
			totalScore += Math.max(
				(if nonPlusCommentHash[username] then 1 else 0) * participantWeight
				(if plusCommentHash[username] then 1 else 0) * plusCommentWeight
				(if plusReactionHash[username] then 1 else 0) * plusReactionWeight
			)

		# `plusReactions` is already in the row. don't overwrite
		{
			participants: participantUsernames.length
			plusComments: plusCommentUsernames.length
			participantScore: participantScore
			plusScore: plusScore
			score: totalScore
		}

	###
	Turns an array of username strings into a hash. Has `true` values.
	###
	buildUsernameHash: (usernameArray) ->
		usernameHash = {}
		for username in usernameArray
			if not @repoConfig.excludeUserHash[username]
				usernameHash[username] = true
		usernameHash

	###
	Returns a SORTED array of issues that optionally match the given labels.
	###
	query: (labelNames=null) ->
		if labelNames
			rows = @getByLabel(labelNames)
		else
			rows = @items
		@sortRows(rows)

	###
	Returns an array of issues that match all the given labels, UNSORTED.
	`labelNames` can be a single string or an array.
	###
	getByLabel: (labelNames) ->
		if typeof labelNames == 'string'
			labelNames = [ labelNames ]
		(row for row in @items \
			when @doesRowHaveLabels(row, labelNames))

	###
	Returns true if the issue object has ALL the given labels
	###
	doesRowHaveLabels: (issue, labelNames) ->
		for labelName in labelNames
			if not (labelName in issue.labelNames)
				return false
		true

	###
	Sorts the given array of rows by the criteria in the RepoConfig
	###
	sortRows: (rows) ->
		sorted = _.clone(rows)
		sortBy = @repoConfig.sortBy
		sortFunc = (a, b) ->
			b.valueHash[sortBy] - a.valueHash[sortBy] # descending
		sorted.sort(sortFunc) # sorts in place
		sorted

# make public
module.exports = RowCollection
