
var string = require('lodash/string');
var cheerio = require('cheerio');

exports.parseHtml = function(html) {
	var $ = cheerio.load(html);

	return {
		thumbsUpCommentUsernames: queryThumbsUpCommentUsernames($),
		plusOneCommentUsernames: queryPlusOneCommentUsernames($),
		thumbsUpReactions: queryThumbsUpReactions($),
		legacyStars: queryLegacyStars($)
	};
};

function queryThumbsUpCommentUsernames($) {
	return $('.comment-body > p:first-child > img.emoji[title=":+1:"]:first-child')
		.map(function(i, img) {
			return string.trim(
				$(img).closest('.comment').find('.timeline-comment-header .author').text()
			);
		})
		.get();
}

function queryPlusOneCommentUsernames($) {
	return $('.comment-body > p:first-child:contains("+1")')
		.filter(function(i, p) {
			var $p = $(p);
			var text = string.trim($p.text());
			return text.match(/^\+1/);
		})
		.map(function(i, p) {
			return string.trim($(p).closest('.comment').find('.timeline-comment-header .author').text());
		})
		.get();
}

function queryThumbsUpReactions($) {
	var usernames = [];
	var total = 0;
	var $button = $('.js-discussion > .timeline-comment-wrapper').first()
		.find('.comment-reactions-options button > g-emoji[alias="+1"]')
			.closest('button');

	if ($button.length) {
		var totalText = $button.text();
		var totalMatch = totalText.match(/\d+/);
		if (totalMatch) {
			total = parseInt(totalMatch[0], 10);
			var usernamesText = $button.attr('aria-label') || '';
			usernames = usernamesText.replace(/(, and \d+ more)? reacted with thumbs up emoji$/, '')
				.split(/,(?: and)?\s*/);
		}
	}

	return {
		usernames: usernames,
		anonTotal: total - usernames.length
	}
}

function queryLegacyStars($) {
	var bodyText = $('.js-discussion > .timeline-comment-wrapper').first()
		.find('.comment-body')
			.text();
	var match = bodyText.match(/Imported with (\d+) star/);
	if (match) {
		return parseInt(match[1], 10);
	}
	return 0;
}
