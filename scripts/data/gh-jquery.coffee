###
Github API utilities to be used on the FRONTEND ONLY. Leverages jQuery.ajax.
###

$ = require('jquery')
Cookie = require('js-cookie')
ghUtil = require('./gh-util')

###
Fetches all labels for a repo. Returns a jQuery promise.
###
exports.fetchLabels = (repoUser, repoName) ->
	deferred = $.Deferred()
	ghUtil.fetchLabels repoUser, repoName, fetchItems, (err, labels) ->
		if !err
			deferred.resolve(labels)
		else
			deferred.reject(err)
	deferred.promise()

###
Fetches all issues for a repo. Returns a jQuery promise.
###
exports.fetchIssues = (repoUser, repoName) ->
	deferred = $.Deferred()
	ghUtil.fetchIssues repoUser, repoName, fetchItems, (err, issues) ->
		if !err
			deferred.resolve(issues)
		else
			deferred.reject(err)
	deferred.promise()

###
The `fetchFunc` for the transport layer. See gh-util for more info.
###
fetchItems = (url, params, callback) ->
	console.log('fetching', url)
	username = Cookie.get('github-username')
	accessToken = Cookie.get('github-access-token')
	$.ajax
		url: url
		type: 'GET'
		headers: ghUtil.getHeaders(username, accessToken)
		data: params || {}
	.done (issues, textStatus, xhr) ->
		callback(null, issues, xhr.getResponseHeader('link'))
	.fail (xhr) ->
		callback(xhr, [], null)
