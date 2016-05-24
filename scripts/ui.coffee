# entrypoint for the frontend

$ = require('jquery')
HashRouter = require('hash-router')
DashboardModel = require('./models/DashboardModel')
DashboardView = require('./views/DashboardView')
rawConfig = require('../conf/conf')

dashboardModel = new DashboardModel(rawConfig)
dashboardView = new DashboardView(dashboardModel)

$ -> # DOM ready
	router = HashRouter()

	# TODO: handle routes that don't exist. catch-all

	# default route (renders the first repo)
	router.addRoute '#', -> # OR when no hash
		dashboardView.rerender()

	# register a route for each repo
	dashboardModel.repoModels.forEach (repoModel) ->
		router.addRoute '#' + repoModel.repoConfig.name, ->
			dashboardModel.currentRepoModel = repoModel
			dashboardView.rerender()

	window.addEventListener('hashchange', router)
	router() # start the router
