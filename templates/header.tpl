
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
				<li>
					<a href="{{repo.url}}" target="_blank">
						{{user.name}} / {{repo.name}}
					</a>
				</li>
				<!--
				<li class="dropdown">
					<a class="dropdown-toggle"
						data-toggle="dropdown"
						role="button"
						aria-haspopup="true"
						aria-expanded="false"
						>
						<span class="hidden-md hidden-lg">change repo</span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu dropdown-menu-right">
						<li><a href="https://github.com/fullcalendar/fullcalendar-scheduler">fullcalendar / fullcalendar-scheduler</a></li>
					</ul>
				</li>
				-->
			</ul>

			<p class="navbar-text navbar-right" style="margin-right:0">
				Created with
				<a href="#" class="navbar-link">ghi-dashboard</a>
			</p>

		</div>

	</div>
</nav>
