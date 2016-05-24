
<nav class="navbar navbar-default navbar-static-top">
	<div class="container-fluid">

		<div class="navbar-header">
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
			<span class="navbar-brand">Top Issues</span>
		</div>

		<div class="collapse navbar-collapse" id="navbar-collapse-1">

			<ul class="nav navbar-nav">
				{{#if otherRepos}}
					<li class="dropdown">
						<a class="dropdown-toggle"
							data-toggle="dropdown"
							role="button"
							aria-haspopup="true"
							aria-expanded="false"
							>
							{{currentRepo.user.name}} / {{currentRepo.name}}
							<span class="caret"></span>
						</a>
						<ul class="dropdown-menu">
							{{#otherRepos}}
								<li>
									<a href="#{{name}}">
										{{user.name}} / {{name}}
									</a>
								</li>
							{{/otherRepos}}
						</ul>
					</li>
					<li>
						<a href="{{currentRepo.url}}" target="_blank">
							<span class="glyphicon glyphicon-share-alt"></span>
						</a>
					</li>
				{{else}}
					<li>
						<a href="{{currentRepo.url}}" target="_blank">
							{{currentRepo.user.name}} / {{currentRepo.name}}
							<span class="glyphicon glyphicon-share-alt"></span>
						</a>
					</li>
				{{/if}}
			</ul>

			<p class="navbar-text navbar-right" style="margin-right:0">
				Created with
				<a href="https://github.com/arshaw/ghi-dashboard" class="navbar-link">ghi-dashboard</a>
			</p>

		</div>

	</div>
</nav>
