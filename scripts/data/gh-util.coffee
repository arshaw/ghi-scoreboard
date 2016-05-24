###
Network-library-agnostic utility functions for fetching items (labels/issues/comments)
from Github's API.

the `fetchFunc` argument
------------------------
Called with (url, GET_params, callback) params.
It must call `callback` with (err, itemArray, nextHeader).
See gh-node or gh-jquery's `fetchItems` for example.
###

btoa = require('btoa')

WAIT = 100 # time to wait in between fetching pages of items (labels/issues/comments)
MAX_PER_PAGE = 100 # max number of items per-page that Github API will allow

###
Calls `callback` when all labels for a repo are fetched. `callback(err, labels)`
###
exports.fetchLabels = (repoUser, repoName, fetchFunc, callback) ->
	fetchAllItems(
		'https://api.github.com/repos/' + repoUser + '/' + repoName + '/labels'
		null
		fetchFunc
		callback
	)

###
Calls `callback` when all issues for a repo are fetched. `callback(err, issues)`
###
exports.fetchIssues = (repoUser, repoName, fetchFunc, callback) ->
	fetchAllItems(
		'https://api.github.com/repos/' + repoUser + '/' + repoName + '/issues'
		{
			sort: 'comments' # 
			direction: 'desc'
			per_page: MAX_PER_PAGE
			# TODO: do a limit of max results returned
		}
		fetchFunc
		callback
	)

###
Calls `callback` when all comments for a single issue are fetched. `callback(err, comments)`
###
exports.fetchComments = (repoUser, repoName, issueNumber, fetchFunc, callback) ->
	fetchAllItems(
		'https://api.github.com/repos/' + repoUser + '/' + repoName +
			'/issues/' + issueNumber + '/comments'
		{
			per_page: MAX_PER_PAGE
			# TODO: do a limit of max results returned
		}
		fetchFunc
		callback
	)

###
Given a `fetchFunc`, returns an accumulation of all pages of items.
###
fetchAllItems = (url, params, fetchFunc, callback) ->
	allItems = []

	processResponse = (err, items, linkHeader) ->
		if !err
			allItems.push.apply(allItems, items) # append array items
			nextUrl = parseNextUrl(linkHeader)
			if nextUrl
				setTimeout -> # call stack problems?
					fetchFunc(nextUrl, {}, processResponse)
				, WAIT || 0
			else
				callback(null, allItems)
		else
			callback(err, [])

	fetchFunc(url, params, processResponse)

###
Given the raw HTTP header for "next", returns the next page's URL.
###
parseNextUrl = (linkHeader='') ->
	nextMatch = linkHeader.match(/<([^>]*)>;\s*rel="next"/)
	if nextMatch
		nextMatch[1]
	else
		null

###
Generates HTTP headers that should be sent out with every request to Github's API.
Optionally given Basic Auth information to pass along.
###
exports.getHeaders = (username, accessToken) ->
	headers = {
		# experimental feature to get reactions:
		# https://developer.github.com/v3/issues/#reactions-summary-1
		Accept: 'application/vnd.github.squirrel-girl-preview'
	}
	if username and accessToken
		headers.Authorization = 'Basic ' + btoa(username + ':' + accessToken)
	headers
