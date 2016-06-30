
$ = require('jquery')
_ = require('lodash')
Cookie = require('js-cookie')
RowCollection = require('../models/RowCollection')

# TODO: also requires Bootstrap JS

tabsTpl = require('../../templates/tabs.tpl')
splitpaneTpl = require('../../templates/splitpane.tpl')
labelTableTpl = require('../../templates/label-table.tpl')
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

		# dynamically adjust title of page
		repoConfig = @repoModel.repoConfig
		document.title = repoConfig.name + ' · Issue Dashboard'

		@$el.text('Loading...')

		$.when(
			@repoModel.getLabels()
			@repoModel.getIssues()
			@repoModel.getComments()
			@repoModel.getReactions()
		).then (labelCollection, issueCollection, commentCollection, reactionCollection) =>

			@labelCollection = labelCollection

			rowCollection = new RowCollection(@repoModel.repoConfig)
			rowCollection.processCollections(
				issueCollection
				commentCollection
				reactionCollection
			)

			@$el.html(@renderHtml(rowCollection))
			@initHandlers()

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
	Attaches DOM event handlers for user interaction
	###
	initHandlers: ->
		@$el.find('[data-toggle="tooltip"]').tooltip() # bootstrap

		# when clicking on an issue row, go to the issue's URL
		@$el.on 'click', '.issue-table tbody tr', (ev) ->
			$target = $(ev.target)
			if not $target.closest('a').length # not clicked within <a>
				$tr = $target.closest('tr')
				url = $tr.data('url')
				if url
					window.open(url)
			return

	###
	Clears the contents of the element and unbinds handlers.
	###
	destroy: ->
		@$el.empty()
		@$el.off() # remove all handlers. TODO: more precise

	###
	Main entry point for rendering
	###
	renderHtml: (rowCollection) ->
		res = @renderUi(@repoModel.repoConfig.raw, rowCollection)
		res.html

	###
	Renders HTML for a component of the dashboard, defined by the `ui` config object.
	Returns { html, issueCnt }
	###
	renderUi: (ui, rowCollection) ->
		if ui.tabs # always an array
			@renderTabs(ui.tabs, rowCollection)

		else if ui.splitpane # always an array
			@renderSplitpane(ui.splitpane, rowCollection)

		else if ui.layout # always an array. just a single column of content
			@renderLayout(ui.layout, rowCollection)

		else if ui.label # always an object
			@renderLabelTable(ui.label, rowCollection)

		else
			@renderTable(rowCollection.query())

	###
	Renders HTML for a tab component, based on an array of tab configuration objects.
	Returns { html, issueCnt }
	###
	renderTabs: (tabs, rowCollection) ->
		issueCnt = 0
		tabsForTpl = 
			for tab, i in tabs
				inner = @renderUi(tab, rowCollection)
				issueCnt += inner.issueCnt
				{
					name: tab.title.toLowerCase()
					title: tab.title
					isActive: not i # is the first?
					count: inner.issueCnt
					content: inner.html
				}
		html = tabsTpl({ tabs: tabsForTpl })
		{ html, issueCnt }

	###
	###
	renderSplitpane: (panes, rowCollection) ->
		issueCnt = 0
		panesForTpl =
			for pane in panes
				inner = @renderUi(pane, rowCollection)
				issueCnt += inner.issueCnt
				{
					width: pane.width
					content: inner.html
				}
		html = splitpaneTpl({ panes: panesForTpl })
		{ html, issueCnt }

	###
	###
	renderLayout: (layoutItems, rowCollection) ->
		issueCnt = 0
		html = ''
		for layoutItem in layoutItems
			inner = @renderUi(layoutItem, rowCollection)
			issueCnt += inner.issueCnt
			html += inner.html
		{ html, issueCnt }

	###
	Renders a table for issues that match ALL of the given labels,
	complete with a header displaying the labels.
	Returns { html, issueCnt }
	###
	renderLabelTable: (labelName, rowCollection) ->
		label = @labelCollection.getByName(labelName)
		sortedRows = rowCollection.query(labelName)
		inner = @renderTable(sortedRows, labelName)
		html = labelTableTpl({
			label: label
			count: inner.issueCnt
			tableHtml: inner.html
		})
		{ html, issueCnt: inner.issueCnt }

	###
	Renders a sorted table of issue rows.
	Accepts an ARRAY OF ROWS (not a collection).
	Returns { html, issueCnt }
	###
	renderTable: (rows, hiddenLabelNames=[]) ->
		rowsForTpl = @getRowsForTable(rows, hiddenLabelNames)
		html = tableTpl({
			columns: @repoModel.repoConfig.columns
			count: rowsForTpl.length
			rows: rowsForTpl
		})
		{ html, issueCnt: rowsForTpl.length }

	###
	Gets an array of row objects used for HTML template rendering.
	###
	getRowsForTable: (rows, hiddenLabelNames) ->

		if typeof hiddenLabelNames == 'string'
			hiddenLabelNames = [ hiddenLabelNames ]

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
		formatNumber = repoConfig.formatNumber
		sortBy = repoConfig.sortBy

		for column in repoConfig.columns

			value = valueHash[column.name]

			if typeof value == 'number' and formatNumber
				value = formatNumber(value)

			{
				value: value
				isSorted: column.name == sortBy
			}

# expose
module.exports = RepoView
