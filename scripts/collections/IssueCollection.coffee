
###
Holds a number of plain issue objects
###
class IssueCollection

	repoConfig: null
	items: null # an array of normalized issue objects

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->

	###
	Populates this collection with an array of raw object data from the Github API
	###
	parseGithub: (ghIssues) ->
		@items =
			for ghIssue in ghIssues
				issue = {
					number: ghIssue.number
					url: ghIssue.html_url
					title: ghIssue.title
					comments: ghIssue.comments
					pluses: ghIssue.reactions['+1']
					labelNames: (ghLabel.name for ghLabel in ghIssue.labels)
				}
				if @repoConfig.parseIssue
					@repoConfig.parseIssue(issue, ghIssue)
				issue

	###
	Serializes the normalized format
	###
	getRaw: ->
		@items

	###
	Deserializes the normalized format
	###
	setRaw: (@items) ->

	###
	Utility for retrieving all issues that have the given labelName (a string)
	###
	getByLabel: (labelName) ->
		issue for issue in @items when \
			labelName in issue.labels

# make public
module.exports = IssueCollection
