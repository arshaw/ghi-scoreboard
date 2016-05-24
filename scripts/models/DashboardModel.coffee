
RepoConfig = require('./RepoConfig')
RepoModel = require('../models/RepoModel')

###
Controlls the repos within a dashboard app
###
class DashboardModel

	repoModels: null
	currentRepoModel: null

	###
	Given a raw master config object
	###
	constructor: (masterConfig) ->
		repoConfigs = RepoConfig.parseConfigs(masterConfig)
		@repoModels =
			for repoConfig in repoConfigs
				new RepoModel(repoConfig)

		@currentRepoModel = @repoModels[0]

# expose
module.exports = DashboardModel
