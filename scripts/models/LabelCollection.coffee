
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
			label = new Label(@repoConfig)
			label.parseGithub(ghLabel)
			@addLabel(label)
		return

	###
	For deserialization
	###
	setRaw: (rawLabels) ->
		for rawLabel in rawLabels
			label = new Label(@repoConfig)
			label.setRaw(rawLabel)
			@addLabel(label)
		return

	###
	For serialization
	###
	getRaw: ->
		for label in @items # return value
			label.getRaw()

	###
	Adds a proper Label object to the internal data structures
	###
	addLabel: (label) ->
		@items.push(label)
		@hash[label.name] = label

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

###
Class for an INDIVIDUAL label
###
class Label

	repoConfig: null
	name: null
	rawColor: null
	_textColor: null # internal only

	###
	Accepts a RepoConfig
	###
	constructor: (@repoConfig) ->

	###
	Process a single label from the Github API
	###
	parseGithub: (ghLabel) ->
		@name = ghLabel.name
		@rawColor = ghLabel.color

	###
	For deserialization
	###
	setRaw: (rawObj) ->
		@name = rawObj.name
		@rawColor = rawObj.color

	###
	For serialization
	###
	getRaw: ->
		{ @name, color: @rawColor }

	###
	Compute the label's URL
	###
	getUrl: ->
		'https://github.com/' + @repoConfig.user.name + '/' + @repoConfig.name + '/issues?q=' +
			encodeURIComponent(
				'is:open is:issue label:' +
				if @name.match(/\s/) # any whitespace?
					'"' + @name + '"'
				else
					@name
			)

	###
	Get a CSS color for the background
	###
	getBgColor: ->
		'#' + @rawColor

	###
	Get a CSS color for the text
	###
	getTextColor: ->
		@_textColor ?= @computeTextColor()

	###
	Given a CSS string background color, compute a contrasting CSS color
	###
	computeTextColor: ->
		color = new Color('#' + @rawColor)
		if color.luminosity() < 0.45 # dark background? (what gh seems to use)
			'#fff' # light text
		else
			'#000' # dark text

# make public
module.exports = LabelCollection
