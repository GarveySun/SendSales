<!doctype html>
<html>
<head>
<meta charset="utf-8">
<link href="css/jquery-ui.css" rel="stylesheet">
<link href="css/maincss.css" rel="stylesheet">
<script src="jquery/jquery-1.9.1.min.js"></script>
<script src="jquery/jquery-ui.js"></script>

<title>每日速报</title>
</head>
<body>
<div class="blackback">
	<div class="pw_input">
    	<p>请输入密码以写入数据库</p>
        <input type="text" value="" class="pw" placeholder="请输入"><br />
        <button type="button" class="pwbutton pwwrite" id="pwwrite">写入</button>
        <button type="button" class="pwbutton pwcancel" id="pwcancel">取消</button>
    </div>
</div>
<div id="tabs">
  <ul>
    <li><a href="#tabs-0">查看销售日历</a></li>
    <li><a href="#tabs-1">上传销售数据</a></li>
    <li><a href="#tabs-2">查询销售报表</a></li>
    <li><a href="#tabs-3">录入销售计划</a></li>
  </ul>
  <div id="tabs-0">
    <div> 查看其它月份：
      <select class="year" id="year">
      </select>
      年
      <select class="month" id="month">
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
      <button class="button" type="submit">上传</button>
      <br />
    </form>
  </div>
  <div id="tabs-2">
    <form id="form2" name="form2" target="_blank" action="" method="post">
      查询
      <input type="text" id="searchdate" value="<%=(date()-1)%>">
      号的销售。
      <button class="button" id="search" type="submit">查询</button>
    </form>
  </div>
  <div id="tabs-3"> 查看/录入月计划：
    <select class="year" id="year2">
    </select>
    年
    <select class="month" id="month2">
    </select>
    月
    &nbsp;&nbsp;&nbsp;
    <button id="wsellplanbutton" class="button" type="button">保存修改</button>
    <div class="msg"></div>
    <div style="margin:5px">当月总销计划:<span class="monthplan"></span>万元。</div>
  </div>
</div>
<script src="js/mainjs.js"></script>
</body>
</html>
