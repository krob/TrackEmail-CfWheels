<!--- Display a tracking report for an email --->

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
	
	.user-item.even{
		background-color:#fdfbf4;
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
	
	.detail{}
	
		.detail h4{
			margin-bottom:0.25em;
		}
		
		.detail .email-sent-detail{
			margin-left:2%; 
			width:48%;
		}
			
		.detail .link-detail{
			float:right; 
			width:48%;
		}
		
			#content .detail .link-detail ul{
				margin-top:0;
				margin-left:0;
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
				
				if ( $(this).text() == 'Show' )
				{
					$(this).text( 'Hide' );
				}
				else
				{
					$(this).text( 'Show' );
				}
			}
		);
		
		$( 'input' ).datepicker();
		
		$( '#view-body-link' ).bind(
			'click',
			function()
			{
				$( '#body-container' ).slideToggle();
				
				if ( $(this).text() == 'Show email body' )
				{
					$(this).text( 'Hide email body' );
				}
				else
				{
					$(this).text( 'Show email body' );
				}
			}
		);
	});
</script> 

<cfoutput>
	<p>#linkTo( action="emails", text="<< back" )#</p>
	
	<h2>#HTMLEditFormat( report.email.subject )#</h2>
		
	<p><a id="view-body-link" href="javascript:void(0);">Show email body</a></p>
	
	<div id="body-container">
		#report.email.body#
	</div>
	
	<p>
		<form method="post">
			From: <input type="text" name="startDate" value="#DateFormat( params.startDate, 'mm/dd/yyyy' )#" />
			To: <input type="text" name="endDate" value="#DateFormat( params.endDate, 'mm/dd/yyyy' )#" />
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

<cfset rowCount = 1 />		
<cfoutput 
	query="report.recipientData" 
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
	
	<div class="user-item clearhack <cfif rowCount Mod 2 eq 0>even</cfif>">
		
		<div class="overview">
		
			<div class="email col">#recipient#</div>
			<div class="sent col">#sentTotalCount#</div>
			<div class="views col">#viewTotalCount#</div>
			<div class="clicks col">#clickTotalCount#</div>
			<div class="view-detail col"><a href="javascript:void(0);">Show</a></div>
			
		</div>
	
		<div class="detail">
		
			<div class="email-sent-detail col">
		
				<h4>Emails sent</h4>
		
				<div>
					#sentContent#
				</div>
			
			</div>
			
			<div class="link-detail col">
				
				<h4>Link summary</h4>
				
				<ul>
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
	
	<cfset rowCount++ />
	
</cfoutput>