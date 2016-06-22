###
Github API utilities to be used by Node on the BACKEND ONLY.
###

request = require('request')
_ = require('lodash')
Promise = require('promise')
ghUtil = require('./gh-util')

authConfig = require('../../conf/auth')

###
Fetches all labels for a repo. Returns a proper A+ Promise.
###
exports.fetchLabels = (repoUser, repoName) ->
	new Promise (resolve, reject) ->
		ghUtil.fetchLabels repoUser, repoName, fetchItems, (err, labels) ->
			if not err
				resolve(labels)
			else
				reject(err)

###
Fetches details for a single issue. Returns a proper A+ Promise.
###
exports.fetchIssue = (repoUser, repoName, issueNumber) ->
	new Promise (resolve, reject) ->
		ghUtil.fetchIssue repoUser, repoName, issueNumber, fetchItems, (err, issue) ->
			if not err
				resolve(issue)
			else
				reject(err)

###
Fetches all issues for a repo. Returns a proper A+ Promise.
###
exports.fetchIssues = (repoUser, repoName) ->
	new Promise (resolve, reject) ->
		ghUtil.fetchIssues repoUser, repoName, fetchItems, (err, issues) ->
			if not err
				resolve(issues)
			else
				reject(err)

###
Fetches all comments for a specific issue. Returns a proper A+ Promise.
###
exports.fetchComments = (repoUser, repoName, issueNumber) ->
	new Promise (resolve, reject) ->
		ghUtil.fetchComments repoUser, repoName, issueNumber, fetchItems, (err, comments) ->
			if not err
				resolve(comments)
			else
				reject(err)

###
Fetches all reaction data for a specific issue. Returns a proper A+ Promise.
###
exports.fetchReactions = (repoUser, repoName, issueNumber) ->
	new Promise (resolve, reject) ->
		ghUtil.fetchReactions repoUser, repoName, issueNumber, fetchItems, (err, comments) ->
			if not err
				resolve(comments)
			else
				reject(err)

###
The `fetchFunc` for the transport layer. See gh-util for more info.
###
fetchItems = (url, params, callback) ->
	console.log('fetching', url)
	request {
		url: url
		headers: _.assign(
			{},
			ghUtil.getHeaders(authConfig.username, authConfig.accessToken),
			{ 'User-Agent': 'ghi-dashboard' } # API requires a useragent
		)
		qs: params || {}
		json: true
	}, (err, response, issues) ->
			if (!err && response.statusCode == 200)
				callback(null, issues, response.headers['link'])
			else
				callback(err || response, [], null)
