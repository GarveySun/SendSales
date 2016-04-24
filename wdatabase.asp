<!--#include file ="config.asp"-->
<%
errmsg = ""
'日期分组，分成年月日，方便以后计算
selldate = Split(Request("selldate"),"/")
Dim conn1
Dim rs1
Dim conn2
Dim rs2
Dim conn3
Dim rs3
'连接并读取上传的excel文件
Set conn1 = Server.CreateObject("ADODB.Connection")
Set rs1   = Server.CreateObject("ADODB.Recordset")
'连接上传文件，用AccessDatabaseEngine打开xls文件
strAddr   = Server.MapPath("./files/" & Request("filename"))
conn1.open "Provider=Microsoft.ACE.OLEDB.12.0;Extended Properties=Excel 8.0;Data Source=" & strAddr
sheetname = Split(Request("filename"),".")
sql1      = "Select * from [" & sheetname(0) & "$]"
rs1.open sql1, conn1, 1, 1
'连接客流系统数据库
on error resume next
Set conn3 = Server.CreateObject("ADODB.Connection")
Set rs3   = Server.CreateObject("ADODB.Recordset")
conn3.open DBipva
CountDate = selldate(0) & "-" & Right("0" & selldate(1),2) & "-" & selldate(2)
sql3      = "select * from Summary_Day where CountDate = '" & CountDate & "' and SiteKey = 'P00002'"
rs3.open sql3,conn3,1,1

'如果没取到客流数据（每天11点前客流服务器没初始化完成，无法读取到数据）数据先置1

if err.number<>0 then
	insum      = 1
	sellnumber = 1
	errmsg     = "未能成功连接客流服务器，当日客流数与交易笔数设置为1，影响客流数、交易笔数、客单价、转化率。"
Else
	insum      = rs3("InSum")
	sellnumber = rs3("TransactionNumber")
End If

rs3.Close
conn3.Close
'连接要写入的数据库
Set conn2 = Server.CreateObject("ADODB.Connection")
Set rs2   = Server.CreateObject("ADODB.Recordset")
conn2.open DBstr
'数据库中每月一张表，表名格式为4位年&2位月，如201601
tablename = selldate(0) & Right("0" & selldate(1),2)
On Error Resume Next
rs2.open tablename,conn2

'如果本月表不存在（每月1号），则按字段建立新表
If Not Err.Number = 0 Then
	Err.Clear
	sql2 = "create table [dbo].[" & tablename & "](id Int IDENTITY primary key,selldate date,floor varchar(50),dept varchar(50),xl varchar(50),gz varchar(50),xsje money)"
	'sql数据库自增主键为id Int IDENTITY primary key    access数据库为id COUNTER primary key，金额为currency
	conn2.execute(sql2)
Else
	Response.Write(tablename)
End If

'删除表中要导入日期的销售数据，为重新写入做准备，因此不必担心某天数据重复导入
sql2 = "delete from [" & tablename & "] where selldate = '" & Request("selldate") & "'"
conn2.execute(sql2)
rs2.Close
sql2 = "select * from [" & tablename & "]"
rs2.open sql2,conn2,3,2

'循环计算对应日期总销sellsum，并写入数据库
sellsum         = 0
While Not rs1.eof
    sellsum         = sellsum + rs1("xsje")
    rs2.addnew
    rs2("selldate") = Request("selldate")
    rs2("floor") = rs1("floor")
    rs2("dept") = rs1("dept")
    rs2("xl") = rs1("xl")
    rs2("gz") = rs1("gz")
    rs2("xsje") = rs1("xsje")
    rs2.update
    rs1.movenext
Wend
rs1.Close
rs2.Close

'删除表中要导入日期的客流及总销数据，同样是防止某天多次导入
sql3 = "delete from dailytable where selldate = '" & Request("selldate") & "'"
conn2.execute(sql3)
'将当日总销sellsum，进店客流insum，销售笔数sellnumber写入数据库
sql3 = "insert into dailytable (selldate,sellmoney,insum,sellnumber) values ('" & Request("selldate") & "','" & sellsum & "','" & insum & "','" & sellnumber & "')"
conn2.execute(sql3)
conn1.Close
conn2.Close
'跳转到发送报表页，传递日期参数，错误消息参数
Response.Redirect("report.asp?selldate=" & Request("selldate") & "&errmsg=" & errmsg)
Response.End
%>
