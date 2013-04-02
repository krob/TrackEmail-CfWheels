<!--- Display a list of emails that are being tracked --->

<cfinclude template="_security.cfm" />

<cfif NOT adminAuthorized>
	<cfabort />
</cfif>	
	
<cfsilent>
	<cfset emails = getEmails() />
</cfsilent>

<h2>Emails Sent</h2>

<p>Click on an email to see a report.</p>

<cfoutput query="emails">
	<p>#linkTo( controller="wheels", action="wheels", params="view=plugins&name=trackemail&page=report&emailid=#id#", text=subject )# sent #numberSent# time(s)</p>
</cfoutput>