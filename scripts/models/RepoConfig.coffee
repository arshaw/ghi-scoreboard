
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
	cacheIssues: null
	cacheComments: null
	cacheReactions: null

	# functions (might be null)
	parseIssue: null
	parseComments: null
	parseReactions: null
	displayValue: null

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
		@sortBy = @raw.sortBy or @columns[@columns.length - 1].name

		@cacheIssues = @raw.cacheIssues ? false
		@cacheComments = @raw.cacheComments ? false
		@cacheReactions = @raw.cacheReactions ? false

		@parseIssue = @raw.parseIssue or null
		@parseComments = @raw.parseComments or null
		@parseReactions = @raw.parseReactions or null
		@displayValue = @raw.displayValue or null


# Column Normalization
# --------------------------------------------------------------------------------------------------

DEFAULT_COLUMN_LIST = [
	'comments'
	'pluses'
]

STOCK_COLUMNS = [ {
	name: 'comments'
	icon: 'comment'
	caption: 'comments'
	prop: 'comments'
}, {
	name: 'pluses'
	icon: 'thumbs-up'
	caption: '+1'
	prop: 'pluses'
}, {
	name: 'participants'
	icon: 'user'
	caption: 'participants'
	prop: 'participants' # cache required
}, {
	name: 'commentPluses'
	icon: 'thumbs-up'
	title: '*'
	caption: '+1 from comments'
	prop: 'commentPluses' # cache required
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
