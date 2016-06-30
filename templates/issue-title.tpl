{{title}}
{{#if labels}}
	<span class="issue-labels">
		{{#labels}}
			<a href="{{getUrl}}" target="_blank" class="label"
				style="background-color:{{getBgColor}};color:{{getTextColor}}"
			>{{name}}</a>
		{{/labels}}
	</span>
{{/if}}
