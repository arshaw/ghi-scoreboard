
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
			<tr>
				{{#cells}}
					<td class="issue-value{{#isSorted}} issue-sorted{{/isSorted}}">
						{{value}}
					</td>
				{{/cells}}
				<td>
					{{title}}
					<span class="issue-labels">
						{{#labels}}
							<a href="{{url}}" target="_blank" class="label"
								style="background-color:{{bgColor}};color:{{textColor}}"
							>{{name}}</a>
						{{/labels}}
					</span>
				</td>
			</tr>
		{{/rows}}
	</tbody>
</table>
