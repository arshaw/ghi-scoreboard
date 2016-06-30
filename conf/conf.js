module.exports = {

	aggregateIssues: true,
	aggregateComments: true,
	aggregateReactions: true,

	initialPageTitle: 'FullCalendar Project',

	excludeUsers: [ 'arshaw' ], // did all the importing

	logo: {
		url: "http://fullcalendar.io/images/logo.svg",
		width: 29,
		height: 24
	},

	tabs: [
		{
			title: 'Features',
			splitpane: [
				{ label: 'Accepted', width: '60%' },
				{ label: 'Discussing', width: '40%' }
			]
		},
		{
			title: 'Bugs',
			splitpane: [
				{ label: 'Confirmed', width: '60%' },
				{ label: 'Reproducing', width: '40%' }
			]
		},
	],

	participantWeight: 0.8,
	plusCommentWeight: 0.9,

	repos: [
		{
			user: 'fullcalendar',
			name: 'fullcalendar',

			parseIssue: function(ghIssue, issue) {
				// match "Imported with **4** stars"
				var match = ghIssue.body.match(/Imported with \**(\d+)\** star/);
				issue.legacyStars = match ? parseInt(match[1], 10) : 0;
			},

			columns: [
				{
					name: 'score',
					title: 'Score',
					caption: 'computed score',
					value: function(issue) {
						return issue.legacyStars * 0.75 +
							Math.max(
								issue.legacyStars * 0.25,
								issue.score
							);
					}
				},
				'titleAndLabels'
			]
		},
		{
			user: 'fullcalendar',
			name: 'fullcalendar-scheduler',
			columns: [
				'score',
				'titleAndLabels'
			]
		}
	]
};
