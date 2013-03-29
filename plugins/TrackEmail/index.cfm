<cfparam name="params.page" default="" />

<cfif params.page eq "report">
	
	<cfinclude template="views/report.cfm" />
	
<cfelseif params.page eq "emails">

	<cfinclude template="views/emails.cfm" />
	
<cfelseif params.page eq "track">

	<cfinclude template="views/track.cfm" />
	
<cfelse>

	<cfinclude template="views/default.cfm" />
	
</cfif>

