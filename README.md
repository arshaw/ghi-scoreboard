
## Auth Config

If you plan to use any of the aggregation functionality, allowing the backend `./bin/aggregate` script to execute, you'll need to set up authentication to Github's API.

Create a file at `./conf/auth.js` with the given format:

```js
module.exports = {
	username: 'arshaw', // github username
	accessToken: 'asdfasdfasdfasdf' // personal access token
};
```

[How to create a personal access token &raquo;](https://github.com/blog/1509-personal-api-tokens)


## Main Config


All other customization settings live in `./conf/config.js`, which has the following format:

```js
module.exports = {
	repo: 'fullcalendar/fullcalendar', // repo path

	// other settings...
};
```


### Specifying a Repo


#### repo

Contains a string indicating the path to a Github repo. For example, the string `'fullcalendar/fullcalendar'` leads the repo https://github.com/fullcalendar/fullcalendar


#### repos

More than one repo can be specified. This will affect the top bar of the UI, allowing the user to switch between repos. Can be an array of repo strings:

```js
repos: [
	'fullcalendar/fullcalendar',
	'fullcalendar/fullcalendar-scheduler'
]
```

If you'd like to specify settings on a per-repo basis:

```js
repos: [
	{
		user: 'fullcalendar',
		name: 'fullcalendar',
		// put other settings here...
	},
	{
		user: 'fullcalendar',
		name: 'fullcalendar-scheduler'
		// put other settings here...
	}
]
```

Nearly all of the following config settings can be specified on a per-repo basis.


### Aggregating Data


By default, the browser fetches Github Issue every time the scoreboard is loaded. If you have many issues, you may want to pre-fetch them on your server-side first, so the client renders faster.

Also, many of the issue stats you wish to display require pre-fetching a processing on the server-side. Please see notes in the [Standard Column Types](#standard-column-types) documentation.


#### Flags

To pre-fetch data, certain flags must be toggled on. The `./bin/aggregate` script will look at these flags to determine what to fetch:


##### aggregateIssues

`Boolean`. Whether to fetch and store stripped-down issue data on the server-side for faster scoreboard pageload. Not required. Recommended if your repo has more than 200 open issues.


##### aggregateReactions

`Boolean`. Whether to fetch and process thumbs-up reaction data. Required by many [Standard Column Types](#standard-column-types).


##### aggregateComments

`Boolean`. Whether to fetch and process comment data. Required by many [Standard Column Types](#standard-column-types).


#### Filters

Hooks are available to store additional data received by the pre-fetched Github API data:


##### processIssue

`function(issue, ghIssue)`. Given the raw object returned by the Github API, you may compute and assign additional properties to the resulting `issue` object.


##### processComments

`function(issue, ghComments)`. Given the raw list of Github API comments for a particular issue, you may compute and assign additional properties to the resulting `issue` object.


##### processReactions

`function(issue, ghReactions)`. Given the raw list of Github API reactions for a particular issue, you may compute and assign additional properties to the resulting `issue` object.


#### Excluding Users

If you'd like exclude users from being considered commenters:

```js
excludeUsers: [ 'GithubIssueImporter' ]
```


### Table Columns

The scoreboard UI displays one or more tables. You are able to customize the columns in the table via the `columns` settings.

The default `columns` configuration is this:

```js
columns: [ 'number', 'titleAndLabels', 'plusReactions' ]
```

Entries within the array can be simple strings, which indicate a standard column type, or they can be complex object, which indicate [custom column types](#custom-column-types).


#### Standard Column Types

The following column types are built-in and ready to use:


##### number

The number of the issue, like "#123", rendered as a link.


##### title

The title of the issue.


##### titleAndLabels

The title of the issue in addition to its labels. If the issue table lives within a `label` layout, the current layout's label will be excluded.


##### plusReactions

Number of users who have given a :+1: reaction to the issue. Only reactions on the topmost issue description count.


##### plusComments

Requires `aggregateComments:true`

Number of *unique* users who have written a comment consisting solely of "+1" or :+1:.


##### plusScore

Requires `aggregateReactions:true` and `aggregateComments:true`

Number of *unique* users who have either given a plusReaction or a plusComment. Weighted by `plusReactionWeight` and `plusCommentWeight`.


##### participants

Requires `aggregateComments:true`

Number of *unique* users who have written comments.


##### participantScore

Requires `aggregateComments:true`

Number of *unique* users who have written comments. Comments that consist solely of "+1" or :+1: will be weighted by `plusCommentWeight`.


##### score 

Requires `aggregateReactions:true` and `aggregateComments:true`

Number of *unique* users who have either written comments, given plusReactions, or given plusComments. Will be weighted by `participantWeight`, `plusReactionWeight`, or `plusCommentWeight`.


#### Custom Columns

Custom columns that programatically yield values can be defined. The format is as follows:

```js
columns: [
	{
		name: 'mycolumn',
		label: 'My Column',
		value: function(issue) {
			retun issue.customField1 + issue.customField2;
		}
	}
]
```

Custom column definitions can contain the following keys:


##### name

Unique string name for the column. Important if this is a `sortBy` column.


##### label

Text heading above the column data.


##### value

`function(issue)`. Programmatically generates a value. Given a barebones `issue` object that has tacked-on fields from `processIssue`, `processComment`, or `processReactions`. Must return a value to be used.


##### field

`string`. The name of a property to query on the internal `issue` object, which can have tacked-on properties from `processIssue`, `processComment`, or `processReactions`.


##### icon

`string`. Icon to display in the table heading. A value like `'star'` will result in the [Glyphicon](http://glyphicons.com/) `glyphicon-star`.


##### labelCaption

`String`. A caption string to show on mouseover of the label.


##### caption

`function(issue)`. Returns a label string to show on mouseover of the cell.


### Column Sorting

#### sortBy

`string`. Determines the ordering of rows within each table. Is a column name, a barebones `issue` property name, or a custom property from one of the `process*` functions.

Defaults to the rightmost column.


### Weights

As mentioned in a number of the [standard column types](#standard-column-types), scores can be weighted by the following floating-point values, all of which default to `1.0`:

- **plusCommentWeight**
- **plusReactionWeight**
- **participantWeight**

Many of the standard column types are compound weighted values, unique by user. If there is a collision, the value with the highest weight will take precedence.


### Number Display


#### formatCellNumber

`function(number)`. Affects how all numbers are displayed within the table. Given a number, should return a string.


### Layout of the UI

By default, all issues will be displayed in one big table.

However, issue tables can be organized into various groupings and UI paradigms. These UI components can be nested recursively.


#### layout

A simple array of other UI components. They stack horizontally. Example:

```js
layout: [ // array
	{ label: 'Accepted' }, // nested UI
	{ label: 'Discussing' } // nested UI
]
```


#### splitpane

Like the `layout` setting, but arranged side-by-side. Example:

```js
splitpane: [
	// on left
	{
		width: '60%',
		label: 'Accepted' // nested UI
	},
	// on right
	{
		width: '40%',
		label: 'Discussing' // nested UI
	}
]
```

The `width` properties are optional and will default to `50%`.


#### tabs

Example:

```js
tabs: [
	{
		title: 'Features',
		label: 'type-feature' // nested UI
	},
	{
		title: 'Bugs',
		label: 'type-bug' // nested UI
	}
]
```

#### label

Will display a table of issues with a certain label. Will have a heading above the table indicating the label.


### logo

A branding image that will be placed at the top-left of the UI. Takes the format:

```js
logo: {
	url: "http://fullcalendar.io/images/logo.svg", // external image URL
	width: 29,
	height: 24
}
```

Can only be specified globally. It cannot be specified per-repo.
