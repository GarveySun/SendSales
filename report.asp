<!--#include file ="config.asp"-->
<%
response.Write(request("errmsg"))
errmsg=""
'�������ݿ��ʼ��
dim conn,rs1,rs2,rs3
Set conn=Server.CreateObject("ADODB.Connection")
Set rs1 = Server.CreateObject("ADODB.Recordset")
Set rs2 = Server.CreateObject("ADODB.Recordset")
Set rs3 = Server.CreateObject("ADODB.Recordset")
'����ÿ���������ݿ�172.16.2.14
conn.open DBstr
selldate=split(request("selldate"),"/")
tablename = selldate(0)&right("0"&selldate(1),2)
'��ȡÿ����������
sql1="select * from [fxsDB].[dbo].["&tablename&"] where selldate = '"&request("selldate")&"'"
rs1.open sql1,conn, 1, 1
if rs1.eof or rs1.bof then
errmsg=errmsg&"fxsDB�в�ѯ�������ݣ���ȷ��Ҫ��ѯ�����������Ƿ��Ѿ��������"
end if
'�����ѯ�յ�����ר��
while not rs1.eof
'�������
  for i=0 to ubound(dl)
    if dlname(i)=rs1("floor") then
     dl(i)=dl(i)+rs1("xsje")
	 exit for
	end if
  next
'���㾫Ʒ  
  for j=0 to ubound(jp)
    if jpname(j)=rs1("gz") then
	
	 jp(j)=rs1("xsje")
	 exit for
	end if
  next
'ָ����һר��
rs1.movenext
wend
'�������ݿ����

'�����������룬��λ��Ԫ��������С��
  for i=0 to ubound(dl)
	 dl2(i)=cstr(round((dl(i)/10000),0))
  next 
'��Ʒ�������룬��λ��Ԫ����1λС��
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
'����д�뱾�����ݿ�Ŀ��������������� 
sql2="select * from [fxsDB].[dbo].[dailytable] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&request("selldate")&"'"
rs2.open sql2,conn,1,1
if rs2.eof then
errmsg=errmsg&"fxsDB�п�������û�ɼ�����"
end if

monthsell=1
insum=1
sellnumber=1
'ѭ�����㱾�����������Ҳ�ѯ�տ��������ۼ����״���
while not rs2.eof
  monthsell=monthsell+rs2("sellmoney")
  if cdate(rs2("selldate"))=cdate(request("selldate")) then
  sellmoney=rs2("sellmoney")
  insum=rs2("insum")
  sellnumber=rs2("sellnumber")
  end if
  rs2.movenext
wend
'���������������뵽��
sellmoney2=round((sellmoney/10000),0)

'����ÿ������
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

'�������ݿ�����¼ƻ������������¼ƻ�
sql3= "select * from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"'"
rs3.open sql3,conn,1,1

if rs3.eof then
    errmsg=errmsg&"fxsDB��û��¼�뵱���ռƻ���"
end if

monthplan=0
halfplan=0
'ѭ�������¼ƻ������������¼ƻ�
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

'�����۲���Ӧ��������ۼ�
huazhuang=dl(0)
zhubaojp=dl(1)+dl(2)+dl(3)+dl(22)
nvzhuang=dl(7)+dl(8)+dl(9)+dl(15)
piju=dl(4)+dl(5)+dl(6)
nanzhuangyd=dl(10)+dl(11)+dl(12)+dl(13)
jiayonget=dl(14)+dl(16)+dl(17)+dl(18)+dl(19)+dl(20)
chaoshi=dl(23)
'�������뵽��
huazhuang2=round((huazhuang/10000),0)
zhubaojp2=round((zhubaojp/10000),0)
nvzhuang2=round((nvzhuang/10000),0)
piju2=round((piju/10000),0)
nanzhuangyd2=round((nanzhuangyd/10000),0)
jiayonget2=round((jiayonget/10000),0)
chaoshi2=round((chaoshi/10000),0)

'���۲��������ַ���
xsbstr="�������۶�"&sellmoney2&"��Ԫ����ױ��"&huazhuang2&"���鱦��Ʒ��"&zhubaojp2&"��Ůװ��"&nvzhuang2&"��Ƥ�߲�"&piju2&"����װ�˶���"&nanzhuangyd2&"�����ö�ͯ��"&jiayonget2&"�����в�"&chaoshi2&" ��λ����Ԫ�����տ���"&insum&"�ˡ��ɽ�"&sellnumber&"�ʡ�ת����"&round(((sellnumber/insum)*100),2)&"% ֵ���ˣ�"

