<cfcomponent extends="Controller" output="false">

	<cffunction name="init">
		<cfset filters( through="isLoggedIn", except="track,login,security,install" ) />
	</cffunction>
	
	
	<cffunction name="emails">
	
		<cfset emails = trackEmail_getEmails() />
		
	</cffunction>


	<cffunction name="install">
		
		<cfset var loc = {} />
		
		<cfset installSuccess = true />
			
		<!--- <cftry> --->
			<cfset loc.tableCheck = trackEmail_checkTables() />
				
			<cfif NOT loc.tableCheck.emails
					OR NOT loc.tableCheck.links
					OR NOT loc.tableCheck.sent
					OR NOT loc.tableCheck.views>
					
				<cfset installSuccess = false />
					
			</cfif>
				
			<cfset flashInsert( alertEmail="Email table exists: #loc.tableCheck.emails#" ) />
			<cfset flashInsert( alertLink="Link table exists: #loc.tableCheck.links#" ) />
			<cfset flashInsert( alertSent="Sent table exists: #loc.tableCheck.sent#" ) />
			<cfset flashInsert( alertViews="View table exists: #loc.tableCheck.views#" ) />
				
			<!--- <cfcatch>
				<cfset installSuccess = false />
			</cfcatch>
		</cftry> --->
			
		<cfif installSuccess>
			<cfset flashInsert( success="Install successfull." ) />
		<cfelse>
			<cfset flashInsert( error="Install unsuccessfull." ) />
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="isLoggedIn">
	
		<cfif NOT StructKeyExists( cookie, "trackemail_admin" )>
			OR cookie.trackemail_admin neq "slkjfoweriuj9tslkbns">
			
			<cfset redirectTo( action="login" ) />
		
		</cfif>
	
	</cffunction>
	
	
	<cffunction name="login">
		
		<cfset var loc = {} />
		
		<cfif StructKeyExists( params, "installsuccess" )>
			<cfset installSuccess = true />
			
			<cftry>
				<cfset loc.checkEmailTable = _checkEmailTable() />
				<cfset loc.checkLinkTable = _checkLinkTable() />
				<cfset loc.checkSentTable = _checkSentTable() />
				<cfset loc.checkViewTable = _checkViewTable() />
				
				<cfif NOT loc.checkEmailTable
						OR NOT loc.checkLinkTable
						OR NOT loc.checkSentTable
						OR NOT loc.checkViewTable>
					
					<cfset installSuccess = false />
					
				</cfif>
				
				<cfset flashInsert( alert="Email table exists: #loc.checkEmailTable#" ) />
				<cfset flashInsert( alert="Link table exists: #loc.checkLinkTable#" ) />
				<cfset flashInsert( alert="Sent table exists: #loc.checkSentTable#" ) />
				<cfset flashInsert( alert="View table exists: #loc.checkViewTable#" ) />
				
				<cfcatch>
					<cfset installSuccess = false />
				</cfcatch>
			</cftry>
			
			<cfif installSuccess>
				<cfset flashInsert( success="Install successfull." ) />
			<cfelse>
				<cfset flashInsert( error="Install unsuccessfull." ) />
			</cfif>
			
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="report">
	
		<cfif NOT StructKeyExists( params, "startDate" )>
			<cfset params.startDate = DateAdd( 'm', -1, now() ) />
		</cfif>
		
		<cfif NOT StructKeyExists( params, "endDate" )>
			<cfset params.endDate = now() />
		</cfif>
	
		<cfset report = trackEmail_getEmailReport( 
			emailid=params.emailid, 
			startDate=params.startDate, 
			endDate=params.endDate 
		) />
	
	</cffunction>
	
	
	<cffunction name="security">
	
		<cfif StructKeyExists( form, "password" )
			AND Hash( form.password ) eq "5F4DCC3B5AA765D61D8327DEB882CF99">
			
			<cfset cookie.trackemail_admin = "slkjfoweriuj9tslkbns" />
			<cfset redirectTo( action="emails" ) />
				
		<cfelse>
		
			<cfset flashInsert( error="Invalid password" ) />
			<cfset renderPage( action="login" ) />
			
		</cfif>
	
	</cffunction>
	
	
	<cffunction name="track">
	
		<!---
		Log a email view or a click of a link in the email
		
		Parameters:
		
		url.e (required) - the unique sent email id
		url.t - stands for type, tracking a l=link or v=view
		url.u - the link to forward the user too, required if type is link
		--->
		
		<cfparam name="url.t" default="v" />
			
		<cfif StructKeyExists( url, "e" )>
				
			<cfif url.t eq "l" AND StructKeyExists( url, "u" )>
					
				<!--- log link and forward on to link destination --->
				<cfset trackEmail_logLink( sentId=url.e, link=url.u ) />
				<cflocation url="#url.u#" addtoken="false" />
					
			<cfelseif url.t eq "v">
				
				<cfset trackEmail_logView( sentId=url.e ) />
					
			</cfif>
			
		</cfif>
	
	</cffunction>
	
</cfcomponent>