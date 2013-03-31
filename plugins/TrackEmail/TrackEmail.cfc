<!---
Adds view and click tracking code to emails, adds functions to log views and clicks

Adds the following process to the sendEmail function
	if track argument passed to sendEmail is true
		Get email id with the same subject line exists for this site
			Add email if doesn't exist
		Insert a sent record for email id and recipient
		Add tracking to email body
		Send email
--->

<cfcomponent output="false" mixin="controller,dispatch">

	<cffunction name="init" 
				returntype="any" 
				access="public" 
				output="false"
				hint="Initialize component">
		
		<cfset this.version = "1.0" />
		
		<cfset _initVars() />
		
		<cfset _createTables() />
		
		<cfreturn this />
		
	</cffunction>
	
	
	<cffunction name="_initVars" 
				returntype="void" 
				access="public" 
				output="false"
				hint="Initialize variables needed by component for tracking">
		
		<cfset this.site = application.applicationName />
		<cfset this.baseUrl = cgi.server_name & application.wheels.webPath />
		<cfset this.dsn = application.wheels.datasourcename />
		
		<cfif getPageContext().getRequest().isSecure()>
			<cfset this.baseUrl = "https://" & this.baseUrl />
		<cfelse>
			<cfset this.baseUrl = "http://" & this.baseUrl />
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="_addTracking" 
				returntype="string" 
				access="public" 
				output="false"
				hint="Replaces links with tracking links and adds tracking image to email">
		
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="The email body that is going to be modified." />
			
		<cfargument 
			name="uuid" 
			type="string" 
			required="true" 
			hint="The uuid for the email that is being sent." />
		
		<cfscript>
		
			var loc = {};
			
			//Set variables to use
			_initVars();
			
			//Add ending slash if doesn't exist
			if ( Right( this.baseUrl, 1 ) != '/' )
			{
				this.baseUrl = this.baseUrl & '/';
			}
			
			//Create the base tracking url
			loc.trackUrl = "#this.baseUrl#index.cfm?controller=wheels&action=wheels&view=plugins&name=trackemail&page=track&e=#arguments.uuid#";
			
			//Replace the links in the email with a tracking link
			loc.content = Replace( arguments.content, '<a href="', '<a href="#loc.trackUrl#&t=l&u=', 'all' );
			loc.content = Replace( loc.content, "<a href='", "<a href='#loc.trackUrl#&t=l&u=", "all" );
			
			//Add a tracking image to the end of the email
			loc.content = loc.content & '<img src="#loc.trackUrl#&t=v" width="0" height="0" style="display:none;" />';
			
			return loc.content;
		</cfscript>
	
	</cffunction>
	
	
	<cffunction name="_checkEmailTable" 
				returntype="boolean" 
				access="private" 
				output="false"
				hint="Check if the email table exists">
		
		<cfset var loc = {} />
		
		<cfset loc.valid = true />
		
		<cftry>
			<cfquery 
				name="loc.checkEmailTable"
				datasource="#this.dsn#">
		
				SELECT TOP 1 id
				
				FROM
					trackemail_emails
			
			</cfquery>
			
			<cfcatch>
				<cfset loc.valid = false />
			</cfcatch>
		</cftry>

		<cfreturn loc.valid />
	
	</cffunction>
	
	
	<cffunction name="_checkLinkTable" 
				returntype="boolean" 
				access="private" 
				output="false"
				hint="Check if the link table exists">
		
		<cfset var loc = {} />
		
		<cfset loc.valid = true />
		
		<cftry>
			<cfquery 
				name="loc.checkLinkTable"
				datasource="#this.dsn#">
		
				SELECT TOP 1 id
				
				FROM
					trackemail_links
			
			</cfquery>
			
			<cfcatch>
				<cfset loc.valid = false />
			</cfcatch>
		</cftry>

		<cfreturn loc.valid />
		
	</cffunction>
	
	
	<cffunction name="_checkSentTable" 
			returntype="boolean" 
			access="private" 
			output="false"
			hint="Check if the sent table exists">
		
		<cfset var loc = {} />
		
		<cfset loc.valid = true />
		
		<cftry>
			<cfquery 
				name="loc.checkSentTable"
				datasource="#this.dsn#">
		
				SELECT TOP 1 id
				
				FROM
					trackemail_sent
			
			</cfquery>
			
			<cfcatch>
				<cfset loc.valid = false />
			</cfcatch>
		</cftry>
		
		<cfreturn loc.valid />
		
	</cffunction>
	
	
	<cffunction name="_checkViewTable" 
				returntype="boolean" 
				access="private" 
				output="false"
				hint="Check if the view table exists">
		
		<cfset var loc = {} />
		
		<cfset loc.valid = true />
		
		<cftry>
			<cfquery 
				name="loc.checkViewTable"
				datasource="#this.dsn#">
		
				SELECT TOP 1 id
				
				FROM
					trackemail_views
			
			</cfquery>
			
			<cfcatch>
				<cfset loc.valid = false />
			</cfcatch>
		</cftry>
		
		<cfreturn loc.valid />
		
	</cffunction>
	
	
	<cffunction name="_createEmailTable" 
				returntype="void" 
				access="private" 
				output="false"
				hint="Create the email table">
		
		<cfset var loc = {} />
		
		<cfquery 
			name="loc.createEmailTable"
			datasource="#this.dsn#">
				
			CREATE TABLE trackemail_emails(
				id int IDENTITY(1,1) NOT NULL,
				site varchar(50) NOT NULL,
				subject varchar(255) NULL,
				body text NOT NULL,
				createdAt datetime NOT NULL,
				CONSTRAINT "pk_trackemail_email-id" PRIMARY KEY (id)
			)
					
		</cfquery>
	
	</cffunction>


	<cffunction name="_createLinkTable" 
				returntype="void" 
				access="private" 
				output="false"
				hint="Create the link table">
		
		<cfset var loc = {} />
		
		<cfquery 
			name="loc.createLinkTable"
			datasource="#this.dsn#">
				
			CREATE TABLE trackemail_links(
				id int IDENTITY(1,1) NOT NULL,
				sentid char(35) NOT NULL,
				link varchar(255) NOT NULL,
				createdAt datetime NOT NULL,
				CONSTRAINT "pk_trackemail_links-id" PRIMARY KEY (id)
			)
					
		</cfquery>
		
	</cffunction>
	
	
	<cffunction name="_createTables" 
				returntype="void" 
				access="private" 
				output="false"
				hint="Create the tables needed for tracking">
		
		<cftry>
			
			<cfif NOT _checkEmailTable()>
				<cfset _createEmailTable() />
			</cfif>
			
			<cfif NOT _checkLinkTable()>
				<cfset _createLinkTable() />
			</cfif>
			
			<cfif NOT _checkSentTable()>
				<cfset _createSentTable() />
			</cfif>
			
			<cfif NOT _checkViewTable()>
				<cfset _createViewTable() />
			</cfif>
			
			<cfcatch>
				<cfthrow message="Error creating tables, you may need to create them manually. See sql in db folder." />
			</cfcatch>
				
		</cftry>
		
	</cffunction>
	
	
	<cffunction name="_createSentTable" 
				returntype="void" 
				access="private" 
				output="false"
				hint="Create the sent table">
		
		<cfset var loc = {} />
		
		<cfquery 
			name="loc.createSentTable" 
			datasource="#this.dsn#">
				
			CREATE TABLE trackemail_sent(
				id char(35) NOT NULL,
				emailid int NOT NULL,
				recipient varchar(255) NOT NULL,
				createdAt datetime NOT NULL,
				CONSTRAINT "pk_trackemail_sent-id" PRIMARY KEY (id)
			)
					
		</cfquery>

	</cffunction>
	
	
	<cffunction name="_createViewTable" 
				returntype="void" 
				access="private" 
				output="false"
				hint="Create the view table">
		
		<cfset var loc = {} />
		
		<cfquery 
			name="loc.createViewTable" 
			datasource="#this.dsn#">
				
			CREATE TABLE trackemail_views(
				id int IDENTITY(1,1) NOT NULL,
				sentid char(35) NOT NULL,
				createdAt datetime NOT NULL,
				CONSTRAINT "pk_trackemail_views-id" PRIMARY KEY (id)
			)
					
		</cfquery>

	</cffunction>
	

	<cffunction name="_emailExists" 
				returntype="any" 
				access="public" 
				output="false"
				hint="Checks if an email exists with this subject line for this site, if does it it returns the email id, if not returns false">
	
		<cfargument 
			name="subject" 
			type="string" 
			default=""
			hint="Subject line of email being sent." />
			
		<cfset var loc = {} />
		
		<cfset _initVars() />
		
		<cfquery 
			name="loc.emailExists" 
			datasource="#this.dsn#">
			
			SELECT TOP 1 
				id
			
			FROM 
				trackemail_emails
				
			WHERE
				site = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.site#" />
				AND subject = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subject#" />
					
		</cfquery>

		<cfif loc.emailExists.recordCount eq 0>
			<cfreturn false />
		<cfelse>
			<cfreturn loc.emailExists.id />
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="getEmails" 
				returntype="query" 
				access="public" 
				output="false"
				hint="Returns a query of emails that are being tracked">
				
		<cfset var loc = {} />

		<!--- Set variables to use --->
		<cfset _initVars() />
		
		<cfquery 
			name="loc.emails" 
			datasource="#this.dsn#">
			
			SELECT
				trackemail_emails.id,
				trackemail_emails.subject,
				Count( trackemail_sent.id ) AS numberSent
				
			FROM 
				trackemail_emails INNER JOIN trackemail_sent ON
				trackemail_emails.id = trackemail_sent.emailId
				
			WHERE
				trackemail_emails.site = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.site#" />
				
			GROUP BY
				trackemail_emails.id,
				trackemail_emails.subject
				
			ORDER BY trackemail_emails.subject
		</cfquery>

		<cfreturn loc.emails />
		
	</cffunction>
	

	<cffunction name="getEmailReport" 
				returntype="struct" 
				access="public" 
				output="true"
				hint="Returns a struct of data for reporting">
				
		<cfargument 
			name="emailId" 
			type="numeric" 
			required="true" />
			
		<cfargument 
			name="startDate" 
			type="date" 
			default="#DateAdd( 'm', -6, now() )#" />
			
		<cfargument 
			name="endDate" 
			type="date" 
			default="#now()#" />
			
		<cfset var loc = {} />
		
		<!--- Create report struct to hold data --->
		<cfset loc.report = {} />
		
		<!--- Create start and end date from the dates passed in the arguments --->
		<cfset loc.startDate = CreateDateTime( Year( arguments.startDate ), Month( arguments.startDate ), Day( arguments.startDate ), 0, 0, 0 ) />
		<cfset loc.endDate = CreateDateTime( Year( arguments.endDate ), Month( arguments.endDate ), Day( arguments.endDate ), 23, 59, 59 ) />
		
		<!--- Get the difference in days between start date and end date --->
		<cfset loc.days = Abs( DateDiff( "d", loc.startDate, loc.endDate ) ) />
		
		<!--- Set variables to use --->
		<cfset _initVars() />
		
		<!--- Get the record for this email to display subject and body --->
		<cfquery
			name="loc.getEmail"
			datasource="#this.dsn#">
			
			SELECT 
				*
			
			FROM
				trackemail_emails
				
			WHERE 
				id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
		</cfquery>
		
		<cfset loc.report.email = loc.getEmail />
		
		<cfset loc.report.recipientData = _getRecipientData(
			startDate = loc.startDate,
			endDate = loc.endDate,
			emailId = arguments.emailId	
		) />
		
		<cfset loc.summaryByDate = _getSummaryByDate(
			startDate = loc.startDate,
			endDate = loc.endDate,
			emailId = arguments.emailId	
		) />
		
		<cfset loc.linkClicksByDate = _getLinkClicksByDate(
			startDate = loc.startDate,
			endDate = loc.endDate,
			emailId = arguments.emailId	
		) />
		
		<!---********************************************************************
		Create the json needed to display the two google charts used on the report
		********************************************************************* --->
		
		<!--- Create a struct of all the possible dates that will contain the number of emails sent, views, and clicks --->
		<cfloop 
			from="0" 
			to="#loc.days#" 
			index="loc.j">
		
			<cfset loc.tempDate = DateFormat( DateAdd( "d", loc.j, loc.startDate ), "mm/dd/yyyy" ) />
			
			<cfset loc.dataByDate[ loc.tempDate ] = {} />
			
			<cfset loc.dataByDate[ loc.tempDate ].sent = 0 />
			<cfset loc.dataByDate[ loc.tempDate ].views = 0 />
			<cfset loc.dataByDate[ loc.tempDate ].clicks = 0 />
			
			<!--- Create a struct for the date that will contain links and clicks --->
			<cfset loc.dataLinkClicksByDate[ loc.tempDate ] = {} />
			
			<!--- Loop through the links to create a struct of links and number of times clicked by date --->
			<cfloop 
				list="#ValueList( loc.linkClicksByDate.link )#" 
				index="loc.l">
		
				<!--- Init data for date and link --->
				<cfset loc.dataLinkClicksByDate[ loc.tempDate ][ loc.l ] = 0 />
				
				<!--- Get number of clicks by date and link --->
				<cfquery 
					name="loc.q" 
					dbtype="query">
				
					SELECT
						numberClicks
						
					FROM
						loc.linkClicksByDate
						
					WHERE
						link = '#loc.l#'
						AND dateClick = '#loc.tempDate#'
						
				</cfquery>
				
				<cfif loc.q.recordCount gt 0>
					<cfset loc.dataLinkClicksByDate[ loc.tempDate ][ loc.l ] = loc.q.numberClicks />
				</cfif>
				
			</cfloop>
			
		</cfloop>
		
		<!--- Loop through the byDate query to populate the struct of dates that was created in the loop above --->
		<cfloop 
			query="loc.summaryByDate">
			
			<cfif loc.summaryByDate.type eq "sent">
				
				<cfset loc.dataByDate[ DateFormat( loc.summaryByDate.createdAt, "mm/dd/yyyy" ) ].sent = number />
			
			<cfelseif loc.summaryByDate.type eq "view">
				
				<cfset loc.dataByDate[ DateFormat( loc.summaryByDate.createdAt, "mm/dd/yyyy" ) ].views = number />
			
			<cfelseif loc.summaryByDate.type eq "click">
				
				<cfset loc.dataByDate[ DateFormat( loc.summaryByDate.createdAt, "mm/dd/yyyy" ) ].clicks = number />
			
			</cfif>
			
		</cfloop>
		
		<!--- Create json array of sent, views, and clicks to be used by google charts --->
		<cfsavecontent variable="loc.report.summaryChartData">
			<cfoutput>
			<cfloop 
				list="#ListSort( StructKeyList( loc.dataByDate ), 'text', 'ASC' )#" 
				index="loc.itemDate">
				
				[ '#DateFormat(  loc.itemDate, "mm/dd/yyyy" )#', #loc.dataByDate[ loc.itemDate ].sent#, #loc.dataByDate[ loc.itemDate ].views#, #loc.dataByDate[ loc.itemDate ].clicks# ],
				
			</cfloop>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Add column name information to json --->
		<cfset loc.report.summaryChartData = "['Date', 'Sent', 'Views', 'Clicks']," & Left( loc.report.summaryChartData, Len( loc.report.summaryChartData ) - 1 ) />
		
		<!--- Start the header row json for --->
		<cfset loc.rowHead = "[ 'Date'," />
		
		<cfset loc.count = 1 />
		
		<cfif loc.linkClicksByDate.recordCount gt 0>
			<cfset loc.report.hasLinkData = true />
			
			<cfsavecontent variable="loc.report.linkChartData">
				<cfoutput>
					
				<!--- Loop through the dates we have clicks on --->
				<cfloop 
					list="#ListSort( StructKeyList( loc.dataLinkClicksByDate ), 'text', 'ASC' )#" 
					index="loc.itemDate">
				
					<!--- Start json row --->
					<cfset loc.row = "[ '#DateFormat( loc.itemDate, "mm/dd/yyyy" )#'," />
					
					<cfloop 
						collection=#loc.dataLinkClicksByDate[ loc.itemDate ]# 
						item="loc.itemLink">
						
						<!--- If this is the first date we are looping through add the link to the row header --->
						<cfif loc.count eq 1>
							<cfset loc.rowHead = loc.rowHead & "'#loc.itemLink#'," />	
						</cfif>
						
						<cfset loc.row = loc.row & "#loc.dataLinkClicksByDate[ loc.itemDate ][ loc.itemLink ]#," />
					</cfloop>
					
					<!--- If this is the first date we are looping through close the row header --->
					<cfif loc.count eq 1>
						<cfset loc.rowHead = Left( loc.rowHead, Len( loc.rowHead ) - 1 ) & "]," />
					</cfif>
					
					<cfset loc.row = Left( loc.row, Len( loc.row ) - 1 ) & "]," />
					
					#loc.row#
					
					<cfset loc.count++ />
					
				</cfloop>
				</cfoutput>
			</cfsavecontent>
			
			<!--- Join the row and the row header --->
			<cfset loc.report.linkChartData = loc.rowHead & Left( loc.report.linkChartData, Len( loc.report.linkChartData ) - 1 ) />
		<cfelse>
			<cfset loc.report.hasLinkData = false />
		</cfif>
		
		<cfreturn loc.report />
	</cffunction>
	
	
	<cffunction name="_getLinkClicksByDate"
				returnType="query"
				access="public"
				output="false"
				hint="Return a query of the links and how often they've been clicked by date.">
	
		<cfargument 
			name="startDate" 
			type="date" 
			required="true"
			hint="The start date for when we are looking for data" />
			
		<cfargument
			name="endDate" 
			type="date" 
			required="true"
			hint="The end date for when we are looking for data" />
			
		<cfargument 
			name="emailId" 
			type="numeric" 
			required="true"
			hint="The id of the email we are looking for data for" />
			
		<cfset var loc = {} />
		
		<!--- Get the number of clicks by link and by date --->
		<cfquery
			name="loc.linkClicksByDate"
			datasource="#this.dsn#">
			
			SELECT
				Count( trackemail_links.id ) AS numberClicks,
				link,
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_links.createdAt ) ) AS dateClick
				
			FROM
				trackemail_links INNER JOIN trackemail_sent ON
				trackemail_links.sentId = trackemail_sent.id
			
			WHERE
				trackemail_links.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_links.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			GROUP BY
				link,
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_links.createdAt ) )
				
			ORDER BY 
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_links.createdAt ) ),
				link
		</cfquery>
		
		<cfreturn loc.linkClicksByDate />
		
	</cffunction>
	
	
	<cffunction name="_getRecipientData"
				returnType="query"
				access="public"
				output="false"
				hint="Return a query of the emails sent, email views, and clicks by email recipient.">
	
		<cfargument 
			name="startDate" 
			type="date" 
			required="true"
			hint="The start date for when we are looking for data" />
			
		<cfargument
			name="endDate" 
			type="date" 
			required="true"
			hint="The end date for when we are looking for data" />
			
		<cfargument 
			name="emailId" 
			type="numeric" 
			required="true"
			hint="The id of the email we are looking for data for" />
			
		<cfset var loc = {} />
		
		<!--- This query gets individual email information to display --->
		<cfquery 
			name="loc.recipientData" 
			datasource="#this.dsn#">
			
			SELECT
				trackemail_sent.id,
				trackemail_sent.recipient,
				trackemail_sent.createdAt AS sentOn,
				'' AS link,
				'sent' AS type,
				trackemail_sent.createdAt

			FROM 
				trackemail_sent
				
			WHERE
				trackemail_sent.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_sent.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			
			UNION SELECT
				trackemail_sent.id,
				trackemail_sent.recipient,
				trackemail_sent.createdAt AS sentOn,
				'' AS link,
				'view' AS type,
				trackemail_views.createdAt

			FROM 
				trackemail_views RIGHT JOIN trackemail_sent ON trackemail_sent.id = trackemail_views.sentId
				
			WHERE
				trackemail_views.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_views.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			
			UNION SELECT
				trackemail_sent.id,
				trackemail_sent.recipient,
				trackemail_sent.createdAt AS sentOn,
				trackemail_links.link,
				'click' AS type,
				trackemail_links.createdAt
				
			FROM 
				trackemail_links RIGHT JOIN trackemail_sent ON trackemail_sent.id = trackemail_links.sentId
				
			WHERE
				trackemail_links.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_links.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
			
			ORDER BY 
				recipient, 
				id, 
				type DESC, 
				link
		</cfquery>
		
		<cfreturn loc.recipientData />
		
	</cffunction>
	
	
	<cffunction name="_getSummaryByDate"
				returnType="query"
				access="public"
				output="false"
				hint="Return a query of the summary of sent emails, email views, and clicks by date.">
	
		<cfargument 
			name="startDate" 
			type="date" 
			required="true"
			hint="The start date for when we are looking for data" />
			
		<cfargument
			name="endDate" 
			type="date" 
			required="true"
			hint="The end date for when we are looking for data" />
			
		<cfargument 
			name="emailId" 
			type="numeric" 
			required="true"
			hint="The id of the email we are looking for data for" />
			
		<cfset var loc = {} />
		
		<!--- Get the number of emails sent, the number of views, and the number of clicks grouped by date --->
		<cfquery
			name="loc.summaryByDate"
			datasource="#this.dsn#">
			
			SELECT
				Count( id ) AS number,
				DATEADD( dd, 0, DATEDIFF( dd, 0, createdAt ) ) AS createdAt,
				'sent' AS type
				
			FROM
				trackemail_sent
				
			WHERE
				createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			GROUP BY
				DATEADD( dd, 0, DATEDIFF( dd, 0, createdAt ) )
			
			
			UNION SELECT
				Count( trackemail_views.id ) AS number,
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_views.createdAt ) ) AS createdAt,
				'view' AS type
				
			FROM
				trackemail_views INNER JOIN trackemail_sent ON
				trackemail_views.sentId = trackemail_sent.id
				
			WHERE
				trackemail_views.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_views.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			GROUP BY
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_views.createdAt ) )
			
			
			UNION SELECT
				Count( trackemail_links.id ) AS number,
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_links.createdAt ) ) AS createdAt,
				'click' AS type
				
			FROM
				trackemail_links INNER JOIN trackemail_sent ON
				trackemail_links.sentId = trackemail_sent.id
				
			WHERE
				trackemail_links.createdAt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
				AND trackemail_links.createdAt <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
				AND trackemail_sent.emailId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailId#" />
				
			GROUP BY
				DATEADD( dd, 0, DATEDIFF( dd, 0, trackemail_links.createdAt ) )
				
			ORDER BY 
				createdAt
				
		</cfquery>
		
		<cfreturn loc.summaryByDate />
		
	</cffunction>
	
	
	<cffunction name="_insertEmail" 
				returntype="numeric" 
				access="public" 
				output="false"
				hint="Insert email into trackemail_emails table. Returns id of email record">
	
		<cfargument
			name="subject" 
			type="string" 
			default=""
			hint="The subject line of the email being sent" />
			
		<cfargument 
			name="body" 
			type="string" 
			required="true"
			hint="The body of the email being sent" />
		
		<cfset var loc = {} />
		
		<cfset _initVars() />
		
		<cfquery 
			name="loc.insertEmail" 
			datasource="#this.dsn#"
			result="loc.insertEmailResult">
			
			INSERT INTO trackemail_emails
				(
					site,
					subject,
					body,
					createdAt
				) 
			
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#this.site#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.subject#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.body#" />,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
				)
			
		</cfquery>

		<cfreturn loc.insertEmailResult.IDENTITYCOL />
		
	</cffunction>
	
	
	<cffunction name="_insertLink" 
				returntype="void" 
				access="public" 
				output="false"
				hint="Insert a record of someone clicking on a link">
	
		<cfargument 
			name="sentId" 
			type="string" 
			required="true"
			hint="The uuid for a particular email sent." />
			
		<cfargument 
			name="link" 
			type="string" 
			default=""
			hint="The link the user clicked" />
		
		<cfset var loc = {} />
		
		
		<cfquery 
			name="loc.insertLink" 
			datasource="#this.dsn#">
			
			INSERT INTO trackemail_links
				(
					sentId,
					link,
					createdAt
				) 
			
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.sentId#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.link#" />,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
				)
			
		</cfquery>

	</cffunction>
	
	
	<cffunction name="_insertSent" 
				returntype="string" 
				access="public" 
				output="false"
				hint="Insert a record of an email being sent. Returns a uuid for this email being sent">
	
		<cfargument 
			name="emailid" 
			type="numeric" 
			required="true"
			hint="The id of the email being sent." />
			
		<cfargument 
			name="recipient" 
			type="string" 
			required="true"
			hint="The email address to which the email was sent" />
			
		<cfset var loc = {} />
		
		<cfset loc.uuid = CreateUUID() />
		
		<cfquery 
			name="loc.insertSent" 
			datasource="#this.dsn#">
			
			INSERT INTO trackemail_sent
				(
					id,
					emailid,
					recipient,
					createdAt
				) 
			
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_char" value="#loc.uuid#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.emailid#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.recipient#" />,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
				)
			
		</cfquery>

		<cfreturn loc.uuid />
		
	</cffunction>
	
	
	<cffunction name="_insertView" 
				returntype="void" 
				access="public" 
				output="false"
				hint="Insert a record of someone viewing an email">
	
		<cfargument 
			name="sentId" 
			type="string" 
			required="true" />
			
		<cfset var loc = {} />

		<cfquery 
			name="loc.insertView" 
			datasource="#this.dsn#">
			
			INSERT INTO trackemail_views
				(
					sentId,
					createdAt
				) 
			
			VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.sentId#" />,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
				)
			
		</cfquery>

	</cffunction>
	
	
	<cffunction name="sendEmail" returntype="any" access="public" output="false" hint="Sends an email using a template and an optional layout to wrap it in. Besides the Wheels-specific arguments documented here, you can also pass in any argument that is accepted by the `cfmail` tag as well as your own arguments to be used by the view."
		examples=
		'
			<!--- Get a member and send a welcome email, passing in a few custom variables to the template --->
			<cfset newMember = model("member").findByKey(params.member.id)>
			<cfset sendEmail(
				to=newMember.email,
				template="myemailtemplate",
				subject="Thank You for Becoming a Member",
				recipientName=newMember.name,
				startDate=newMember.startDate
			)>
		'
		categories="controller-request,miscellaneous" chapters="sending-email" functions="">
		<cfargument name="template" type="string" required="false" default="" hint="The path to the email template or two paths if you want to send a multipart email. if the `detectMultipart` argument is `false`, the template for the text version should be the first one in the list. This argument is also aliased as `templates`.">
		<cfargument name="from" type="string" required="false" default="" hint="Email address to send from.">
		<cfargument name="to" type="string" required="false" default="" hint="List of email addresses to send the email to.">
		<cfargument name="subject" type="string" required="false" default="" hint="The subject line of the email.">
		<cfargument name="layout" type="any" required="false" hint="Layout(s) to wrap the email template in. This argument is also aliased as `layouts`.">
		<cfargument name="file" type="string" required="false" default="" hint="A list of the names of the files to attach to the email. This will reference files stored in the `files` folder (or a path relative to it). This argument is also aliased as `files`.">
		<cfargument name="detectMultipart" type="boolean" required="false" hint="When set to `true` and multiple values are provided for the `template` argument, Wheels will detect which of the templates is text and which one is HTML (by counting the `<` characters).">
		<cfargument name="track" type="boolean" required="false" default="false" hint="When set to `true` adds open and click tracking to email">
		<cfargument name="$deliver" type="boolean" required="false" default="true">
		<cfscript>
			var loc = {};
			$args(args=arguments, name="sendEmail", combine="template/templates/!,layout/layouts,file/files", required="template,from,to,subject");
	
			loc.nonPassThruArgs = "template,templates,layout,layouts,file,files,detectMultipart,$deliver";
			loc.mailTagArgs = "from,to,bcc,cc,charset,debug,failto,group,groupcasesensitive,mailerid,maxrows,mimeattach,password,port,priority,query,replyto,server,spoolenable,startrow,subject,timeout,type,username,useSSL,useTLS,wraptext";
			loc.deliver = arguments.$deliver;
			loc.track = arguments.track;
			
			// if two templates but only one layout was passed in we set the same layout to be used on both
			if (ListLen(arguments.template) > 1 && ListLen(arguments.layout) == 1)
				arguments.layout = ListAppend(arguments.layout, arguments.layout);
	
			// set the variables that should be available to the email view template (i.e. the custom named arguments passed in by the developer)
			for (loc.key in arguments)
			{
				if (!ListFindNoCase(loc.nonPassThruArgs, loc.key) && !ListFindNoCase(loc.mailTagArgs, loc.key))
				{
					variables[loc.key] = arguments[loc.key];
					StructDelete(arguments, loc.key);
				}
			}
	
			// get the content of the email templates and store them as cfmailparts
			arguments.mailparts = [];
			loc.iEnd = ListLen(arguments.template);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
			{
				// include the email template and return it
				loc.content = $renderPage($template=ListGetAt(arguments.template, loc.i), $layout=ListGetAt(arguments.layout, loc.i));
				loc.mailpart = {};
				loc.mailpart.tagContent = loc.content;
				if (ArrayIsEmpty(arguments.mailparts))
				{
					ArrayAppend(arguments.mailparts, loc.mailpart);
				}
				else
				{
					// make sure the text version is the first one in the array
					loc.existingContentCount = ListLen(arguments.mailparts[1].tagContent, "<");
					loc.newContentCount = ListLen(loc.content, "<");
					if (loc.newContentCount < loc.existingContentCount)
						ArrayPrepend(arguments.mailparts, loc.mailpart);
					else
						ArrayAppend(arguments.mailparts, loc.mailpart);
					arguments.mailparts[1].type = "text";
					arguments.mailparts[2].type = "html";
				}
			}
	
			// figure out if the email should be sent as html or text when only one template is used and the developer did not specify the type explicitly
			if (ArrayLen(arguments.mailparts) == 1)
			{
				arguments.tagContent = arguments.mailparts[1].tagContent;
				StructDelete(arguments, "mailparts");
				if (arguments.detectMultipart && !StructKeyExists(arguments, "type"))
				{
					if (Find("<", arguments.tagContent) && Find(">", arguments.tagContent))
						arguments.type = "html";
					else
						arguments.type = "text";
				}
			}
	
			// does user wnat to track email
			if ( loc.track )
			{
				_initVars();
				
				// get email id if it exists
				loc.emailId = this._emailExists( subject=arguments.subject );
				
				// if email doesn't exists get body and insert
				if ( loc.emailId == false )
				{
					if ( NOT StructKeyExists( arguments, "mailparts" ) == 1 && arguments.type == "html" )
					{
						loc.body = arguments.tagContent;
					}
					else
					{
						loc.body = arguments.mailparts[ 2 ].tagContent;
					}
				
					// insert email and get email id
					loc.emailId = this._insertEmail( subject=arguments.subject, body=loc.body );
				}
				
				// insert a sent record for this email, returns uuid of sent record
				loc.uuid = this._insertSent( emailId=loc.emailId, recipient=arguments.to );
				
				// return email body with tracking code added	
				if ( NOT StructKeyExists( arguments, "mailparts" ) == 1 && arguments.type == "html" )
				{
					arguments.tagContent = this._addTracking( content=arguments.tagContent, uuid=loc.uuid );
				}
				else
				{
					arguments.mailparts[ 2 ].tagContent = this._addTracking( content=arguments.mailparts[ 2 ].tagContent, uuid=loc.uuid );
				}
			}
			
			// attach files using the cfmailparam tag
			if (Len(arguments.file))
			{
				arguments.mailparams = [];
				loc.iEnd = ListLen(arguments.file);
				for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				{
					arguments.mailparams[loc.i] = {};
					arguments.mailparams[loc.i].file = ExpandPath(application.wheels.filePath) & "/" & ListGetAt(arguments.file, loc.i);
				}
			}
	
			// delete arguments that we don't want to pass through to the cfmail tag
			loc.iEnd = ListLen(loc.nonPassThruArgs);
			for (loc.i=1; loc.i <= loc.iEnd; loc.i++)
				StructDelete(arguments, ListGetAt(loc.nonPassThruArgs, loc.i));
	
			// send the email using the cfmail tag
			if (loc.deliver)
				$mail(argumentCollection=arguments);
			else
				return arguments;
		</cfscript>
		
	</cffunction>
	
	
	<cffunction name="logLink" 
				returntype="void" 
				access="public" 
				output="false"
				hint="Log that someone clicked on a link in an email">
	
		<cfargument 
			name="sentId" 
			type="string" 
			required="true"
			hint="The id of the email that was sent" />
			
		<cfargument 
			name="link" 
			type="string" 
			required="true"
			hint="The link the user clicked" />
		
		<cfset _initVars() />
		
		<cfset _insertLink( sentId=arguments.sentId, link=arguments.link ) />

	</cffunction>
	
	
	<cffunction name="logView" 
				returntype="void" 
				access="public" 
				output="false"
				hint="Log that someone viewed the email">
	
		<cfargument 
			name="sentId" 
			type="string" 
			required="true"
			hint="The id of the email that was sent" />
			
		<cfset _initVars() />
		
		<cfset _insertView( sentId=arguments.sentId ) />

	</cffunction>
	
</cfcomponent>