<cfoutput>
<cfif flashKeyExists( "error" )>
	#flashMessages( key="error" )#
</cfif>


<p>Log in to view the reports, the default password is <em>password</em></p>
	
<form method="post" action="#UrlFor( action='security' )#">
	<p>
		<div>Password</div>
		<div><input type="password" name="password" /></div>
	</p>
		
	<p>
		<button>Log in</button>
	</p>
</form>
</cfoutput>