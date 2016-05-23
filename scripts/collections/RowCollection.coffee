
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
	- discussion
	- { valueHash }
	###
	items: null

	constructor: (@repoConfig) ->

	###
	Assembles and stores preliminary row objects,
	given processed issue objects and processed discussion objects.
	###
	processCollections: (issueCollection, discussionCollection) ->
		@items = for issue in issueCollection.items
			discussion = discussionCollection.getByNumber(issue.number) or {}
			row = _.assign({}, issue, discussion) # merge into one object
			row.valueHash = @computeValueHash(row)
			row

	###
	Assembles and returns a hash of computed cell values.
	Each corresponds to a column in the dashboard UI.
	###
	computeValueHash: (issue) ->
		hash = {}
		for column in @repoConfig.columns
			hash[column.name] =
				if column.prop
					issue[column.prop] # easy property
				else
					column.value(issue) # function that computes the values
		hash

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
