
# Github Issues Scoreboard

Display your Github repo's issues by demand (:+1:) with an attractive configurable index page.

Provides robust ranking utilities. For example, you can sort issues by a combination of reactions, participants, and comments that contain "+1".

Examples:

- http://fullcalendar.io/issues/ ([see config](./conf/sample.fullcalendar.conf.js))
- http://arshaw.com/moment-scoreboard ([see config](./conf/sample.moment.conf.js))


## Installation

First, clone the ghi-scoreboard repo:

```
git clone https://github.com/arshaw/ghi-scoreboard
cd ghi-scoreboard
npm install
```

Then, configure your [Main Config](#main-config) with information about your repo and what you want your scoreboard to look like.

If you plan to do [comment/reaction aggregation](#aggregating-data), also configure your [Auth Config](#auth-config).

Then, build your scoreboard:

```
gulp
```

The `./out/` directory will be populated with all the necessary web files. Open `./out/index.html` in a web browser. Make sure this is done from a web server and not the `file:///` protocol.

If you'd like to make your scoreboard public, make the `./out/` directory the web root.

If you want to do [comment/reaction aggregation](#aggregating-data), run the following script:

```
./bin/aggregate
```

If you want this to periodically update, call the `aggregate` script from a cron job.


## Auth Config

If you plan to use any of the aggregation functionality, allowing the backend `./bin/aggregate` script to execute, you'll need to set up authentication to Github's API.

Create a file at `./conf/auth.js` with the given format:

```js
module.exports = {
	username: 'arshaw', // github username
	accessToken: 'xxx' // personal access token
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

Also, many of the issue stats you wish to display require pre-fetching a processing on the server-side. Please see notes in the [Standard Columns](#standard-columns) documentation.


#### Flags

To pre-fetch data, certain flags must be toggled on. The `./bin/aggregate` script will look at these flags to determine what to fetch:


##### aggregateIssues

`Boolean`. Whether to fetch and store stripped-down issue data on the server-side for faster scoreboard pageload. Not required. Recommended if your repo has more than 200 open issues.


##### aggregateComments

`Boolean`. Whether to fetch and process comment data. Required by many [Standard Columns](#standard-columns).


##### aggregateReactions

`Boolean`. Whether to fetch and process thumbs-up reaction data. Required by many [Standard Columns](#standard-columns).


#### Filters

Hooks are available to store additional data received by the pre-fetched Github API data:


##### parseIssue

`function(ghIssue, issue)`. Given the raw object returned by the Github API, you may compute and assign additional properties to the given `issue` object.


##### parseComments

`function(ghComments, issue)`. Given the raw list of Github API comments for a particular issue, you may compute and assign additional properties to the given `issue` object.


##### parseReactions

`function(ghReactions, issue)`. Given the raw list of Github API reactions for a particular issue, you may compute and assign additional properties to the given `issue` object.


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

Entries within the array can be simple strings, which indicate a standard column type, or they can be complex object, which indicate [Custom Columns](#custom-columns).


#### Standard Columns

The following column types are built-in and ready to use:


##### number

The number of the issue, like "#123", rendered as a link.


##### title

The title of the issue.


##### titleAndLabels

The title of the issue in addition to its labels. If the issue table lives within a `label` layout, the current layout's label will be excluded.


##### plusReactions

Number of unique users who have given a :+1: reaction to the issue. Only reactions on the topmost issue description count.


##### plusComments

Requires `aggregateComments:true`

Number of *unique* users who have written a comment with a "+1" or :+1: in it.


##### plusScore

Requires `aggregateComments:true` and `aggregateReactions:true`

Number of *unique* users who have either given a plusComment or a plusReaction. Weighted by `plusCommentWeight` and `plusReactionWeight`.


##### participants

Requires `aggregateComments:true`

Number of *unique* users who have written comments.


##### participantScore

Requires `aggregateComments:true`

Number of *unique* users who have written comments. Comments that consist solely of "+1" or :+1: will be weighted by `plusCommentWeight`.


##### score 

Requires `aggregateComments:true` and `aggregateReactions:true`

Number of *unique* users who have either written comments, given plusComments, or given plusReactions. Will be weighted by `participantWeight`, `plusCommentWeight`, and `plusReactionWeight`.


#### Custom Columns

Custom columns that programatically yield values can be defined. The format is as follows:

```js
columns: [
	{
		name: 'mycolumn',
		title: 'My Column',
		value: function(issue) {
			retun issue.customField1 + issue.customField2;
		}
	}
]
```

Custom column definitions can contain the following keys:


##### name

Unique string name for the column. Important if this is a `sortBy` column.


##### title

Text heading above the column data.


##### value

`function(issue)`. Programmatically generates a value. Given a barebones `issue` object that has tacked-on fields from `parseIssue`, `parseComments`, or `parseReactions`. Must return a value to be used.


##### icon

`string`. Icon to display in the table heading. A value like `'star'` will result in the [Glyphicon](http://glyphicons.com/) `glyphicon-star`.


### Column Sorting

#### sortBy

`string`. Determines the ordering of rows within each table. Is a column name, a barebones `issue` property name, or a custom property from one of the `parse*` functions.

Defaults to the rightmost column.


### Weights

As mentioned in a number of the [Standard Columns](#standard-columns), scores can be weighted by the following floating-point values, all of which default to `1.0`:

- **participantWeight**
- **plusCommentWeight**
- **plusReactionWeight**

Many of the standard column types are compound weighted values, unique by user. If there is a collision, the value with the highest weight will take precedence.


### Number Display


#### formatNumber

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
