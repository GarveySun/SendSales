<!--#include file ="config.asp"-->
<%
response.Write(request("errmsg"))
errmsg=""
'连接数据库初始化
dim conn,rs1,rs2,rs3
Set conn=Server.CreateObject("ADODB.Connection")
Set rs1 = Server.CreateObject("ADODB.Recordset")
Set rs2 = Server.CreateObject("ADODB.Recordset")
Set rs3 = Server.CreateObject("ADODB.Recordset")
'连接每日销售数据库172.16.2.14
conn.open DBstr
selldate=split(request("selldate"),"/")
tablename = selldate(0)&right("0"&selldate(1),2)
'读取每日销售数据
sql1="select * from [fxsDB].[dbo].["&tablename&"] where selldate = '"&request("selldate")&"'"
rs1.open sql1,conn, 1, 1
if rs1.eof or rs1.bof then
errmsg=errmsg&"fxsDB中查询不到数据，请确认要查询的日期销售是否已经导入过。"
end if
'历遍查询日的所有专柜
while not rs1.eof
'计算大类
  for i=0 to ubound(dl)
    if dlname(i)=rs1("floor") then
     dl(i)=dl(i)+rs1("xsje")
	 exit for
	end if
  next
'计算精品  
  for j=0 to ubound(jp)
    if jpname(j)=rs1("gz") then
	
	 jp(j)=rs1("xsje")
	 exit for
	end if
  next
'指向下一专柜
rs1.movenext
wend
'结束数据库计算

'大类四舍五入，单位万元，不保留小数
  for i=0 to ubound(dl)
	 dl2(i)=cstr(round((dl(i)/10000),0))
  next 
'精品四舍五入，单位万元保留1位小数
 jpsum=0
  for i=0 to ubound(jp)
   jpsum=jpsum+jp(i)
    if (jp(i)/10000)<1 and (jp(i)/10000)>0.1 then
	  jp2(i)="0"&cstr(round((jp(i)/10000),1))
	elseif (jp(i)/10000)>-1 and (jp(i)/10000)<-0.1 then
	  jp2(i)="-0"&right(cstr(round((jp(i)/10000),1)),2)
	else
	  jp2(i)=cstr(round((jp(i)/10000),1))
	end if
  next
'连接写入本地数据库的客流及月总销数据 
sql2="select * from [fxsDB].[dbo].[dailytable] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&request("selldate")&"'"
rs2.open sql2,conn,1,1
if rs2.eof then
errmsg=errmsg&"fxsDB中客流数据没采集到。"
end if

monthsell=1
insum=1
sellnumber=1
'循环计算本月累销并查找查询日客流、销售及交易次数
while not rs2.eof
  monthsell=monthsell+rs2("sellmoney")
  if cdate(rs2("selldate"))=cdate(request("selldate")) then
  sellmoney=rs2("sellmoney")
  insum=rs2("insum")
  sellnumber=rs2("sellnumber")
  end if
  rs2.movenext
wend
'当日总销四舍五入到万
sellmoney2=round((sellmoney/10000),0)

'返回每月天数
if selldate(1)=1 or selldate(1)=3 or selldate(1)=5 or selldate(1)=7 or selldate(1)=8 or selldate(1)=10 or selldate(1)=12 then
    endday = 31
elseif selldate(1)=2 then
    if ((selldate(0) mod 4=0)and(selldate(0) mod 100<>0) or (selldate(0) mod 400=0))then
        endday = 29
    else
        endday = 28
    end if
else
    endday = 30
end if

'连接数据库计算月计划，截至当日月计划
sql3= "select * from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"'"
rs3.open sql3,conn,1,1

if rs3.eof then
    errmsg=errmsg&"fxsDB中没有录入当日日计划。"
end if

monthplan=0
halfplan=0
'循环计算月计划，截至当日月计划
while not rs3.eof
    monthplan=monthplan+rs3("dailyplan")
	if datediff("d",cdate(request("selldate")),cdate(rs3("selldate")))<0 then 
	    halfplan=halfplan+rs3("dailyplan")
	elseif datediff("d",cdate(request("selldate")),cdate(rs3("selldate")))=0 then
	    halfplan=halfplan+rs3("dailyplan")
		sellplan=rs3("dailyplan")
	end if
	rs3.movenext
