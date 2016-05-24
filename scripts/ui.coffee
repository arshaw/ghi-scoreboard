# entrypoint for the frontend

$ = require('jquery')
DashboardModel = require('./models/DashboardModel')
DashboardView = require('./views/DashboardView')
rawConfig = require('../conf/conf')

dashboardModel = new DashboardModel(rawConfig)
dashboardView = new DashboardView(dashboardModel)

$ -> # DOM ready
	dashboardView.render()
