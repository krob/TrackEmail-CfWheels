TrackEmail-CfWheels
===================

A cfwheels plugin that adds the ability to track email views and clicks

<h3>How to install</h3>

<p>After cfwheels extracts the content of the zip file do the following.</p>

<ul>
	<li>Copy the <em>TrackEmails.cfc</em> file from <em>/plugins/TrackEmail/controllers/</em> to <em>/controllers/</em>.</li>
	<li>Copy the <em>trackemails</em> folder from <em>/plugins/TrackEmail/views/</em> to <em>/views/</em>.</li>
	<li>Go to index.cfm?controller=trackemails&action=install to try to create tables. If it fails there is ms sql server script to create the tables.</li>
</ul>

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

<h3>Report Section</h3>

View reports for each unique email sent. A unique email is determined by site it is sent from and subject line. 

Reports show graphs for emails sent, views, and clicks as well as a graph for each link and how often it was clicked. Reports also show sent, views, and clicks for each recipient.
