
process = require('process')
fs = require('fs')
Promise = require('promise')
async = require('async')
writeFile = Promise.denodeify(fs.writeFile) # will return a promise
mkdirp = Promise.denodeify(require('mkdirp')) # will return a promise
RepoConfig = require('./models/RepoConfig')
RepoCache = require('./models/RepoCache')

rawConfig = require('../conf/conf')
OUT_DIR = __dirname + '/../out/json'

###
Builds a cache file for each repo entry in the config.
Exits with an error code if an exception was thrown, or no repos processed.
###
run = ->
	repoConfigs = RepoConfig.parseConfigs(rawConfig)
	processConfigs(repoConfigs)
		.then (successCnt) ->
			if successCnt
				console.log('processed', successCnt, 'repos.')
			else
				console.log('no repos to process.')
				process.exitCode = 1
		, (err) ->
			console.log(err)
			process.exitCode = 1

###
Builds the cache for one or more repos, given an array of RepoConfigs.
Executes IN SERIAL.
###
processConfigs = (repoConfigs) ->
	new Promise (resolve, reject) ->
		successCnt = 0

		q = async.queue (repoConfig, taskCallback) ->
			cacheBuilder = new RepoCache(repoConfig)
			cacheBuilder.build()
				.then (rawData) ->
					if rawData?
						writeJson(repoConfig.name, rawData)
							.then ->
								successCnt += 1
								taskCallback() # move on
					else
						taskCallback() # no work to perform. move on
				.catch (err) ->
					# an error was thrown at some point in the process
					q.kill() # don't process any more items
					reject(err) # error!

		# called when all items have been processed
		q.drain = ->
			resolve(successCnt) # done!

		q.push(repoConfigs) # start processing all configs

###
Writes a repo's cache data to disk.
Given a repo's string name and plain object data to be serialized to JSON.
###
writeJson = (repoName, rawData) ->
	mkdirp(OUT_DIR) # recursively create the directory
		.then ->
			outPath = OUT_DIR + '/' + repoName + '.json'
			writeFile(outPath, JSON.stringify(rawData))

# immediately execute!
run()


###
# TEST CODE for downloading and parsing a single issue

ghNode = require('./data/gh-node')
IssueCollection = require('./collections/IssueCollection')
RepoCache = require('./models/RepoCache')
repoConfig = RepoConfig.parseConfigs(rawConfig)[0]

ghNode.fetchIssue('fullcalendar', 'fullcalendar', 2978).then (singleRawIssue) ->
	issueCollection = new IssueCollection(repoConfig)
	issueCollection.parseGithub([ singleRawIssue ])
	repoCache = new RepoCache(repoConfig)
	repoCache.fetchDiscussions(issueCollection) # promise
.then (discussionCollection) ->
	console.log(discussionCollection.getRaw())
.catch (err) ->
	console.log(err.stack)
###