wend

'各销售部对应大类进行累加
huazhuang=dl(0)
zhubaojp=dl(1)+dl(2)+dl(3)+dl(22)
nvzhuang=dl(7)+dl(8)+dl(9)+dl(15)
piju=dl(4)+dl(5)+dl(6)
nanzhuangyd=dl(10)+dl(11)+dl(12)+dl(13)
jiayonget=dl(14)+dl(16)+dl(17)+dl(18)+dl(19)+dl(20)
chaoshi=dl(23)
'四舍五入到万
huazhuang2=round((huazhuang/10000),0)
zhubaojp2=round((zhubaojp/10000),0)
nvzhuang2=round((nvzhuang/10000),0)
piju2=round((piju/10000),0)
nanzhuangyd2=round((nanzhuangyd/10000),0)
jiayonget2=round((jiayonget/10000),0)
chaoshi2=round((chaoshi/10000),0)

'销售部版连接字符串
xsbstr="今日销售额"&sellmoney2&"万元。化妆部"&huazhuang2&"、珠宝精品部"&zhubaojp2&"、女装部"&nvzhuang2&"、皮具部"&piju2&"、男装运动部"&nanzhuangyd2&"、家用儿童部"&jiayonget2&"、超市部"&chaoshi2&" 单位：万元。今日客流"&insum&"人、成交"&sellnumber&"笔、转化率"&round(((sellnumber/insum)*100),2)&"% 值班人："

'大类版连接字符串
dlstr="今日销售额"&sellmoney2&"万元。化妆"&dl2(0)&"、珠宝"&dl2(1)&"、钟表眼镜"&dl2(2)&"、精品"&dl2(22)&"、饰品"&dl2(3)&"、男鞋"&dl2(4)&"、女鞋"&dl2(5)&"、箱包"&dl2(6)&"、成熟"&dl2(7)&"、青春"&dl2(8)&"、女内"&dl2(9)&"、针织"&dl2(15)&"、男装"&dl2(10)&"、中性休闲"&dl2(11)&"、运动"&round(((dl(12)+dl(13))/10000),0)&"、儿童"&dl2(14)&"、家电"&dl2(16)&"、数码"&dl2(17)&"、文化"&dl2(18)&"、家居"&dl2(19)&"、超市"&dl2(23)&" 单位：万元。值班人："

'一层精品版连接字符串
jpstr="今日一层精品销售额"&round((jpsum/10000),2)&"万元。"
for i=0 to ubound(jpnameshow)
    jpstr=jpstr&jpnameshow(i)&jp2(i)
next
jpstr=jpstr&" 单位：万元。值班人："

'营运部长版连接字符串
yybzstr = "领导，晚上好！百货大楼"&selldate(1)&"月"&selldate(2)&"日预计销售"&sellplan&"万元，实销"&sellmoney2&"万元，"
if sellmoney >= (sellplan*10000) then
    yybzstr = yybzstr&"超"&(sellmoney2-sellplan)&"万元。"
else
    yybzstr = yybzstr&"差"&(sellplan-sellmoney2)&"万元。"
end if
yybzstr = yybzstr&"月累计"&round((monthsell/10000),2)&"万元，较月计划"&monthplan
if monthsell>=(halfplan*10000) then
    yybzstr = yybzstr&"超"&round(((monthsell-halfplan*10000)/10000),2)&"万元。"
else
    yybzstr = yybzstr&"差"&round(((halfplan*10000-monthsell)/10000),2)&"万元。"
end if
yybzstr = yybzstr&"今日客流"&insum&"人，交易次数"&sellnumber&"笔，客单价"&round((sellmoney/sellnumber),0)&"元，转化率"&round(((sellnumber/insum)*100),2)&"%。化妆"&huazhuang2&"万元、珠宝精品"&zhubaojp2&"万元、女装"&nvzhuang2&"万元、皮具"&piju2&"万元、男装运动"&nanzhuangyd2&"万元、家用儿童"&jiayonget2&"万元、超市"&chaoshi2&"万元。"