'����������ַ���
dlstr="�������۶�"&sellmoney2&"��Ԫ����ױ"&dl2(0)&"���鱦"&dl2(1)&"���ӱ��۾�"&dl2(2)&"����Ʒ"&dl2(22)&"����Ʒ"&dl2(3)&"����Ь"&dl2(4)&"��ŮЬ"&dl2(5)&"�����"&dl2(6)&"������"&dl2(7)&"���ഺ"&dl2(8)&"��Ů��"&dl2(9)&"����֯"&dl2(15)&"����װ"&dl2(10)&"����������"&dl2(11)&"���˶�"&round(((dl(12)+dl(13))/10000),0)&"����ͯ"&dl2(14)&"���ҵ�"&dl2(16)&"������"&dl2(17)&"���Ļ�"&dl2(18)&"���Ҿ�"&dl2(19)&"������"&dl2(23)&" ��λ����Ԫ��ֵ���ˣ�"

'һ�㾫Ʒ�������ַ���
jpstr="����һ�㾫Ʒ���۶�"&round((jpsum/10000),2)&"��Ԫ��"
for i=0 to ubound(jpnameshow)
    jpstr=jpstr&jpnameshow(i)&jp2(i)
next
jpstr=jpstr&" ��λ����Ԫ��ֵ���ˣ�"

'Ӫ�˲����������ַ���
yybzstr = "�쵼�����Ϻã��ٻ���¥"&selldate(1)&"��"&selldate(2)&"��Ԥ������"&sellplan&"��Ԫ��ʵ��"&sellmoney2&"��Ԫ��"
if sellmoney >= (sellplan*10000) then
    yybzstr = yybzstr&"��"&(sellmoney2-sellplan)&"��Ԫ��"
else
    yybzstr = yybzstr&"��"&(sellplan-sellmoney2)&"��Ԫ��"
end if
yybzstr = yybzstr&"���ۼ�"&round((monthsell/10000),2)&"��Ԫ�����¼ƻ�"&monthplan
if monthsell>=(halfplan*10000) then
    yybzstr = yybzstr&"��"&round(((monthsell-halfplan*10000)/10000),2)&"��Ԫ��"
else
    yybzstr = yybzstr&"��"&round(((halfplan*10000-monthsell)/10000),2)&"��Ԫ��"
end if
yybzstr = yybzstr&"���տ���"&insum&"�ˣ����״���"&sellnumber&"�ʣ��͵���"&round((sellmoney/sellnumber),0)&"Ԫ��ת����"&round(((sellnumber/insum)*100),2)&"%����ױ"&huazhuang2&"��Ԫ���鱦��Ʒ"&zhubaojp2&"��Ԫ��Ůװ"&nvzhuang2&"��Ԫ��Ƥ��"&piju2&"��Ԫ����װ�˶�"&nanzhuangyd2&"��Ԫ�����ö�ͯ"&jiayonget2&"��Ԫ������"&chaoshi2&"��Ԫ��"

