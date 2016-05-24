
$ = require('jquery')
HeaderView = require('./HeaderView')
RepoView = require('../views/RepoView')

###
Renders a topbar for navigation and delegates the rendering of information
about a repo's issues to RepoView.
###
class DashboardView

	dashboardModel: null
	isRendered: false
	headerView: null
	repoView: null

	###
	Accepts a DashboardModel
	###
	constructor: (@dashboardModel) ->
		@headerView = new HeaderView(@dashboardModel)

	###
	Renders everything, unrendering previous stuff, safe to be called repeatedly.
	###
	rerender: ->
		if @isRendered
			@destroy()
		@render()

	###
	Renders everything into hardcoded elements on the page
	###
	render: ->
		@headerView.$el = $('#header')
		@headerView.render()

		@repoView = new RepoView(@dashboardModel.currentRepoModel)
		@repoView.$el = $('#stats')
		@repoView.render()

		@isRendered = true

	###
	Clears all rendering and unbinds handlers
	###
	destroy: ->
		@headerView.destroy()
		@repoView.destroy()

# expose
module.exports = DashboardView
