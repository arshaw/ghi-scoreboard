
_ = require('lodash')

###
Returns an array of RepoConfig objects, given a master config that looks something like:
{ repo: 'me/proj' }
{ repos: [ 'me/proj' ] }
{ repos: [ { user: 'me', name: 'proj' } ] }
###
exports.parseConfigs = (masterInput) ->
	repos = []

	# parse 'repo'
	if masterInput.repo
		repos.push(new RepoConfig(masterInput.repo, masterInput))

	# parse 'repos'
	for repoInput in masterInput.repos or []
		repos.push(new RepoConfig(repoInput, masterInput))

	repos

###
Normalizes and stores information from the config, for a single repo.
###
class RepoConfig

	raw: null # merged configs

	user: null # { name, url }
	name: null # repo's name
	url: null
	columns: null
	sortBy: null

	# flags
	aggregateIssues: null
	aggregateComments: null
	aggregateReactions: null

	# functions (might be null)
	parseIssue: null
	parseComments: null
	parseReactions: null

	# filtering comments
	excludeUserHash: null

	# weights for scores
	participantWeight: null
	plusCommentWeight: null
	plusReactionWeight: null

	# for table display
	formatNumber: null

	constructor: (input, fallback={}) ->
		@raw = _.assign({}, input, fallback)

		if typeof input == 'string'
			parts = input.split('/')
			input = { user: parts[0], name: parts[1] }

		@user = {
			name: input.user
			url: 'https://github.com/' + input.user
		}
		@name = input.name
		@url = 'https://github.com/' + input.user + '/' + input.name
		@ui =
			if input.tabs or input.labels
				input
			else
				fallback
		@columns = normalizeColumns(input.columns or fallback.columns)

		@sortBy = @raw.sortBy
		if not @sortBy # needs a default?
			for column in @columns
				if not column.isSpecial
					@sortBy = column.name # rightmost non-special column

		@aggregateIssues = @raw.aggregateIssues ? false
		@aggregateComments = @raw.aggregateComments ? false
		@aggregateReactions = @raw.aggregateReactions ? false

		@parseIssue = @raw.parseIssue or null
		@parseComments = @raw.parseComments or null
		@parseReactions = @raw.parseReactions or null

		@excludeUserHash = {}
		for username in @raw.excludeUsers or []
			@excludeUserHash[username] = true

		@participantWeight = @raw.participantWeight ? 1.0
		@plusCommentWeight = @raw.plusCommentWeight ? 1.0
		@plusReactionWeight = @raw.plusReactionWeight ? 1.0

		@formatNumber = @raw.formatNumber or stockFormatNumber

###
Rounds numbers greater than 1. Displays 1 decimal point if a fraction.
###
stockFormatNumber = (n) ->
	if n > 0 and n < 1
		n.toFixed(1)
	else
		Math.round(n)

# Column Normalization
# --------------------------------------------------------------------------------------------------

DEFAULT_COLUMN_LIST = [
	'number'
	'titleAndLabels'
	'plusReactions'
]

STOCK_COLUMNS = [ {
	name: 'number'
	isSpecial: true
}, {
	name: 'title'
	isSpecial: true
}, {
	name: 'titleAndLabels'
	isSpecial: true
}, {
	name: 'plusReactions'
	prop: 'plusReactions'
	icon: 'thumbs-up'
}, {
	name: 'plusComments'
	prop: 'plusComments'
	icon: 'thumbs-up'
	title: 'comments'
}, {
	name: 'plusScore'
	prop: 'plusScore'
	icon: 'thumbs-up'
	title: 'score'
}, {
	name: 'participants'
	prop: 'participants'
	icon: 'user'
}, {
	name: 'participantScore'
	prop: 'participantScore'
	icon: 'user'
	title: 'score'
}, {
	name: 'score'
	prop: 'score'
	title: 'Score'
} ]

STOCK_COLUMN_HASH = _.keyBy(STOCK_COLUMNS, 'name')

columnGuid = 0

###
Normalizes the 'columns' config option into an array of name/prop|value.
###
normalizeColumns = (columns) ->
	columns or= DEFAULT_COLUMN_LIST

	for column in columns

		# given a shortcut string
		if typeof column == 'string'
			column = STOCK_COLUMN_HASH[column]

		# columns need a name
		column.name or= '_column' + (columnGuid += 1)

		# accumulate for return value
		column