'输出错误代码（如果有）
response.Write("<br />"&errmsg)
rs1.close
rs2.close
rs3.close
conn.close
%>
<!doctype html>
<html>
<head>
<meta charset="gb2312">
<link type="text/css" href="" rel="stylesheet">
<link href="css/jquery-ui.css" rel="stylesheet">
<script src="jquery/jquery-1.9.1.min.js"></script>
<script src="jquery/jquery-ui.js"></script><style type="text/css">
body{
	background-color:#cccccc;}
.background{
	background-color:#ccffff;
	width:80%;
	height:auto;
	position:absolute;
	top:10%;
	left:10%;
	margin:0px;
	border-radius:25px;
	}
input{
	width:80px;}
td{
	min-width:50px;
	text-align:center;
	}
table{
	margin:10px;}	
.l_div{
	float:left;
	width:33%;
	height:inherit;
	border:0px}
.r_div{
	float:left;
	width:33%;
	height:inherit;
	border:0px;
	}
.b_div{
	width:80%;
	}
td,th{
	background-color:#ccffff}
table.b_table td{
	background-color:#ccff99;
	}
textarea{
	width:98%;
	overflow:visible;
	font-size:16px;}
.l_table{
	background-color:#000}
.longtext{
	width:100%;
	text-align:left;
	padding:5px;}
#icons {
		margin: 0;
		padding: 0;
	}
.up_div{
	width:100%;
	height:260px;}
#icons li {
		margin: 2px;
		position: relative;
		padding: 4px 0;
		cursor: pointer;
		float: left;
		list-style: none;
	}
#icons span.ui-icon {
		float: left;
		margin: 0 4px;
	}
</style>
<title>每日速报-<%=request("selldate")%></title>
</head>
<body>
<div class="background" align="center">
<div class="up_div">
<div class="l_div" align="center">
<table class="l_table" cellpadding="2" cellspacing="1">
<tr><th colspan="2">广播室版</th></tr>
<tr><td align="center" colspan="2"><%=request("selldate")%></td></tr>
<tr><td>日销总额</td><td><%=sellmoney2%></td></tr>
<tr><td>化妆部</td><td><%=huazhuang2%></td></tr>
<tr><td>珠宝精品部</td><td><%=zhubaojp2%></td></tr>
<tr><td>女装部</td><td><%=nvzhuang2%></td></tr>
<tr><td>皮具部</td><td><%=piju2%></td></tr>
<tr><td>男装运动部</td><td><%=nanzhuangyd2%></td></tr>
<tr><td>家用儿童部</td><td><%=jiayonget2%></td></tr>
<tr><td>超市部</td><td><%=chaoshi2%></td></tr>
</table>
</div>
<div class="l_div"align="center">
<table class="l_table" cellpadding="2" cellspacing="1">
<tr><th colspan="2">简易日报版</th></tr>
<tr><td align="center" colspan="2"><%=request("selldate")%></td></tr>
<tr><td>日销总额</td><td id="sellmoney"><%=(sellmoney/10000)%></td></tr>
<tr><td>化妆部</td><td><%=(huazhuang/10000)%></td></tr>
<tr><td>珠宝精品部</td><td><%=(zhubaojp/10000)%></td></tr>
<tr><td>皮具部</td><td><%=(piju/10000)%></td></tr>
<tr><td>女装部</td><td><%=(nvzhuang/10000)%></td></tr>
<tr><td>男装运动部</td><td><%=(nanzhuangyd/10000)%></td></tr>
<tr><td>家用儿童部</td><td><%=(jiayonget/10000)%></td></tr>
<tr><td>超市部</td><td><%=(chaoshi/10000)%></td></tr>
</table>
</div>
<div class="r_div" align="left">
<br /><br />
值班人：<select id="who">
<option value="" selected>请选择</option>
<option value="武兵">武兵</option>
<option value="甄化">甄化</option>
<option value="潘静">潘静</option>
<option value="吕晓军">吕晓军</option>
<option value="孙佳伟">孙佳伟</option>
</select>
<br />
<br />
<br /><span id="carrottip" title="进销存报表系统-销售查询-z其他业务收入报表-然后项目选11功能服务费-二级报表条件选商品-查出来有两行，选税率为0.17那行。"> ? </span>胡萝卜村儿：
<br /><input type="text" id="carrot" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')"  onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" value="" />万元
<br />
胡萝卜村儿本月累计：<br /><input type="text" id="carrots" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')"  onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" value="" />万元<br />
客流：<input type="text" id="insum" value="<%=insum%>" />人<br />
成交笔数：<input type="text" id="sellnumber" value="<%=sellnumber%>" />笔
</div>
</div>
<br />
<div class="b_div" align="center">
<table class="b_table" cellpadding="10" cellspacing="5">
<tr><td width="80px">销售部：</td><td class="longtext"><textarea rows="3" id="xsb"><%=xsbstr%></textarea></td></tr>
<tr><td>大类：</td><td class="longtext"><textarea rows="4" id="dl"><%=dlstr%></textarea></td></tr>
<tr><td>精品：</td><td class="longtext"><textarea rows="5" id="jp"><%=jpstr%></textarea></td></tr>
<tr><td>营运部长：</td><td class="longtext"><textarea rows="4" id="yybz"><%=yybzstr%></textarea></td></tr>
</table>
<button onClick="javascrtpt:window.location.href='Default.asp'">返回</button>
</div>
</div>

