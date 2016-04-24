<!--#include file ="config.asp"-->
<script language="jscript" runat="server">  
Array.prototype.get = function(x) { return this[x]; };  
function parseJSON(strJSON) { return eval("(" + strJSON + ")"); }  
</script>  
<%
on error resume next
Dim json, obj  
json = request("wdate")
Set obj = parseJSON(json)  
dim selldate(1)
selldate(0)=obj.wyear
selldate(1)=obj.wmonth
sellplan = split(obj.sellplan,",")
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

dim conn,rs
Set conn=Server.CreateObject("ADODB.Connection")
Set rs = Server.CreateObject("ADODB.Recordset")
conn.open DBstr
sql = "delete from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"'"
conn.execute(sql)
sql="select * from [fxsDB].[dbo].[sellplan] where selldate between '"&selldate(0)&"/"&selldate(1)&"/1' and '"&selldate(0)&"/"&selldate(1)&"/"&endday&"' order by selldate"
rs.open sql,conn,3,2
for i=1 to endday
  rs.addnew
      rs("selldate")=cdate(selldate(0)&"-"&selldate(1)&"-"&i)
      rs("dailyplan")=sellplan(i-1)
	  rs.update
next
rs.close
conn.close
Set obj = Nothing
json="{""state"":"
if Err.Number = 0 then
json=json&"""success"""
else
json=json&"""error"",""errnumber"":"""&Err.Number&""",""errsource"":"""&GBtoUTF8(Err.Source)&""",""errdescription"":"""&GBtoUTF8(Err.Description)&""""
end if
Err.clear
json=json&"}"
response.Write(json)

Function GBtoUTF8(szInput)  
Dim wch, uch, szRet  
Dim x  
Dim nAsc, nAsc2, nAsc3  
  
'如果输入参数为空，则退出函数  
If szInput = "" Then  
GBtoUTF8= szInput  
Exit Function  
End If  
  
'开始转换  
For x = 1 To Len(szInput)  
wch = Mid(szInput, x, 1)  
nAsc = AscW(wch)  
  
If nAsc < 0 Then nAsc = nAsc + 65536  
  
If (nAsc And &HFF80) = 0 Then  
szRet = szRet & wch  
Else 
If (nAsc And &HF000) = 0 Then  
uch = "%" & Hex(((nAsc \ 2 ^ 6)) Or &HC0) & Hex(nAsc And &H3F Or &H80)  
szRet = szRet & uch 
Else 
uch = "%" & Hex((nAsc \ 2 ^ 12) Or &HE0) & "%" & _  
Hex((nAsc \ 2 ^ 6) And &H3F Or &H80) & "%" & _  
Hex(nAsc And &H3F Or &H80) 
szRet = szRet & uch 
End If 
End If 
Next 
  
GBtoUTF8= szRet 
End Function
%>