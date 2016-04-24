
function searchsellcalendar(){
	var cyear = $("#year").val();
	var cmonth = $("#month").val();
	var datedata = "{cyear:"+cyear+",cmonth:"+cmonth+"}";
	$.ajax({
		url:"sellcalendar.asp",
		type:"POST",
		dataType:"json",
		data:{cdate:datedata},
		success: function(data){
			var json = eval(data);
			var endday = json.endday;
			var j = json.weekday;
			i=1;
			weekj=1;
			$(".calendar").remove();
			$("#sellcalendar").append('<tr class="calendar"></tr>');
			while (i<=endday){
				if (j>1){
					j=j-1;
					$(".calendar:last").append('<td> </td>');
				}else if (weekj>7){
					$("#sellcalendar").append('<tr class="calendar"></tr>');
					$(".calendar:last").append('<td><span class="daynumber">'+i+'</span><br /><span class="sellmoney">'+json.sellmoney[i-1]+'</span><span class="sellplan">'+json.sellplan[i-1]+'</span></td>');
					i=i+1;
					weekj=1;						
				}else{
					$(".calendar:last").append('<td><span class="daynumber">'+i+'</span><br /><span class="sellmoney">'+json.sellmoney[i-1]+'</span><span class="sellplan">'+json.sellplan[i-1]+'</span></td>');
					i=i+1;
				};
				weekj=weekj+1;
			}
			ifhisempty();
		}
	});	
}

function ifhisempty (){
    var date = new Date();
	var d = date.getDate();
	var y = date.getFullYear();
	var m = date.getMonth() + 1;
	if (($("#year").val() == y)&&($("month").val() == m)){
		$("table#sellcalendar tr td").each(function(index, element) {
			if (($(this).find("span.daynumber").text() < d)&&($(this).find("span.sellmoney").text() == "-")){
			$(this).addClass("emptysell");
			$(this).find("span.sellmoney").text("请导入").addClass("emptysell");
			}
		});
	}
}

function readsellplan(){
	var syear = $("#year2").val();
	var smonth = $("#month2").val();
	var datedata2 = "{syear:"+syear+",smonth:"+smonth+"}";
	$.ajax({
		url:"searchsellplan.asp",
		type:"POST",
		dataType:"json",
		data:{sdate:datedata2},
		success: function(data){
			var json = eval(data);
			var endday = json.endday;
			i=1;
			$(".sellplans").remove();
			$("#tabs-3").append('<div class="sellplans"></div>');
			while (i<=endday){
				$("#tabs-3 div.sellplans").append(i+'号<input class="sellplans" value="'+json.sellplan[i-1]+'"></input>万元<br />');
				i=i+1;
			}
		}
	});
}

function writesellplan(){
	var wyear = $("#year2").val();
	var wmonth = $("#month2").val();
	var endday = $("input.sellplans").length;
	var obj = {
		"wyear" :wyear,
		"wmonth":wmonth,
		"sellplan":[]
	}
	for (i=0;i<endday;i++){
		obj.sellplan[i]=$("input.sellplans").eq(i).val();
	}
	var datedata3 = JSON.stringify(obj);
	$.ajax({
		url:"writesellplan.asp",
		type:"POST",
		dataType:"json",
		data:{wdate:datedata3},
		success: function(data){
			var json = eval(data);
			var state = json.state
			if (state=="success"){
				$(".successtip,.errortip").remove();
			    $("#wsellplanbutton").after('<p class="successtip">保存成功！</p>');
			}else{
				var errnumber = json.errnumber;
				var errsource = decodeURI(json.errsource);
			    var description = decodeURI(json.errdescription);
				$(".successtip,.errortip").remove();
				$("#wsellplanbutton").after('<p class="errortip">写入出错！错误代码：'+errnumber+'。错误来源：'+errsource+'。错误描述：'+description+'</p>');			
			}
		}
	});
}


function wsellplanbutton(){
	var date = new Date();
	var y = date.getFullYear();
	var m = date.getMonth() + 1;
	var y2 = $("#year2").val();
	var m2 = $("#month2").val();
	if ( y2 < y || ( y2 = y && m2 <= m )) {
		if (confirm("您可能正在修改历史数据，将会影响今后查询到的历史销售计划。确定要这么做么？")) {
            writesellplan();
		}else{
			$(".successtip,.errortip").remove();
		};
	}else{
        if (confirm("确认要保存修改？")) {
            writesellplan();
		}else{
			$(".successtip,.errortip").remove();
		};
	};
}

function setdate(){
var date = new Date();
var y = date.getFullYear();
var m = date.getMonth() + 1;

while (y >= 2016) {
	var oP = document.createElement("option");
	var oText = document.createTextNode(y);
	oP.appendChild(oText);
	oP.setAttribute("value", y);
	document.getElementById('year').appendChild(oP);
	
	var oP = document.createElement("option");
	var oText = document.createTextNode(y);
	oP.appendChild(oText);
	oP.setAttribute("value", y);
	document.getElementById('year2').appendChild(oP);
	
	y = y - 1;
};

var j = 1;
for (i = 1; i < 13; i++) {
	var month = document.createElement("option");
	var monthText = document.createTextNode(j);
	month.appendChild(monthText);
	month.setAttribute("value", j);
	if (j == m) {
		month.setAttribute("selected", "selected");
	};
	document.getElementById('month').appendChild(month);
	
	var month = document.createElement("option");
	var monthText = document.createTextNode(j);
	month.appendChild(monthText);
	month.setAttribute("value", j);
	if (j == m) {
		month.setAttribute("selected", "selected");
	};
	document.getElementById('month2').appendChild(month);
	j = j + 1;
};
}