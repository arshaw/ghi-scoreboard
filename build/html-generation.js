
exports.generate = function(configData, issuesData) {
	return '<html>' +
		'<head>\n' + JSON.stringify(configData, null, '\t') + '\n</head>' +
		'<body>\n' + JSON.stringify(issuesData, null, '\t') + '\n</body>' +
	'</html>';
};
