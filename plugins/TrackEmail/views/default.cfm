<h2>Track email plugin</h2>

<h3>Report</h3>

<cfinclude template="_security.cfm" />

<cfif adminAuthorized>
	<cfoutput>
	<p>#linkTo( controller="wheels", action="wheels", params="view=plugins&name=trackemail&page=emails", text="View the emails sent." )#</p>
	</cfoutput>
</cfif>

<h3>How to use</h3>

<p>To track emails all you have to do is add <code class="inline">track=true</code> to the arguments of your sendEmail call.</p>

<h4>Example usage</h4>

<code class="block">
	sendEmail(<br />
		&nbsp;&nbsp;&nbsp;&nbsp;from="john.doe@email.com",<br />
		&nbsp;&nbsp;&nbsp;&nbsp;to="jane.doe@email.com",<br />
		&nbsp;&nbsp;&nbsp;&nbsp;subject="Dear Jane",<br />
		&nbsp;&nbsp;&nbsp;&nbsp;template=genericemailtemplate,<br />
		&nbsp;&nbsp;&nbsp;&nbsp;track=true<br />
	)
</code>

<p>The <code class="inline">track</code> argument is <code class="inline">false</code> by default.</p>