<script>
//预存页面输出的四版字符串
var xsb=$("#xsb").text()
var dl=$("#dl").text()
var jp=$("#jp").text()
var yybz=$("#yybz").text()

$(document).ready(function(e) {
    //重新计算客流数、客单价、销售数量
	$("#insum,#sellnumber").keyup(function(e) {
		var zhuanhua = $("#sellnumber").val()*100/$("#insum").val()
		zhuanhua = zhuanhua.toFixed(2)
        xsb = xsb.replace(/客流\w*/,"客流"+$("#insum").val())
		xsb = xsb.replace(/成交\d*/,"成交"+$("#sellnumber").val())
		xsb = xsb.replace(/转化率[a-zA-Z]*\d*\.*\d*/,"转化率"+zhuanhua)
		$("#xsb").text(xsb)
		var kedanjia = $("#sellmoney").text()*10000/$("#sellnumber").val()
		kedanjia = kedanjia.toFixed(0)
		yybz = yybz.replace(/客流\w*/,"客流"+$("#insum").val())
		yybz = yybz.replace(/次数\d*/,"次数"+$("#sellnumber").val())
		yybz = yybz.replace(/单价\w*/,"单价"+kedanjia)
		yybz = yybz.replace(/转化率[a-zA-Z]*\d*\.*\d*/,"转化率"+zhuanhua)
		$("#yybz").text(yybz)
    });
	
	
	//销售部、大类、精品三版字符串后加值班人名字
    $("#who").change(function(e) {
		var name=$(this).val()
		$("#xsb").text(xsb+name)
		$("#dl").text(dl+name)
		$("#jp").text(jp+name)
    });
	//营运部长版字符串后加胡萝卜村销售
	$("#carrots,#carrot").keyup(function(e) {
		var carrot="胡萝卜村"+$("#carrot").val()
		carrot=carrot+"万元，当月累计"+$("#carrots").val()+"万元。"
        $("#yybz").text(yybz+carrot)
    });
    $("#yybz").click(function(e) {
        if ($("#carrot").val() > 30 || $("#carrots").val() > 200){
			alert("胡萝卜村销售单位是‘万元’，请复验输入是否正确");
		}
    });
	//单击字符串自动全选
	$("textarea").click(function(e) {
		$(this).select();
	});
	//光标移动到胡萝卜村弹出帮助信息
	$( "#carrottip" ).hover(
		function() {
			$( this ).addClass( "ui-state-hover" );
		},
		function() {
			$( this ).removeClass( "ui-state-hover" );
		}
	);
});
</script>
</body>
</html>
