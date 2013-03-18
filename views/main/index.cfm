
<cfoutput>
<h2>Send test email</h2>

<form method="post" action="#urlFor( action='send-test' )#">
	<p>From: <input type="text" name="fromEmailAddress" value="#get( 'errorEmailAddress' )#" /></p>
	
	<p>To: <input type="text" name="toEmailAddress" value="#get( 'errorEmailAddress' )#" /></p>
	
	<p>Subject: <input type="text" name="subject" value="TrackEmail Plugin Test" /></p>
	
	<p><button type="submit">Send</button></p>
</form>
</cfoutput>