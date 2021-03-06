//------------- GLOBAL CONSTANTS
var CONST_HDR = "invoice_number,customer_number,status,first_name,last_name,billing_postcode,billing_address,email,company_name,due_date,issue_date,invoice_amount,billable_amount,paid_amount,paid_date,delivery_postcode,delivery_address,description_1,description_value_1,description_2,description_value_2,description_3,description_value_3,description_4,description_value_4,description_5,description_value_5,column1_header,column2_header,column3_header,column4_header,column5_header,column6_header,column7_header,column1_row_1,column2_row_1,column3_row_1,column4_row_1,column5_row_1,column6_row_1,column7_row_1,column1_row_2,column2_row_2,column3_row_2,column4_row_2,column5_row_2,column6_row_2,column7_row_2,column1_row_3,column2_row_3,column3_row_3,column4_row_3,column5_row_3,column6_row_3,column7_row_3,column1_row_4,column2_row_4,column3_row_4,column4_row_4,column5_row_4,column6_row_4,column7_row_4,column1_row_5,column2_row_5,column3_row_5,column4_row_5,column5_row_5,column6_row_5,column7_row_5,column1_row_6,column2_row_6,column3_row_6,column4_row_6,column5_row_6,column6_row_6,column7_row_6,column1_row_7,column2_row_7,column3_row_7,column4_row_7,column5_row_7,column6_row_7,column7_row_7,net_amount,standard_gst_rate,total_gst_amount,gst_description_1,gst_rate_1,gst_base_1,gst_amount_1,gst_description_2,gst_rate_2,gst_base_2,gst_amount_2,gst_description_3,gst_rate_3,gst_base_3,gst_amount_3,gst_description_4,gst_rate_4,gst_base_4,gst_amount_4,gst_description_5,gst_rate_5,gst_base_5,gst_amount_5";

var CONST_TD_HDR = '<tr><td id="exphdr0">1.  Invoice Number*</td></tr>'
+'<tr><td id="exphdr1">2.  Customer Number*</td></tr>'
+'<tr><td id="exphdr2">3.  Invoice Status*</td></tr>'							// constant mapper
+'<tr><td id="exphdr3">4.  First Name*</td></tr>'								// splitter feature
+'<tr><td id="exphdr4">5.  Last Name*</td></tr>'								// splitter feature
+'<tr><td id="exphdr5">6. Billing Postcode*</td></tr>'							// is it really mandatory?
+'<tr><td id="exphdr6">7. Billing Address*</td></tr>'							// is it really mandatory?
+'<tr><td id="exphdr7">8. E-mail</td></tr>'
+'<tr style="display: none;"><td id="exphdr8">9. Company Name</td></tr>'	
+'<tr><td id="exphdr9">10. Due Date*</td></tr>'									// date formatter - x 
+'<tr><td id="exphdr10">11. Issue Date*</td></tr>'								// date formatter - x
+'<tr><td id="exphdr11">12. Invoice Amount*</td></tr>'							// currency formatter - x
+'<tr><td id="exphdr12">13. Billable Amount*</td></tr>'							// currency formatter - x
+'<tr><td id="exphdr13">14. Paid Amount</td></tr>'								// currency formatter - x
+'<tr><td id="exphdr14">15. Paid Date</td></tr>'								// date formatter - x
+'<tr style="display: none;"><td id="exphdr15">16. Delivery Postcode</td></tr>'	// ignore 
+'<tr style="display: none;"><td id="exphdr16">17. Delivery Address</td></tr>'	// ignore
+'<tr><td id="exphdr17">18. Itemisation</td></tr>';								// multi drag feature

var CONST_P_ID 		= "#p01,#p02,#p03";
var CONST_P_TITLE 	= " // Start Mapping, // Ready to export?";
var DEBUG 			= true;
var DROP_BG_COLOR 	= "#71C600";

var _csv;
var _mapping;
var _track;

//------------- FUNCTIONS	
function Compatibility() {
	// a.download is only available to Chrome; alterative open new page and have user click on Save As
	if($.browser.webkit) {
		$('#export-browser-chrome').show();
		$('#browse-browser-chrome').show();
	} else {
		$('#export-browser-other').show();		
		$('#browse-browser-other').show();		
	}
}

function Csv2Table(data) {
			
 	var row = data.split(/[\r\n|\n]+/);
	_csv = [[]]; 

	for(var i=0;i<row.length;i++) {						
		var column = row[i].split(",");
		_csv[i] = column;					
	}	
	
	var html;
	
	for(var i=0;i<_csv[0].length;i++) {
		// :INFO: if imported has a blank header - ignore it (do not display) and continue 					
		if(jQuery.Common.String.IsEmpty(_csv[0][i]))
			continue;	
		
		html += '<tr><td id="' + i + '" class="name ui-draggable">'+ _csv[0][i] +'</td><td id="sample">' + _csv[1][i] + '</td></tr>';		
	}
	
	$("#table-1").html(html);
					
	DragStart();
}

function CsvValidator(data) {
	
	var result 	= true;
	var row 	= data.split(/[\r\n|\n]+/);
	var csv 	= [[]]; 
	var coln 	= 0;
	
	for(var i=0;i<row.length;i++) {	
		console.log(row[i]);					
		var column = row[i].split(",");
		csv[i] = column;					
	}	

	// first line must be header (minimum of 5?)
	if(csv[0].length<5) { 	
		$.gritter.add({
			 title: 'Error: ' + jQuery.Common.Validator.ErrorMessage("21").code + ' ' + jQuery.Common.Validator.ErrorMessage("21").message,
			  text: 'Please check your file and make sure the first line of your file contains headers.',
			sticky: true
		});
		return false;
	}
	
	// row record/s must match header size	
	for(var i=0;i<csv.length;i++) {
		if(csv[i].length == undefined && i == csv.length) { continue; }

		if(csv[0].length != csv[i].length) {
			
			$.gritter.add({
				 title: jQuery.Common.Validator.ErrorMessage("21").code + ' ' + jQuery.Common.Validator.ErrorMessage("22").message,
				  text: 'Record ' + i + ' does NOT match your header. Missing ' + csv[i].length + ' of ' + csv[0].length,
				sticky: true
			});
			return false;
		}
	}
	
	return result;
}

