<cfcomponent output="false" mixin="controller,dispatch">

	<cffunction name="init" 
				returntype="any" 
				access="public" 
				output="false"
				hint="Initialize component">
		
		<cfset this.version = "0.1" />
		
		<cfset _initVars() />
		
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
			loc.content = loc.content & '<img src="#loc.trackUrl#&t=o" width="0" height="0" style="display:none;" />';
			
			return loc.content;
		</cfscript>
	
	</cffunction>


	<cffunction name="_emailExists" 
				returntype="any" 
				access="public" 
				output="false"
				hint="Checks if an email exists, if does it it returns the email id, if not returns false">
	
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
	
</cfcomponent>