<!doctype html>
<html>
<head>
<meta charset="utf-8">
<link href="css/jquery-ui.css" rel="stylesheet">
<link href="css/maincss.css" rel="stylesheet">
<script src="jquery/jquery-1.9.1.min.js"></script>
<script src="jquery/jquery-ui.js"></script>
<script src="js/mainjs.js"></script>
<title>每日速报</title>
</head>
<body>
<div id="tabs">
  <ul>
    <li><a href="#tabs-0">查看销售日历</a></li>
    <li><a href="#tabs-1">上传销售数据</a></li>
    <li><a href="#tabs-2">查询销售报表</a></li>
    <li><a href="#tabs-3">录入销售计划</a></li>
  </ul>
  <div id="tabs-0">
    <div> 查看其它月份：
      <select id="year">
      </select>
      年
      <select id="month">
      </select>
      月 </div>
    <table id="sellcalendar">
      <tr>
        <th>星期一</th>
        <th>星期二</th>
        <th>星期三</th>
        <th>星期四</th>
        <th>星期五</th>
        <th>星期六</th>
        <th>星期日</th>
      </tr>
    </table>
  </div>
  <div id="tabs-1">
    <form name="upload" action="upload.php" method="post" enctype="multipart/form-data" >
      <input type="hidden" name="MAX_FILE_SIZE" value="1000000" />
      销售数据对应日期：
      <input id="datepicker" type="text" name="selldate" value="<%=date()%>">
      <br />
      上传报表分析系统-销售查询-5查询专柜品牌销售 后基础转存成xls的数据表,先在本地用excel打开，保存一下，再上传: <br />
      <input type="file" name="pic" value="">
      <br />
      <button type="submit">upload</button>
      <br />
    </form>
  </div>
  <div id="tabs-2">
    <form id="form2" name="form2" target="_blank" action="" method="post">
      查询
      <input type="text" id="searchdate" value="<%=(date()-1)%>">
      号的销售。
      <button id="search" type="submit">查询</button>
      <br />
    </form>
  </div>
  <div id="tabs-3"> 查看/录入月计划：
    <select id="year2">
    </select>
    年
    <select id="month2">
    </select>
    月
    &nbsp;&nbsp;&nbsp;
    <button id="wsellplanbutton" type="button">保存修改</button>
  </div>
</div>
<script type="text/javascript">
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

$(document).ready(function(e) {
	setdate();
	searchsellcalendar();
	readsellplan();
    $("#search").click(function(e) {
		var url="report.asp?selldate="+$("#searchdate").val()
        $("#form2").attr("action",url)
    });
	$("#year,#month").change(function(e) {
         searchsellcalendar();
    });
	$("#year2,#month2").change(function(e) {
        readsellplan();
    });
	$("#wsellplanbutton").click(function(e) {
		wsellplanbutton();
    });
});
</script>
</body>
</html>
