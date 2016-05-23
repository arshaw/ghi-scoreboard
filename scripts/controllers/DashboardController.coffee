
RepoConfig = require('../models/RepoConfig')
RepoController = require('../controllers/RepoController')

###
Manages all the Repo Controllers and the switching between them.
###
class DashboardController

	repoControllers: null # hash, keyed by "repoUser/repoName"

	###
	Given a raw master config object
	###
	constructor: (masterConfig) ->
		@repoConfigs = RepoConfig.parseConfigs(masterConfig)
		@repoControllers = {}

	###
	Shows the the frontend for the first repo
	###
	start: ->
		match = window.location.hash.match(/^\#(\d+)/)
		index =
			if match
				parseInt(match[1], 10)
			else
				0
		@startRepo(@repoConfigs[index])

	###
	Shows the frontend for a repo, given its RepoConfig
	###
	startRepo: (repoConfig) ->
		key = repoConfig.user.name + '/' + repoConfig.name
		(@repoControllers[key] ?= new RepoController(repoConfig))
			.start()

# expose
module.exports = DashboardController
