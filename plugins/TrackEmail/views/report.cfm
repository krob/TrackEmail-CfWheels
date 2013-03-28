<!--- Display a tracking report for an email --->

<cfsilent>
	<cfparam name="form.startDate" default="#DateAdd( 'm', -1, now() )#" />
	<cfparam name="form.endDate" default="#now()#" />
	
	<cfset report = getEmailReport( emailid=url.emailid, startDate=#form.startDate#, endDate=#form.endDate# ) />
	
</cfsilent>

<style>
	.user-header{
		margin-top:2.5em;
	}
	
	.user-header div{
		font-weight:bold;
	}
	
	.col{
		float:left;
	}
	
	.email.col{
		width:510px;
	}
	
	.sent.col{
		width:100px;
	}
	
	.views.col{
		width:100px;
	}
	
	.clicks.col{
		width:100px;
	}
	
	.view-detail.col{
		width:120px;
	}
	
	.user-item .detail{
		display:none;
	}
	
	.sent-on.col{
		width:200px;
	}
	
	.link.col{
		width:200px;
	}
	
	#body-container{
		border:1px dashed #999;
		padding:0.5em;
		background-color:#fffff8;
		display:none;
	}
	
	/*----------------------------------------------
	Clearing floats hack
	----------------------------------------------*/
	.clearhack:after {
		content:".";
		display:block;
		height:0;
		clear:both;
		visibility:hidden;
		}
		
	.clearhack {display: inline-block;}
	
	/* Hides from IE-mac \*/	
	* html .clearhack {
		height:1%;
		}
	.clearhack {display: block;}
	/* End hide from IE-mac */
</style>

<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css" type="text/css" media="all" />
<script type="text/javascript" src="http://code.jquery.com/jquery-1.8.2.js"></script>
<script type="text/javascript" src="http://code.jquery.com/ui/1.9.1/jquery-ui.js"></script>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
	google.load("visualization", "1", {packages:["corechart"]});
	google.setOnLoadCallback(drawChart);

	function drawChart() 
	{
	
		var data = google.visualization.arrayToDataTable([
			<cfoutput>#report.summaryChartData#</cfoutput>
		]);

		var options = {};

		var chart = new google.visualization.ColumnChart(document.getElementById('overview'));
        
        chart.draw(data, options);
        
        <cfif report.hasLinkData>
	        var linkData = google.visualization.arrayToDataTable([
				<cfoutput>#report.linkChartData#</cfoutput>
			]);
	
			var linkOptions = {};
	
			var linkChart = new google.visualization.ColumnChart(document.getElementById('links'));
	        
	        linkChart.draw(linkData, linkOptions);
	    </cfif>
	}
	
	$(function(){
	
		$( '.view-detail a' ).bind(
			'click',
			function()
			{
				$(this).parent().parent().next().slideToggle();
			}
		);
		
		$( 'input' ).datepicker();
		
		$( '#view-body-link' ).bind(
			'click',
			function()
			{
				$( '#body-container' ).slideToggle();
			}
		);
	});
</script> 

<cfoutput>
	<h1>#HTMLEditFormat( report.email.subject )#</h1>
		
	<p><a id="view-body-link" href="javascript:void(0);">View body</a></p>
	
	<div id="body-container">
		#report.email.body#
	</div>
	
	<p>
		<form method="post">
			From: <input type="text" name="startDate" value="#DateFormat( form.startDate, 'mm/dd/yyyy' )#" />
			To: <input type="text" name="endDate" value="#DateFormat( form.endDate, 'mm/dd/yyyy' )#" />
			<button type="submit">Submit</button>
		</form>
	</p>
</cfoutput>

<div id="overview"></div>

<cfif report.hasLinkData>
	<div id="links"></div>
</cfif>

<div class="user-header clearhack">
				
	<div class="email col">Email Address</div>
	<div class="sent col">Sent</div>
	<div class="views col">Views</div>
	<div class="clicks col">Clicks</div>
	<div class="view-detail col">Detail</div>
			
</div>
		
<cfoutput 
	query="report.emails" 
	group="recipient">
	
	<cfset sentTotalCount = 0 />
	<cfset viewTotalCount = 0 />
	<cfset clickTotalCount = 0 />
	<cfset linkTotalClickCount = {} />
	
	<cfsavecontent variable="sentContent">
		
		<cfoutput 
			group="id">
		
			<cfset sentTotalCount++ />
			<cfset viewCount = 0 />
			<cfset clickCount = 0 />
			<cfset linkClickCount = {} />
		
			<cfoutput 
				group="link">
				
				<cfoutput>
				
					<cfif type eq "view">
					
						<cfset viewTotalCount++ />
						<cfset viewCount++ />
						
					<cfelseif type eq "click">
					
						<cfset clickTotalCount++ />
						<cfset clickCount++ />
						
						<cfif NOT StructKeyExists( linkClickCount, link )>
							<cfset linkClickCount[ link ] = 0 />
						</cfif>
						
						<cfif NOT StructKeyExists( linkTotalClickCount, link )>
							<cfset linkTotalClickCount[ link ] = 0 />
						</cfif>
						
						<cfset linkClickCount[ link ]++ />
						<cfset linkTotalClickCount[ link ]++ />
							
					</cfif>
					
				</cfoutput>
			
			</cfoutput>
			
			<div class="email-sent">
				<div class="clearhack">
					<div class="sent-on col">Sent on #DateFormat( sentOn, "mm/dd/yyyy" )# #TimeFormat( sentOn, "h:mm tt" )#</div>
					<div class="views col">views: #viewCount#</div>
					<div class="clicks col">clicks: #clickCount#</div>
				</div>
				
				<ul>
					<cfloop 
						collection=#linkClickCount# 
						item="l">
						
						<li class="clearhack">
							<div class="link col">#l#</div> 
							<div class="clicks col">clicks: #linkClickCount[ l ]#</div>
						</li>
						
					</cfloop>
				</ul>
			</div>

		</cfoutput>
	
	</cfsavecontent>
	
	<div class="user-item clearhack">
		
		<div class="overview">
		
			<div class="email col">#recipient#</div>
			<div class="sent col">#sentTotalCount#</div>
			<div class="views col">#viewTotalCount#</div>
			<div class="clicks col">#clickTotalCount#</div>
			<div class="view-detail col"><a href="javascript:void(0);">view</a></div>
			
		</div>
	
		<div class="detail">
		
			<div style="float:left; width:50%;">
		
				<h4>Emails sent</h4>
		
				#sentContent#
			
			</div>
			
			<div style="float:right; width:50%;">
				
				<h4>Link summary</h4>
				
				<ul style="margin-left:0;">
					<cfloop 
					collection=#linkTotalClickCount# 
					item="l">
						
						<li class="clearhack">
							<div class="link col">#l#</div> 
							<div class="clicks col">clicks: #linkTotalClickCount[ l ]#</div>
						</li>
						
					</cfloop>
				</ul>
				
			</div>
			
		</div>
		
		
	</div>
	
</cfoutput>