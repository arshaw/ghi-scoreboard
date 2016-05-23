
$ = require('jquery')
HeaderView = require('./HeaderView')
StatsView = require('./StatsView')

###
Responsible for rendering the entire Dashboard information for a single repo.
###
class RepoView

	repoModel: null
	headerView: null
	statsView: null

	###
	Given a RepoModel
	###
	constructor: (@repoModel) ->
		@headerView = new HeaderView(@repoModel)
		@statsView = new StatsView(@repoModel)

	###
	Renders the header/main areas into hardcoded elements already existing on the page.
	###
	render: ->
		@headerView.$el = $('#header')
		@statsView.$el = $('#stats')
		@headerView.render()
		@statsView.render()

	###
	Clears the contents of the rendered elements, but leaves them in DOM.
	Unbinds any event handlers.
	###
	destroy: ->
		@headerView.$el.empty()
		@statsView.$el.empty()

# expose
module.exports = RepoView
