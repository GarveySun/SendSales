<!--#include file ="config.asp"-->
<script language="jscript" runat="server">  
Array.prototype.get = function(x) { return this[x]; };  
function parseJSON(strJSON) { return eval("(" + strJSON + ")"); }  
</script>  
<%
Dim json, obj  
json = request("sdate")
Set obj = parseJSON(json)  
dim selldate(1)
selldate(0)=obj.syear
selldate(1)=obj.smonth

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

dim conn,rs,sellplan(30)
for i=0 to 30 step 1
  sellplan(i)=""
next
Set conn=Server.CreateObject("ADODB.Connection")
Set rs = Server.CreateObject("ADODB.Recordset")
conn.open DBstr
sql="select * from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"' order by selldate"
rs.open sql,conn,1,1
while not rs.eof
  sellday2=split(rs("selldate"),"-")
  sellplan(cint(sellday2(2)-1))=rs("dailyplan")
  rs.movenext
wend
rs.close
conn.close

json = "{""endday"":"""&endday&""",""sellplan"":["
for i=0 to endday-1
  json = json & """"&sellplan(i)&""","
next
json = Left(json,Len(json)-1)
json = json & "]"
json = json & "}"
response.Write(json)


Set obj = Nothing  
%>