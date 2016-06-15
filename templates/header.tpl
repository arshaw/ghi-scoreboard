
<nav class="navbar navbar-inverse navbar-static-top">
	<div class="container-fluid">

		<div class="navbar-header">
			{{#logo}}
				<span class="navbar-brand">
					<img src="{{url}}"
						{{#width}}width="{{.}}"{{/width}}
						{{#height}}height="{{.}}"{{/height}}
						/>
				</span>
			{{/logo}}
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse"
				data-target="#navbar-collapse-1"
				aria-expanded="false"
				>
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
		</div>

		<div class="collapse navbar-collapse" id="navbar-collapse-1">

			<ul class="nav navbar-nav">
				{{#repos}}
					<li {{#isActive}}class="active"{{/isActive}}>
						<a href='#{{name}}'>{{name}}</a>
					</li>
				{{/repos}}
			</ul>

			<p class="navbar-text navbar-right">
				Created with
				<a href="https://github.com/arshaw/ghi-dashboard" target="_blank" class="navbar-link">
					ghi-scoreboard
				</a>
			</p>

		</div>

	</div>
</nav>