function DragStart() {
	
    var table = $('table');
			
	table.find('tr td.name').bind('mousedown', function() 
	{
		table.disableSelection();
	}).bind('mouseup', function() 
	{
		table.enableSelection();
	}).draggable({   
		helper: 'clone',
		cursor: 'move',
		opacity: 0.5,
		revert: true,
		revertDuration: 0
	});
	
	$('#table-0 td').droppable({
		drop: function(event, ui)
		{ 	 	
			var     id = '#' + ui.draggable.attr('id');
			var result = $(id).html() + '<input type="hidden" value="' + ui.draggable.attr('id') + '"/>';
			
			$(this).html(result);
			$(this).css('background-color', DROP_BG_COLOR);
		},
		hoverClass: 'hovered'	
	});		    	    
}

function GetCSV() {
	var data = Table2Csv();
	return data;
}

function Table2Csv() {
	jQuery.Common.Logger.Log('Table2Csv() start');
	
	var i   = 0;
	var str = "";
	var arr = [[]];
	var hdr = 0;
	var val = "";				
	_mapping = [];
	
	$('#table-0 td').each(function(){
		var result = $(this).find('input').val();
		_mapping[i] = result ? result : "";
		i++;				
	})
	
	hdr = i;		
	
	// get data from map
	for(var i=0;i<_csv.length;i++) {
		var temp = [];
		
		for(var j=0;j<hdr;j++) {
			temp[j] = _csv[i][_mapping[j]];		
		}
		
		arr[i] = temp;	
	}
	
	// convert to csv
	for(var i=0;i<arr.length;i++) {
		for(var j=0;j<arr[i].length;j++) { 
			if(i==0) // add header			
				str += CONST_HDR.split(',')[j] + ",";
			else {	
				val = arr[i][j];								
				// apply formatter	
				switch(j) {	
					case 11 :
					case 12 :
					case 13 :
						try {
						val = val.replace(/\s/, '');
						val = format("0.00",val);
						} catch(e) {}
						break;
					case 9 :
					case 10 :
					case 14 :
						val = jQuery.Common.String.DateFormat(val);
						break;
					default : 					
						break;
				}
				
				str += val + ",";
			}
		}			
		str += "\r\n";
	}
	return str;
}

//------------- DOCUMENT READY	
$(document).ready(function() {	

	startup(); // app startup
	
	// buttons : page next & page previous 
	$('#btn-next').click(function(){ animateTo("next"); });
	$('#btn-back').click(function(){ animateTo(""); });
	
	// buttons : table ctrls
 	$('#btn-reset').click(function(){ reset(); }); 	
 	$('#btn-table-0-down').click(function(){ $('#scroll-pane-0').animate({scrollTop:'+=112'},200); });
 	$('#btn-table-0-up').click(function(){ $('#scroll-pane-0').animate({scrollTop:'-=112'},200); });
 	$('#btn-table-1-down').click(function(){ $('#scroll-pane-1').animate({scrollTop:'+=112'},200); });
 	$('#btn-table-1-up').click(function(){ $('#scroll-pane-1').animate({scrollTop:'-=112'},200); });

 	// buttons : open file 
 	$("#filename").change(function(e) {
		if (e.target.files == undefined) { return false; } // only open csv type file/s otherwise return false and alert user		
		var reader = new FileReader();
		reader.onload = function(e) {				
			readFile(e.target.result);	
		};
		reader.readAsText(e.target.files.item(0));			
		return false;		
	});
    
    // ffai : enable and configure flash file api for open and save file/s
    $('#ffapi-sv').ffapi({id:'ffapi-sv', path:'swf/ffapi.swf', cmd:'save'});    
    $('#ffapi-br').ffapi({id:'ffapi-br', path:'swf/ffapi.swf', cmd:'browse'});

    function startup() {
		_track = 0; 						// initiate track page 			
		$('#table-0').html(CONST_TD_HDR); 	// populate template table
		
/* 		alert(jQuery.Common.String.DateFormat("5/23/2012")); */
		//alert(jQuery.Common.String.CurrencyFormat("$.00","##.##"));
		Compatibility();					// initiate compatibility setting/s
	}
	
	function readFile(data) {
	
		data = jQuery.Common.CSV.Clean(data);	// clean the CSV data first

		if(CsvValidator(data)){
			Csv2Table(data);
			animateTo("next");			
		}	 
	}
	 	
 	function reset() {
		$('#table-0').html(''); // clear
		$('#table-0').html(CONST_TD_HDR); // create
		DragStart();
	}
	
	function animateTo(type, ease) {
	    var speed      = 1000; //set animation speed
	    var $container = $("#content"); //define the container to move
	    var id;
	   
	    console.log('animateTo() (track='+_track+')');
	    if(type=='next') {
		    if(_track==2) return false;		    		   
	    	_track++;
	    } else {
	    	if(_track==0) return false;	
		    _track--;		    	
	    }
	    
	    id = CONST_P_ID.split(',')[_track];	
	    console.log('animateTo() (new track='+_track+' id='+id+')');
	    //$('#txt-breadc').html(CONST_P_ID.split(',')[track]);
	    $container.stop().animate({"left": -($(id).position().left)}, speed, 'easeOutQuart');
    }    
}); // #END jQuery ready();



