<!--- Display a list of emails that are being tracked --->

<h2>Emails Sent</h2>

<p>Click on an email to see a report.</p>

<cfoutput query="emails">
	<p>#linkTo( action="report", params="emailid=#id#", text=subject )# sent #numberSent# time(s)</p>
</cfoutput>