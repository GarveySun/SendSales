<!--#include file ="config.asp"-->
<%
errmsg = ""
'���ڷ��飬�ֳ������գ������Ժ����
selldate = Split(Request("selldate"),"/")
Dim conn1
Dim rs1
Dim conn2
Dim rs2
Dim conn3
Dim rs3
'���Ӳ���ȡ�ϴ���excel�ļ�
Set conn1 = Server.CreateObject("ADODB.Connection")
Set rs1   = Server.CreateObject("ADODB.Recordset")
'�����ϴ��ļ�����AccessDatabaseEngine��xls�ļ�
strAddr   = Server.MapPath("./files/" & Request("filename"))
conn1.open "Provider=Microsoft.ACE.OLEDB.12.0;Extended Properties=Excel 8.0;Data Source=" & strAddr
sheetname = Split(Request("filename"),".")
sql1      = "Select * from [" & sheetname(0) & "$]"
rs1.open sql1, conn1, 1, 1
'���ӿ���ϵͳ���ݿ�
on error resume next
Set conn3 = Server.CreateObject("ADODB.Connection")
Set rs3   = Server.CreateObject("ADODB.Recordset")
conn3.open DBipva
CountDate = selldate(0) & "-" & Right("0" & selldate(1),2) & "-" & selldate(2)
sql3      = "select * from Summary_Day where CountDate = '" & CountDate & "' and SiteKey = 'P00002'"
rs3.open sql3,conn3,1,1

'���ûȡ���������ݣ�ÿ��11��ǰ����������û��ʼ����ɣ��޷���ȡ�����ݣ���������1

if err.number<>0 then
	insum      = 1
	sellnumber = 1
	errmsg     = "δ�ܳɹ����ӿ��������������տ������뽻�ױ�������Ϊ1��Ӱ������������ױ������͵��ۡ�ת���ʡ�"
Else
	insum      = rs3("InSum")
	sellnumber = rs3("TransactionNumber")
End If

rs3.Close
conn3.Close
'����Ҫд������ݿ�
Set conn2 = Server.CreateObject("ADODB.Connection")
Set rs2   = Server.CreateObject("ADODB.Recordset")
conn2.open DBstr
'���ݿ���ÿ��һ�ű�������ʽΪ4λ��&2λ�£���201601
tablename = selldate(0) & Right("0" & selldate(1),2)
On Error Resume Next
rs2.open tablename,conn2

'������±����ڣ�ÿ��1�ţ������ֶν����±�
If Not Err.Number = 0 Then
	Err.Clear
	sql2 = "create table [dbo].[" & tablename & "](id Int IDENTITY primary key,selldate date,floor varchar(50),dept varchar(50),xl varchar(50),gz varchar(50),xsje money)"
	'sql���ݿ���������Ϊid Int IDENTITY primary key    access���ݿ�Ϊid COUNTER primary key�����Ϊcurrency
	conn2.execute(sql2)
Else
	Response.Write(tablename)
End If

'ɾ������Ҫ�������ڵ��������ݣ�Ϊ����д����׼������˲��ص���ĳ�������ظ�����
sql2 = "delete from [" & tablename & "] where selldate = '" & Request("selldate") & "'"
conn2.execute(sql2)
rs2.Close
sql2 = "select * from [" & tablename & "]"
rs2.open sql2,conn2,3,2

'ѭ�������Ӧ��������sellsum����д�����ݿ�
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

'ɾ������Ҫ�������ڵĿ������������ݣ�ͬ���Ƿ�ֹĳ���ε���
sql3 = "delete from dailytable where selldate = '" & Request("selldate") & "'"
conn2.execute(sql3)
'����������sellsum���������insum�����۱���sellnumberд�����ݿ�
sql3 = "insert into dailytable (selldate,sellmoney,insum,sellnumber) values ('" & Request("selldate") & "','" & sellsum & "','" & insum & "','" & sellnumber & "')"
conn2.execute(sql3)
conn1.Close
conn2.Close
'��ת�����ͱ���ҳ���������ڲ�����������Ϣ����
Response.Redirect("report.asp?selldate=" & Request("selldate") & "&errmsg=" & errmsg)
Response.End
%>
