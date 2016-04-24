<!--#include file ="config.asp"-->
<script language="jscript" runat="server">  
Array.prototype.get = function(x) { return this[x]; };  
function parseJSON(strJSON) { return eval("(" + strJSON + ")"); }  
</script>  
<%
Dim json, obj  
json = request("cdate")
Set obj = parseJSON(json)  
dim selldate(1)
selldate(0)=obj.cyear
selldate(1)=obj.cmonth

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

dim conn,rs1,rs2,sellmoney(30),sellplan(30)
for i=0 to 30 step 1
  sellmoney(i)="-"
  sellplan(i)="/null"
next
Set conn=Server.CreateObject("ADODB.Connection")
Set rs1 = Server.CreateObject("ADODB.Recordset")
Set rs2 = Server.CreateObject("ADODB.Recordset")
conn.open DBstr
sql1="select * from [fxsDB].[dbo].[dailytable] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"' order by selldate"
rs1.open sql1,conn,1,1
while not rs1.eof
  sellday1=split(rs1("selldate"),"-")
  sellmoney(cint(sellday1(2)-1))=round(rs1("sellmoney")/10000,0)
  rs1.movenext
wend
rs1.close

sql2="select * from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"' order by selldate"
rs2.open sql2,conn,1,1
while not rs2.eof
  sellday2=split(rs2("selldate"),"-")
  sellplan(cint(sellday2(2)-1))="/"&rs2("dailyplan")
  rs2.movenext
wend
rs2.close
conn.close
j=weekday(cdate(selldate(0)&"/"&selldate(1)&"/1"),2)

json = "{""weekday"":"""&j&""",""endday"":"""&endday&""",""sellmoney"":["
for i=0 to endday-1
  json = json & """"&sellmoney(i)&""","
next
json = Left(json,Len(json)-1)
json = json & "],""sellplan"":["
for i=0 to endday-1
  json = json & """"&sellplan(i)&""","
next
json = Left(json,Len(json)-1)
json = json & "]"
json = json & "}"
response.Write(json)


Set obj = Nothing  
%>