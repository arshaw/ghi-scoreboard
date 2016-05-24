
$ = require('jquery')
_ = require('lodash')
Cookie = require('js-cookie')
RowCollection = require('../collections/RowCollection')

# TODO: also requires Bootstrap JS

tabsTpl = require('../../templates/tabs.tpl')
labelGroupTpl = require('../../templates/label-group.tpl')
tableTpl = require('../../templates/table.tpl')
rateLimitTpl = require('../../templates/rate-limit.tpl')

###
Responsible for rendering the tabs/groups/tables if issues in a repo
###
class RepoView

	repoModel: null
	labelCollection: null
	$el: null

	###
	Accepts a RepoModel
	###
	constructor: (@repoModel) ->

	###
	Renders the content into an already-assigned this.$el
	Will renderer in asynchronous steps, as data loads.
	###
	render: ->
		@$el.text('Loading...')

		$.when(
			@repoModel.getLabels()
			@repoModel.getIssues()
			@repoModel.getDiscussions()
		).then (labelCollection, issueCollection, discussionCollection) =>

			@labelCollection = labelCollection

			rowCollection = new RowCollection(@repoModel.repoConfig)
			rowCollection.processCollections(issueCollection, discussionCollection)

			@$el.html(@renderHtml(rowCollection))

			@$el.find('[data-toggle="tooltip"]').tooltip()

		.fail (err) =>

			if err?.statusText
				@$el.html(rateLimitTpl({ error: err.statusText }))
				@initAuthForm()

			else if err?.message
				@$el.text('ERROR: ' + err.message)

			else
				@$el.text('ERROR (see console)')

	###
	Initialize event handling for access-token submission form
	###
	initAuthForm: ->
		$form = @$el.find('#auth-form').on 'submit', ->
			username = $form.find('input[name="auth-username"]').val()
			accessToken = $form.find('input[name="auth-access-token"]').val()

			# record cookies for a year
			Cookie.set('github-username', username, { expires: 365 })
			Cookie.set('github-access-token', accessToken, { expires: 365 })

			window.location.reload()
			false # prevent submission

	###
	Clears the contents of the element and unbinds handlers.
	###
	destroy: ->
		@$el.empty()

	###
	Main entry point for rendering
	###
	renderHtml: (rowCollection) ->
		@renderUi(@repoModel.repoConfig.ui, rowCollection)

	###
	Renders HTML for a component of the dashboard,
	defined by the `ui` config object.
	###
	renderUi: (ui, rowCollection) ->
		if ui.tabs
			@renderTabs(ui.tabs, rowCollection)
		else if ui.labels
			@renderLabelGroups(ui.labels, rowCollection)
		else
			@renderTable(rowCollection.query())

	###
	Renders HTML for a tab component,
	based on an array of tab configuration objects.
	###
	renderTabs: (tabs, rowCollection) ->
		tabsTpl
			tabs:
				for tab, i in tabs
					{
						name: tab.title.toLowerCase()
						title: tab.title
						isActive: not i # is the first?
						# render inner-components ...
						content: @renderUi(tab, rowCollection)
					}

	###
	Renders a list of issue tables, grouped by label.
	`labelGroups` is an array of one of the following:
		'groupname'
		[ 'groupname1', 'groupname2'] --- is an AND condition
	###
	renderLabelGroups: (labelGroups, rowCollection) ->
		html = ''
		for labelNames in labelGroups
			if typeof labelNames == 'string'
				labelNames = [ labelNames ]
			html += @renderLabelGroup(labelNames, rowCollection)
		html

	###
	Renders a table for issues that match ALL of the given labels,
	complete with a header displaying the labels.
	###
	renderLabelGroup: (labelNames, rowCollection) ->
		labels = # get objects
			for labelName in labelNames
				@labelCollection.getByName(labelName)
		sortedRows = rowCollection.query(labelNames)
		labelGroupTpl
			labels: labels
			content: @renderTable(sortedRows, labelNames)

	###
	Renders a sorted table of issue rows.
	Accepts an ARRAY OF ROWS (not a collection).
	###
	renderTable: (rows, hiddenLabelNames=[]) ->
		tableTpl
			columns: @repoModel.repoConfig.columns
			rows: @getRowsForTable(rows, hiddenLabelNames)

	###
	Gets an array of row objects used for HTML template rendering.
	###
	getRowsForTable: (rows, hiddenLabelNames) ->

		# TODO: use lodash somehow
		hiddenLabelHash = {}
		for labelName in hiddenLabelNames
			hiddenLabelHash[labelName] = true

		# returns a new transformed array of rows
		for row in rows
			_.assign({}, row, {
				labels: @getLabelsForTable(row.labelNames, hiddenLabelHash)
				cells: @getCellsForTable(row.valueHash)
			})

	###
	Gets an array of label objects used for HTML template rendering.
	Excludes those matching `hiddenLabelHash`, which is in the form:
		{ 'labelname': true }
	###
	getLabelsForTable: (labelNames, hiddenLabelHash) ->
		(@labelCollection.getByName(labelName) \
			for labelName in labelNames \
				when not hiddenLabelHash[labelName])

	###
	Gets an array of cell object used for HTML template rendering.
	Given a hash of cell values for an issue row.
	Infuses the 'isSorted' variable.
	###
	getCellsForTable: (valueHash) ->
		repoConfig = @repoModel.repoConfig
		displayValue = repoConfig.displayValue
		sortBy = repoConfig.sortBy

		for column in repoConfig.columns

			value = valueHash[column.name]
			if displayValue
				value = displayValue(value)

			{
				value: value
				isSorted: column.name == sortBy
			}

# expose
module.exports = RepoView
