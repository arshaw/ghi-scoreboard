
<table class="table table-hover table-condensed issue-table">
	<thead>
		<tr>
			<th colspan="2">
				Issues
				<span class="badge">{{count}}</span>
			</th>
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
		</tr>
	</thead>
	<tbody>
		{{#rows}}
			<tr>
				<td class='issue-number'>
					<a href="{{url}}" target="_blank">#{{number}}</a>
				</td>
				<td>
					{{title}}
					{{#labels}}
						<a href="{{url}}" target="_blank" class="label"
							style="background-color:{{bgColor}};color:{{textColor}}"
						>{{name}}</a>
					{{/labels}}
				</td>
				{{#cells}}
					<td class="issue-value{{#isSorted}} issue-sorted{{/isSorted}}">
						{{value}}
					</td>
				{{/cells}}
			</tr>
		{{/rows}}
	</tbody>
</table>
