module.exports = {

	aggregateIssues: true,
	aggregateComments: true,
	aggregateReactions: true,

	initialPageTitle: 'FullCalendar Project',
	metaDescription: 'Issue scoreboard for the FullCalendar Project',

	excludeUsers: [ 'arshaw' ], // did all the importing

	logo: {
		url: 'https://fullcalendar.io/assets-more/images/logo-64x64.png',
		width: 24,
		height: 24
	},

	tabs: [
		{
			title: 'Features',
			splitpane: [
				{ label: 'Accepted', width: '50%' },
				{ label: 'Discussing', width: '50%' }
			]
		},
		{
			title: 'Bugs',
			splitpane: [
				{ label: 'Confirmed', width: '50%' },
				{ label: 'Reproducing', width: '50%' }
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
		}
	]
};
