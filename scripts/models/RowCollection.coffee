
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

			row.valueHash = @computeValueHash(row)
			row

	###
	Assembles and returns a hash of computed cell values.
	Each corresponds to a column in the dashboard UI.
	###
	computeValueHash: (issue) ->
		hash = @computeStockValues(issue)

		for column in @repoConfig.columns
			hash[column.name] =
				if column.prop
					issue[column.prop] # easy property
				else
					column.value(issue) # function that computes the values
		hash

	###
	Compute import stock cell values available to the row. Returns a new object.
	###
	computeStockValues: (issue) ->
		nonPlusCommentUsernames = (issue.commentBreakdown or {}).nonPlus or []
		plusCommentUsernames = (issue.commentBreakdown or {}).plus or []
		plusReactionUsernames = (issue.reactionBreakdown or {}).plus or []

		nonPlusCommentHash = @buildUsernameHash(nonPlusCommentUsernames)
		plusCommentHash = @buildUsernameHash(plusCommentUsernames)
		plusReactionHash = @buildUsernameHash(plusReactionUsernames)

		combinedHash = _.assign({}, nonPlusCommentHash, plusCommentHash, plusReactionHash)
		usernames = _.keys(combinedHash)
		totalScore = 0

		for username in usernames
			totalScore += Math.max(
				(if nonPlusCommentHash[username] then 1 else 0) * 0.8 # TODO: participantWeight
				(if plusCommentHash[username] then 1 else 0) * 0.9 # TODO: commentPlusWeight
				(if plusReactionHash[username] then 1 else 0) * 1.0 # TODO: strictPlusWeight
			)

		{
			participants: nonPlusCommentUsernames.length + plusCommentUsernames.length
			plusComments: plusCommentUsernames.length
			plusReactions: plusReactionUsernames.length
			score: totalScore
		}

	###
	Turns an array of username strings into a hash. Has `true` values.
	###
	buildUsernameHash: (usernameArray) ->
		usernameHash = {}
		for username in usernameArray
			usernameHash[username] = true # TODO: filter with blacklist
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
