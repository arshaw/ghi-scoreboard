# entrypoint for the frontend

$ = require('jquery')
DashboardController = require('./controllers/DashboardController')
rawConfig = require('../conf/conf')

dashboardController = new DashboardController(rawConfig)

$ -> # DOM ready
	dashboardController.start()
