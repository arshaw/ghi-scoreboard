
RepoModel = require('../models/RepoModel')
RepoView = require('../views/RepoView')

###
Responsible for displaying the frontend of ONE repo's issue dashboard.
Joins the RepoModel and the RepoView together.
###
class RepoController

	repoConfig: null
	repoModel: null
	repoView: null

	###
	Given a RepoConfig
	###
	constructor: (@repoConfig) ->
		@repoModel = new RepoModel(@repoConfig)
		@repoView = new RepoView(@repoModel)

	###
	Displays the frontend
	###
	start: ->
		@repoView.render()

	###
	Clears the frontend from view
	###
	stop: ->
		@repoView.destroy()

# expose
module.exports = RepoController
