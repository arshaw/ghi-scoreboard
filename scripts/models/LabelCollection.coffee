
Color = require('color')

###
Holds information about all the labels that exist for an issue tracker
###
class LabelCollection

	repoConfig: null
	items: null # an array of plain normalized label objects
	hash: null # the same object, keyed by label name

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->
		@items = []
		@hash = {}

	###
	Process label data from the Github API into a normalized format, and stores it
	###
	parseGithub: (ghLabels) ->
		for ghLabel in ghLabels
			bgColor = '#' + ghLabel.color
			@addLabel
				name: ghLabel.name
				url: @computeUrl(ghLabel)
				bgColor: bgColor
				textColor: @computeTextColor(bgColor) # not provided by the API :(

	###
	Adds a label to the internal data structures
	###
	addLabel: (label) ->
		@items.push(label)
		@hash[label.name] = label

	###
	Given a label from the Github API, computes the URL, a search query on the issue tracker
	###
	computeUrl: (ghLabel) ->
		'https://github.com/' + @repoConfig.user.name + '/' + @repoConfig.name + '/issues?q=' +
			encodeURIComponent(
				'is:open is:issue label:' +
				if ghLabel.name.match(/\s/) # any whitespace?
					'"' + ghLabel.name + '"'
				else
					ghLabel.name
			)

	###
	Given a CSS string background color, compute a contrasting CSS color
	###
	computeTextColor: (bgColor) ->
		color = new Color(bgColor)
		if color.luminosity() < 0.45 # dark background? (what gh seems to use)
			'#fff' # light text
		else
			'#000' # dark text

	###
	For serialization
	###
	getRaw: ->
		@items

	###
	For deserialization
	###
	setRaw: (items) ->
		for label in items
			@addLabel(label)

	###
	Retrieves a normalized label object, given a string name
	###
	getByName: (labelName) ->
		@hash[labelName]

	###
	Utility for getting an array of normalized label objects for an ISSUE
	###
	getForIssue: (issue) ->
		for labelName in issue.labelNames
			@hash[labelName]

# make public
module.exports = LabelCollection
