<!---
Log a email view or a click of a link in the email

Parameters:

url.e (required) - the unique sent email id
url.t - stands for type, tracking a l=link or v=view
url.u - the link to forward the user too, required if type is link
--->

<cfsilent>
	<cfparam name="url.t" default="v" />
	
	<cfif StructKeyExists( url, "e" )>
		
		<cfif url.t eq "l" AND StructKeyExists( url, "u" )>
			
			<!--- log link and forward on to link destination --->
			<cfset logLink( sentId=url.e, link=url.u ) />
			<cflocation url="#url.u#" addtoken="false" />
			
		<cfelseif url.t eq "v">
		
			<cfset logView( sentId=url.e ) />
			
		</cfif>
	
	</cfif>
</cfsilent>

<!--- if type is view show the clear image --->
<cfif StructKeyExists( url, "e" )>

	<cfif url.t eq "v">
		
		<cfcontent type="image/png" file="#GetDirectoryFromPath( GetCurrentTemplatePath() )#clear.png" deleteFile="No">
		<cfheader name="Content-Disposition" value="filename=clear.png">
		
	</cfif>
		
</cfif>