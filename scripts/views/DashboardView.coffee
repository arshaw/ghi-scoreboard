
$ = require('jquery')
HeaderView = require('./HeaderView')
RepoView = require('../views/RepoView')

###
Renders a topbar for navigation and delegates the rendering of information
about a repo's issues to RepoView.
###
class DashboardView

	dashboardModel: null
	headerView: null
	repoView: null

	###
	Accepts a DashboardModel
	###
	constructor: (@dashboardModel) ->
		@headerView = new HeaderView(@dashboardModel)

	###
	Renders everything into hardcoded elements on the page
	###
	render: ->
		@headerView.$el = $('#header')
		@headerView.render()

		@repoView = new RepoView(@dashboardModel.currentRepoModel)
		@repoView.$el = $('#stats')
		@repoView.render()

	###
	Clears all rendering and unbinds handlers
	###
	destroy: ->
		@headerView.destroy()
		@repoView.destroy()

# expose
module.exports = DashboardView