'���������루����У�
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
<title>ÿ���ٱ�-<%=request("selldate")%></title>
</head>
<body>
<div class="background" align="center">
<div class="up_div">
<div class="l_div" align="center">
<table class="l_table" cellpadding="2" cellspacing="1">
<tr><th colspan="2">�㲥�Ұ�</th></tr>
<tr><td align="center" colspan="2"><%=request("selldate")%></td></tr>
<tr><td>�����ܶ�</td><td><%=sellmoney2%></td></tr>
<tr><td>��ױ��</td><td><%=huazhuang2%></td></tr>
<tr><td>�鱦��Ʒ��</td><td><%=zhubaojp2%></td></tr>
<tr><td>Ůװ��</td><td><%=nvzhuang2%></td></tr>
<tr><td>Ƥ�߲�</td><td><%=piju2%></td></tr>
<tr><td>��װ�˶���</td><td><%=nanzhuangyd2%></td></tr>
<tr><td>���ö�ͯ��</td><td><%=jiayonget2%></td></tr>
<tr><td>���в�</td><td><%=chaoshi2%></td></tr>
</table>
</div>
<div class="l_div"align="center">
<table class="l_table" cellpadding="2" cellspacing="1">
<tr><th colspan="2">�����ձ���</th></tr>
<tr><td align="center" colspan="2"><%=request("selldate")%></td></tr>
<tr><td>�����ܶ�</td><td id="sellmoney"><%=(sellmoney/10000)%></td></tr>
<tr><td>��ױ��</td><td><%=(huazhuang/10000)%></td></tr>
<tr><td>�鱦��Ʒ��</td><td><%=(zhubaojp/10000)%></td></tr>
<tr><td>Ƥ�߲�</td><td><%=(piju/10000)%></td></tr>
<tr><td>Ůװ��</td><td><%=(nvzhuang/10000)%></td></tr>
<tr><td>��װ�˶���</td><td><%=(nanzhuangyd/10000)%></td></tr>
<tr><td>���ö�ͯ��</td><td><%=(jiayonget/10000)%></td></tr>
<tr><td>���в�</td><td><%=(chaoshi/10000)%></td></tr>
</table>
</div>
<div class="r_div" align="left">
<br /><br />
ֵ���ˣ�<select id="who">
<option value="" selected>��ѡ��</option>
<option value="���">���</option>
<option value="�绯">�绯</option>
<option value="�˾�">�˾�</option>
<option value="������">������</option>
<option value="���ΰ">���ΰ</option>
</select>
<br />
<br />
<br /><span id="carrottip" title="�����汨��ϵͳ-���۲�ѯ-z����ҵ�����뱨��-Ȼ����Ŀѡ11���ܷ����-������������ѡ��Ʒ-����������У�ѡ˰��Ϊ0.17���С�"> ? </span>���ܲ������
<br /><input type="text" id="carrot" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')"  onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" value="" />��Ԫ
<br />
���ܲ���������ۼƣ�<br /><input type="text" id="carrots" onkeyup="this.value=this.value.replace(/[^\d.]/g,'')"  onafterpaste="this.value=this.value.replace(/[^\d.]/g,'')" value="" />��Ԫ<br />
������<input type="text" id="insum" value="<%=insum%>" />��<br />
�ɽ�������<input type="text" id="sellnumber" value="<%=sellnumber%>" />��
</div>
</div>
<br />
<div class="b_div" align="center">
<table class="b_table" cellpadding="10" cellspacing="5">
<tr><td width="80px">���۲���</td><td class="longtext"><textarea rows="3" id="xsb"><%=xsbstr%></textarea></td></tr>
<tr><td>���ࣺ</td><td class="longtext"><textarea rows="4" id="dl"><%=dlstr%></textarea></td></tr>
<tr><td>��Ʒ��</td><td class="longtext"><textarea rows="5" id="jp"><%=jpstr%></textarea></td></tr>
<tr><td>Ӫ�˲�����</td><td class="longtext"><textarea rows="4" id="yybz"><%=yybzstr%></textarea></td></tr>
</table>
<button onClick="javascrtpt:window.location.href='Default.asp'">����</button>
</div>
</div>

<script>
//Ԥ��ҳ��������İ��ַ���
var xsb=$("#xsb").text()
var dl=$("#dl").text()
var jp=$("#jp").text()
var yybz=$("#yybz").text()

$(document).ready(function(e) {
    //���¼�����������͵��ۡ���������
	$("#insum,#sellnumber").keyup(function(e) {
		var zhuanhua = $("#sellnumber").val()*100/$("#insum").val()
		zhuanhua = zhuanhua.toFixed(2)
        xsb = xsb.replace(/����\w*/,"����"+$("#insum").val())
		xsb = xsb.replace(/�ɽ�\d*/,"�ɽ�"+$("#sellnumber").val())
		xsb = xsb.replace(/ת����[a-zA-Z]*\d*\.*\d*/,"ת����"+zhuanhua)
		$("#xsb").text(xsb)
		var kedanjia = $("#sellmoney").text()*10000/$("#sellnumber").val()
		kedanjia = kedanjia.toFixed(0)
		yybz = yybz.replace(/����\w*/,"����"+$("#insum").val())
		yybz = yybz.replace(/����\d*/,"����"+$("#sellnumber").val())
		yybz = yybz.replace(/����\w*/,"����"+kedanjia)
		yybz = yybz.replace(/ת����[a-zA-Z]*\d*\.*\d*/,"ת����"+zhuanhua)
		$("#yybz").text(yybz)
    });
	
	
	//���۲������ࡢ��Ʒ�����ַ������ֵ��������
    $("#who").change(function(e) {
		var name=$(this).val()
		$("#xsb").text(xsb+name)
		$("#dl").text(dl+name)
		$("#jp").text(jp+name)
    });
	//Ӫ�˲������ַ�����Ӻ��ܲ�������
	$("#carrots,#carrot").keyup(function(e) {
		var carrot="���ܲ���"+$("#carrot").val()
		carrot=carrot+"��Ԫ�������ۼ�"+$("#carrots").val()+"��Ԫ��"
        $("#yybz").text(yybz+carrot)
    });
    $("#yybz").click(function(e) {
        if ($("#carrot").val() > 30 || $("#carrots").val() > 200){
			alert("���ܲ������۵�λ�ǡ���Ԫ�����븴�������Ƿ���ȷ");
		}
    });
	//�����ַ����Զ�ȫѡ
	$("textarea").click(function(e) {
		$(this).select();
	});
	//����ƶ������ܲ��嵯��������Ϣ
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
