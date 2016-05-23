
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

	user: null # { name, url }
	name: null # repo's name
	url: null
	ui: null # config object for rendering the dashboard UI
	columns: null
	sortBy: null

	# flags
	cacheIssues: null
	cacheDiscussions: null

	# functions (might be null)
	parseIssue: null
	parseDiscussion: null
	displayValue: null

	constructor: (input, fallback={}) ->

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
		@sortBy = input.sortBy or fallback.sortBy or @columns[@columns.length - 1].name

		@cacheIssues = input.cacheIssues ? fallback.cacheIssues ? false
		@cacheDiscussions = input.cacheDiscussions ? fallback.cacheDiscussions ? false

		@parseIssue = input.parseIssue or fallback.parseIssue or null
		@parseDiscussion = input.parseDiscussion or fallback.parseDiscussion or null
		@displayValue = input.displayValue or fallback.displayValue or null


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
