<cfoutput>
<h2>How to install</h2>

<p>After cfwheels extracts the content of the zip file do the following.</p>

<ul>
	<li>Copy the <em>TrackEmails.cfc</em> file from <em>/plugins/TrackEmail/controllers/</em> to <em>/controllers/</em>.</li>
	<li>Copy the <em>trackemails</em> folder from <em>/plugins/TrackEmail/views/</em> to <em>/views/</em>.</li>
</ul>

<p>#linkTo( controller="trackemails", action="install", text="Check" )# if everything installed correctly.</p>

<h2>How to use</h2>

<p>To track emails all you have to do is add <code class="inline">track=true</code> to the arguments of your sendEmail call.</p>

<h3>Example usage</h3>

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

<h2>Send test email</h2>

<form method="post" action="#urlFor( action='send-test' )#">
	<p>From: <input type="text" name="fromEmailAddress" value="#get( 'errorEmailAddress' )#" /></p>
	
	<p>To: <input type="text" name="toEmailAddress" value="#get( 'errorEmailAddress' )#" /></p>
	
	<p>Subject: <input type="text" name="subject" value="TrackEmail Plugin Test" /></p>
	
	<p><button type="submit">Send</button></p>
</form>

<h2>View Reports</h2>

<p>#linkTo( controller="trackemails", action="emails", text="View the emails sent." )#</p>
</cfoutput>