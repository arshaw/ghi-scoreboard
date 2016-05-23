
<ul class="nav nav-tabs" role="tablist">
	{{#tabs}}
		<li role="presentation" {{#isActive}}class="active"{{/isActive}}>
			<a href="#{{name}}" aria-controls="{{name}}" role="tab" data-toggle="tab">
				{{title}}
			</a>
		</li>
	{{/tabs}}
</ul>

<div class="tab-content">
	{{#tabs}}
		<div role="tabpanel" class="tab-pane {{#isActive}}active{{/isActive}}" id="{{name}}">
			{{{content}}}
		</div>
	{{/tabs}}
</div>
