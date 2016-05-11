$(function() {
	$.datepicker.regional["zh-CN"] = { closeText: "关闭", prevText: "&#x3c;上月", nextText: "下月&#x3e;", currentText: "今天", monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"], monthNamesShort: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"], dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"], dayNamesShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"], dayNamesMin: ["日", "一", "二", "三", "四", "五", "六"], weekHeader: "周", dateFormat: "yy-mm-dd", firstDay: 1, isRTL: !1, showMonthAfterYear: !0, yearSuffix: "年" }
	$.datepicker.setDefaults($.datepicker.regional["zh-CN"]);
		var datePicker = $("#ctl00_BodyMain_txtDate").datepicker({
			showOtherMonths: true,
			selectOtherMonths: true            
		});
});

$( "#tabs" ).tabs();
$( "#datepicker" ).datepicker({
	inline: true,
	dateFormat: "yy/m/d"
});
$( "#searchdate" ).datepicker({
	inline: true,
	dateFormat: "yy/m/d"
});
$( "#searchmonth" ).datepicker({
	inline: true,
	dateFormat: "yy/m",
	changeYear:true,
	changeMonth:true
});
$(".button").button();

$(document).ready(function(e) {
	//设定日期选择框的option
	setdate();
	//查询首页销售日历
	searchsellcalendar();
	//查询本月销售计划
	readsellplan();
	//给查询单日销售按钮绑定跳转地址
    $("#search").click(function(e) {
		var url="report.asp?selldate="+$("#searchdate").val()
        $("#form2").attr("action",url)
    });
	//日期变化绑定重新查询事件
	$("#year,#month").change(function(e) {
         searchsellcalendar();
    });
	//日期变化绑定重新查询事件
	$("#year2,#month2").change(function(e) {
        readsellplan();
    });
	//给写销售计划按钮绑定事件
	$("#wsellplanbutton").click(function(e) {
		checkpw();
    });
	//按钮绑定光标移动变化
	$(".pwbutton").hover(function (e) {
		$(this).addClass("pwhover")},function (e) {
			$(this).removeClass("pwhover")
	});
	//给“取消”按钮绑定清除半透明层的事件
	$("#pwcancel,div.blackback").on("click",function (e){
		$("div.blackback").hide();
	});
	//给“写入”按钮绑定校验密码过程，密码采用单向不可逆算法加密
	$("#pwwrite").on("click",function (e){
		var inputpw = $("input.pw").val();
		if (md5(inputpw) === "a8a29f5201d20b9a506a6a95003abcd7"){
			wsellplanbutton();
		}else{
			$("div.msg").addClass("error").show();
			$("div.msg").text("输入的密码有误，操作被拒绝");
		}
		$("div.blackback").hide();
	});
});

//向后台服务器请求销售日历中的数据
function searchsellcalendar(){
	var cyear = $("#year").val();
	var cmonth = $("#month").val();
	var datedata = {"year":cyear,"month":cmonth};
	$.ajax({
		url:"sellcalendar.asp",
		type:"POST",
		dataType:"json",
		data:datedata,
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
					$(".calendar:last").append('<td class="white"> </td>');
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

//检测是否有空白历史数据，如果有，弹出提示
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

//读取数据库中的销售计划
function readsellplan(){
	var syear = $("#year2").val();
	var smonth = $("#month2").val();
	var datedata2 = {"year":syear,"month":smonth};
	$.ajax({
		url:"searchsellplan.asp",
		type:"POST",
		dataType:"json",
		data:datedata2,
		success: function(data){
			var json = eval(data);
			var endday = json.endday;
			var i=1,j=1;
			$(".sellplans").remove();
			$("#tabs-3").append('<div class="sellplans"></div>');
			while (i<=endday){
				$("#tabs-3 div.sellplans").append("<div class=\"sellplan_input\">"+i+"号:<input class=\"sellplans\" value=\""+(json.sellplan[i-1] || "0")+"\"></input></div>");
				if(j>=7) {
					$("#tabs-3 div.sellplans").append("<br />");
					j=0;
				}
				i++;
				j++;
			}
			calculmplan();
		}
	});
}

//计算月计划总数并判断
function calculmplan(){
	var length=$("input.sellplans").length
	var sum=0;
	for (var i=0;i<length;i++){
		sum += parseInt($("input.sellplans")[i].value);
	}
	$("span.monthplan").text(sum);
	if (sum%10!==0){
		$("div.msg").show().removeClass("error");
		$("div.msg").text("提示：销售月计划似乎不是整数，请确认日计划录入正确！");
	}else{
		$("div.msg").hide();
	}
		
}
	
//向数据库中写入月计划
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
				$("div.msg").show().removeClass("error");
			    $("div.msg").text("提示：保存成功");
			}else{
				var errnumber = json.errnumber;
				var errsource = decodeURI(json.errsource);
			    var description = decodeURI(json.errdescription);
				$("div.msg").addClass("error");
				$("div.msg").show().text('<p class="errortip">写入出错！错误代码：'+errnumber+'。错误来源：'+errsource+'。错误描述：'+description+'</p>');			
			}
		}
	});
}

