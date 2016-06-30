
<table class="table table-hover table-condensed issue-table">
	<thead>
		<tr>
			{{#columns}}
				<th class="issue-{{name}} {{#isSorted}}issue-sorted{{/isSorted}}">
					{{#icon}}
						<span class="glyphicon glyphicon-{{.}}"></span>
					{{/icon}}
					{{title}}
				</th>
			{{/columns}}
		</tr>
	</thead>
	<tbody>
		{{#rows}}
			<tr data-url="{{url}}" title="#{{number}}">
				{{#cells}}
					<td class="issue-{{name}} {{#isSorted}} issue-sorted{{/isSorted}}">
						{{{valueHtml}}}
					</td>
				{{/cells}}
			</tr>
		{{/rows}}
	</tbody>
</table>
