<cfcomponent extends="Controller" output="false">

	<cffunction name="sendTest"
		hint="Send a email for testing track email functionality">
	
		<cfset var loc = {} />

		<cfset sendEmail( 
			from="#params.fromEmailAddress#", 
			to="#params.toEmailAddress#", 
			subject="#params.subject#", 
			template="email", 
			track=true 
		) />
	
		<cfset emailArguments = sendEmail( 
			from="#params.fromEmailAddress#", 
			to="#params.toEmailAddress#", 
			subject="#params.subject#", 
			template="email", 
			track=true,
			$deliver=false
		) />

	</cffunction>
	
</cfcomponent>