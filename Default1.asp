<%
DBname="fxs"
dim conn,rs
Set conn=Server.CreateObject("ADODB.Connection")
Set rs = Server.CreateObject("ADODB.Recordset")
'strAddr = Server.MapPath("./files/"&request("filename"))
'conn.open "Provider=Microsoft.ACE.OLEDB.12.0;Extended Properties=Excel 8.0;Data Source="&strAddr
'sheetname=split(request("filename"),".")
'sql = "Select * from ["&sheetname(0)&"$]"


conn.open "DSN=fxs"
sql="Select * from 201601"
rs.open sql, Conn, 1, 1
%>
<!doctype html>
<html>
<head>

<link href="css/see_list.css" rel="stylesheet" type="text/css">
<script src="jquery/jquery-1.9.1.min.js"></script>
<style type="text/css">
input{
text-align:center;
width:100px;
}
.green{background-color:#99CC66;}
.yellow{background-color:#FFFF66}
</style>
<script type="text/javascript">
function save_confirm(){
	if(confirm("确认要保存所有修改吗？"))
	{}
	else
	{return false;}
}

$(document).ready(function(e) {
    $("tr").click(function(e) {
		$("input").removeClass("green");
        $(this).find("input").addClass("green");
		});
		
	$(".listtd").keyup(function(e) {
        $(this).find("input").addClass("yellow")
    });
});
</script>
<title>testdata</title>
<meta http-equiv="Content-Type" content="text/html" charset="gb2312">
</head>
<body>
<form action="save.asp" method="post" onSubmit="return save_confirm()" name="form1"> 
  <table border=1 width=80% align=center>
   <tr>

<%
lineID=1
columns=rs.fields.count 
jj=0
while jj<columns
%>

     <th> <%=rs.fields(jj).name%> </th>

<%
	jj=jj+1
wend
%>
   </tr>
   <% while not rs.eof	
 %>
   <tr>
     <%
		ii=0
		while ii<columns	
    		if rs(ii)="0" then				
	    		%><td class=1111> </td>
        	<%else%>
		    	 <td class=1111><%=rs(ii)%></td>
             <%end if%>
     <%
		 ii=ii+1
         wend%>
   </tr>
   <%
  
         lineID=lineID+1  
	 rs.movenext
	 wend
  %>
 </table>
</form>
</br>
<div align="center">
<button type="submit">submit保存</button>
<button type="button" onClick="javascript:window.location.href='Default.asp?action=exit'">back</button>
</div>
</form>
</body>
</html>	
<%
rs.close
%>