function checkpw(){
	$("div.blackback").show();
	$("input.pw").val("").focus();
}

//给写入按钮绑定检测事件
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
			$("div.msg").hide();
		};
	}else{
    	writesellplan();
	};
}

//设定选择框的日期
function setdate(){
	var date = new Date();
	var y = date.getFullYear();
	var m = date.getMonth() + 1;
	while (y >= 2016) {
		$(".year").append("<option value=\""+y+"\">"+y+"</option>");
		y--;
	}
	for (var i=1;i<13;i++) {
		if (i==m)
			$(".month").append("<option value=\""+i+"\" selected>"+i+"</option>");
		else
			$(".month").append("<option value=\""+i+"\">"+i+"</option>");
	}
}

function md5(string){
	function md5_RotateLeft(lValue, iShiftBits) {
		return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
		}
		function md5_AddUnsigned(lX,lY){
				var lX4,lY4,lX8,lY8,lResult;
				lX8 = (lX & 0x80000000);
				lY8 = (lY & 0x80000000);
				lX4 = (lX & 0x40000000);
				lY4 = (lY & 0x40000000);
				lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
				if (lX4 & lY4) {
						return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
				}
				if (lX4 | lY4) {
						if (lResult & 0x40000000) {
								return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
						} else {
								return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
						}
				} else {
						return (lResult ^ lX8 ^ lY8);
				}
		}         
		function md5_F(x,y,z){
				return (x & y) | ((~x) & z);
		}
		function md5_G(x,y,z){
				return (x & z) | (y & (~z));
		}
		function md5_H(x,y,z){
				return (x ^ y ^ z);
		}
		function md5_I(x,y,z){
				return (y ^ (x | (~z)));
		}
		function md5_FF(a,b,c,d,x,s,ac){
				a = md5_AddUnsigned(a, md5_AddUnsigned(md5_AddUnsigned(md5_F(b, c, d), x), ac));
				return md5_AddUnsigned(md5_RotateLeft(a, s), b);
		}; 
		function md5_GG(a,b,c,d,x,s,ac){
				a = md5_AddUnsigned(a, md5_AddUnsigned(md5_AddUnsigned(md5_G(b, c, d), x), ac));
				return md5_AddUnsigned(md5_RotateLeft(a, s), b);
		};
		function md5_HH(a,b,c,d,x,s,ac){
				a = md5_AddUnsigned(a, md5_AddUnsigned(md5_AddUnsigned(md5_H(b, c, d), x), ac));
				return md5_AddUnsigned(md5_RotateLeft(a, s), b);
		}; 
		function md5_II(a,b,c,d,x,s,ac){
				a = md5_AddUnsigned(a, md5_AddUnsigned(md5_AddUnsigned(md5_I(b, c, d), x), ac));
				return md5_AddUnsigned(md5_RotateLeft(a, s), b);
		};
		function md5_ConvertToWordArray(string) {
				var lWordCount;
				var lMessageLength = string.length;
				var lNumberOfWords_temp1=lMessageLength + 8;
				var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
				var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
				var lWordArray=Array(lNumberOfWords-1);
				var lBytePosition = 0;
				var lByteCount = 0;
				while ( lByteCount < lMessageLength ) {
						lWordCount = (lByteCount-(lByteCount % 4))/4;
						lBytePosition = (lByteCount % 4)*8;
						lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
						lByteCount++;
				}
				lWordCount = (lByteCount-(lByteCount % 4))/4;
				lBytePosition = (lByteCount % 4)*8;
				lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
				lWordArray[lNumberOfWords-2] = lMessageLength<<3;
				lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
				return lWordArray;
		}; 
		function md5_WordToHex(lValue){
				var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
				for(lCount = 0;lCount<=3;lCount++){
						lByte = (lValue>>>(lCount*8)) & 255;
						WordToHexValue_temp = "0" + lByte.toString(16);
						WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
				}
				return WordToHexValue;
		};
		function md5_Utf8Encode(string){
				string = string.replace(/\r\n/g,"\n");
				var utftext = ""; 
				for (var n = 0; n < string.length; n++) {
						var c = string.charCodeAt(n); 
						if (c < 128) {
								utftext += String.fromCharCode(c);
						}else if((c > 127) && (c < 2048)) {
								utftext += String.fromCharCode((c >> 6) | 192);
								utftext += String.fromCharCode((c & 63) | 128);
						} else {
								utftext += String.fromCharCode((c >> 12) | 224);
								utftext += String.fromCharCode(((c >> 6) & 63) | 128);
								utftext += String.fromCharCode((c & 63) | 128);
						} 
				} 
				return utftext;
		}; 
		var x=Array();
		var k,AA,BB,CC,DD,a,b,c,d;
		var S11=7, S12=12, S13=17, S14=22;
		var S21=5, S22=9 , S23=14, S24=20;
		var S31=4, S32=11, S33=16, S34=23;
		var S41=6, S42=10, S43=15, S44=21;
		string = md5_Utf8Encode(string);
		x = md5_ConvertToWordArray(string); 
		a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476; 
		for (k=0;k<x.length;k+=16) {
				AA=a; BB=b; CC=c; DD=d;
				a=md5_FF(a,b,c,d,x[k+0], S11,0xD76AA478);
				d=md5_FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
				c=md5_FF(c,d,a,b,x[k+2], S13,0x242070DB);
				b=md5_FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
				a=md5_FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
				d=md5_FF(d,a,b,c,x[k+5], S12,0x4787C62A);
				c=md5_FF(c,d,a,b,x[k+6], S13,0xA8304613);
				b=md5_FF(b,c,d,a,x[k+7], S14,0xFD469501);
				a=md5_FF(a,b,c,d,x[k+8], S11,0x698098D8);
				d=md5_FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
				c=md5_FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
				b=md5_FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
				a=md5_FF(a,b,c,d,x[k+12],S11,0x6B901122);
				d=md5_FF(d,a,b,c,x[k+13],S12,0xFD987193);
				c=md5_FF(c,d,a,b,x[k+14],S13,0xA679438E);
				b=md5_FF(b,c,d,a,x[k+15],S14,0x49B40821);
				a=md5_GG(a,b,c,d,x[k+1], S21,0xF61E2562);
				d=md5_GG(d,a,b,c,x[k+6], S22,0xC040B340);
				c=md5_GG(c,d,a,b,x[k+11],S23,0x265E5A51);
				b=md5_GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
				a=md5_GG(a,b,c,d,x[k+5], S21,0xD62F105D);
				d=md5_GG(d,a,b,c,x[k+10],S22,0x2441453);
				c=md5_GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
				b=md5_GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
				a=md5_GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
				d=md5_GG(d,a,b,c,x[k+14],S22,0xC33707D6);
				c=md5_GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
				b=md5_GG(b,c,d,a,x[k+8], S24,0x455A14ED);
				a=md5_GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
				d=md5_GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
				c=md5_GG(c,d,a,b,x[k+7], S23,0x676F02D9);
				b=md5_GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
				a=md5_HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
				d=md5_HH(d,a,b,c,x[k+8], S32,0x8771F681);
				c=md5_HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
				b=md5_HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
				a=md5_HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
				d=md5_HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
				c=md5_HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
				b=md5_HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
				a=md5_HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
				d=md5_HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
				c=md5_HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
				b=md5_HH(b,c,d,a,x[k+6], S34,0x4881D05);
				a=md5_HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
				d=md5_HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
				c=md5_HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
				b=md5_HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
				a=md5_II(a,b,c,d,x[k+0], S41,0xF4292244);
				d=md5_II(d,a,b,c,x[k+7], S42,0x432AFF97);
				c=md5_II(c,d,a,b,x[k+14],S43,0xAB9423A7);
				b=md5_II(b,c,d,a,x[k+5], S44,0xFC93A039);
				a=md5_II(a,b,c,d,x[k+12],S41,0x655B59C3);
				d=md5_II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
				c=md5_II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
				b=md5_II(b,c,d,a,x[k+1], S44,0x85845DD1);
				a=md5_II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
				d=md5_II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
				c=md5_II(c,d,a,b,x[k+6], S43,0xA3014314);
				b=md5_II(b,c,d,a,x[k+13],S44,0x4E0811A1);
				a=md5_II(a,b,c,d,x[k+4], S41,0xF7537E82);
				d=md5_II(d,a,b,c,x[k+11],S42,0xBD3AF235);
				c=md5_II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
				b=md5_II(b,c,d,a,x[k+9], S44,0xEB86D391);
				a=md5_AddUnsigned(a,AA);
				b=md5_AddUnsigned(b,BB);
				c=md5_AddUnsigned(c,CC);
				d=md5_AddUnsigned(d,DD);
		}
return (md5_WordToHex(a)+md5_WordToHex(b)+md5_WordToHex(c)+md5_WordToHex(d)).toLowerCase();
}
