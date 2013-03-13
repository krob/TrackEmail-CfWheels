<cfcomponent output="false" mixin="controller,dispatch">

	<cffunction name="init" 
				returntype="any" 
				access="public" 
				output="false"
				hint="Initialize component">
		
		<cfset this.version = "0.1" />
		
		<cfset _initVars() />
		
		<cfset _createTables() />
		
		<cfreturn this />
		
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
	
			if ( loc.track )
			{
				_initVars();
				
				loc.emailId = this._emailExists( subject=arguments.subject );
				
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
				
					loc.emailId = this._insertEmail( subject=arguments.subject, body=loc.body );
				}
				
				loc.uuid = this._insertSent( emailId=loc.emailId, recipient=arguments.to );
					
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
	
</cfcomponent>