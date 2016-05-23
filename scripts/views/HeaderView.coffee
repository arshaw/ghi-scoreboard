
headerTpl = require('../../templates/header.tpl')

###
Renders the top area of the screen, containing the current repo's title.
###
class HeaderView

	repoModel: null
	$el: null

	###
	Given a RepoModel
	###
	constructor: (@repoModel) ->

	###
	Renders content into the already-assigned this.$el
	###
	render: ->
		@$el.html(@renderHtml())

	###
	Generates HTML content.
	###
	renderHtml: ->
		headerTpl
			user: @repoModel.repoConfig.user
			repo: @repoModel.repoConfig

# expose
module.exports = HeaderView
