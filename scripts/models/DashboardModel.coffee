
RepoConfig = require('./RepoConfig')
RepoModel = require('../models/RepoModel')

###
Controlls the repos within a dashboard app
###
class DashboardModel

	masterConfig: null
	repoModels: null
	currentRepoModel: null

	###
	Given a raw master config object.
	Will default to the first repo.
	###
	constructor: (@masterConfig) ->
		repoConfigs = RepoConfig.parseConfigs(@masterConfig)
		@repoModels =
			for repoConfig in repoConfigs
				new RepoModel(repoConfig)

		@currentRepoModel = @repoModels[0]

# expose
module.exports = DashboardModel
