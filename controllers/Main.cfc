<cfcomponent extends="Controller" output="false">

	<cffunction name="test">
	
		<cfset sendEmail( from="krobertson@nc4ea.org", to="krobertson@nc4ea.org", subject="test", template="email", track=true ) />
	
		<cfset renderText( "Success" ) />

	</cffunction>
	
</cfcomponent>