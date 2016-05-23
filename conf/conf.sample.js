/*
There needs to be a script similar to this named "conf.js"
in this same directory.
*/
module.exports = {

	cacheIssues: true,
	cacheDiscussions: true,

	displayValue: function(val) {
		if (val && val < 1) {
			return val.toFixed(1);
		}
		return Math.round(val);
	},

	repos: [
		{
			user: 'fullcalendar',
			name: 'fullcalendar',

			parseIssue: function(issue, ghIssue) {
				// match "Imported with **4** stars"
				var match = ghIssue.body.match(/Imported with \**(\d+)\** star/);
				issue.legacyStars = match ? parseInt(match[1], 10) : 0;
			},

			tabs: [
				{
					title: 'Features',
					labels: [
						'Status-Accepted3',
						'Status-Accepted2',
						'Status-Accepted1',
						'Status-Accepted0',
						'Status-Discussing'
					]
				},
				{
					title: 'Bugs',
					labels: [
						'Status-Confirmed',
						'Status-Reproducing'
					]
				}
			],

			columns: [
				'comments',
				{
					name: 'stars',
					icon: 'star',
					caption: 'stars from google code',
					prop: 'legacyStars'
				},
				'commentPluses',
				'pluses',
				{
					name: 'score',
					icon: 'certificate',
					caption: 'computed score',
					value: function(issue) {
						return issue.legacyStars * 0.5 +
							issue.commentPluses * 0.5 +
							issue.pluses;
					}
				}
			]
		},
		{
			user: 'fullcalendar',
			name: 'fullcalendar-scheduler',

			tabs: [
				{
					title: 'Features',
					labels: [
						'Status-Accepted1',
						'Status-Accepted0',
						'Status-Discussing'
					]
				},
				{
					title: 'Bugs',
					labels: [
						'Status-Confirmed',
						'Status-Reproducing'
					]
				}
			],

			columns: [
				'comments',
				'participants',
				'commentPluses',
				'pluses',
				{
					name: 'score',
					icon: 'certificate',
					caption: 'computed score',
					value: function(issue) {
						return issue.participants * 0.5 +
							issue.commentPluses * 0.5 +
							issue.pluses;
					}
				}
			]
		}
	]
};
