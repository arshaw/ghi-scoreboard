
<table class="table table-hover table-condensed issue-table">
	<thead>
		<tr>
			{{#columns}}
				<th class="issue-value{{#isSorted}} issue-sorted{{/isSorted}}">
					{{#icon}}
						<span class="glyphicon glyphicon-{{.}}"
							{{#if ../caption}}
								title="{{../caption}}"
							{{/if}}
							data-toggle="tooltip"
							data-placement="bottom"
						>
						</span>
					{{/icon}}
					{{title}}
				</th>
			{{/columns}}
			<th colspan="2">
			</th>
		</tr>
	</thead>
	<tbody>
		{{#rows}}
			<tr data-url="{{url}}" title="#{{number}}">
				{{#cells}}
					<td class="issue-value{{#isSorted}} issue-sorted{{/isSorted}}">
						{{value}}
					</td>
				{{/cells}}
				<td>
					{{title}}
					<span class="issue-labels">
						{{#labels}}
							<a href="{{getUrl}}" target="_blank" class="label"
								style="background-color:{{getBgColor}};color:{{getTextColor}}"
							>{{name}}</a>
						{{/labels}}
					</span>
				</td>
			</tr>
		{{/rows}}
	</tbody>
</table>
