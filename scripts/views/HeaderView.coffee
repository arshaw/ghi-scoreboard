
_ = require('lodash')
headerTpl = require('../../templates/header.tpl')

###
Renders the top area of the screen, containing the current repo's title
and a repo-switcher if necessary.
###
class HeaderView

	dashboardModel: null
	$el: null

	###
	Given a RepoModel
	###
	constructor: (@dashboardModel) ->

	###
	Renders content into the already-assigned this.$el
	###
	render: ->
		@$el.html(@renderHtml())

	###
	Clears the contents of the element and unbinds handlers.
	###
	destroy: ->
		@$el.empty()

	###
	Generates HTML content.
	###
	renderHtml: ->
		headerTpl
			logo: @dashboardModel.masterConfig.logo
			repos:
				for repoModel in @dashboardModel.repoModels
					_.assign({}, repoModel.repoConfig, {
						isActive: repoModel == @dashboardModel.currentRepoModel
					})

# expose
module.exports = HeaderView
