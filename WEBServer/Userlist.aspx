<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Userlist.aspx.cs" Inherits="Userlist" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
     <link rel="stylesheet" type="text/css" href="~/css/stylesheet.css" /> 
</head>
<body>
 <table class=maintable>
  <tr  class=top>
   <td colspan="2">
   <!-- #include file = "top.aspx" -->
   </td>
  </tr>
   <tr>
    <td class="left" >
     <!-- #include file = "left.aspx" -->
    </td>
    <td  class="top">
    
   <form id="form1" runat="server">
    <div>
        <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/UserInfo.aspx">新建用户</asp:HyperLink>
        <asp:GridView ID="GridView1" runat="server" CellPadding="4" ForeColor="#333333" 
            GridLines="None" Height="100%" Width="100%" AutoGenerateColumns="False">
            <RowStyle BackColor="#E3EAEB" />
            <Columns>
                
            <asp:HyperLinkField   DataNavigateUrlFields="id" DataNavigateUrlFormatString="userinfo.aspx?id={0}" DataTextField="guid" HeaderText="用户编号" SortExpression="guid" />
            <asp:HyperLinkField   DataNavigateUrlFields="id" DataNavigateUrlFormatString="userinfo.aspx?id={0}" DataTextField="user_name" HeaderText="用户名" 
                SortExpression="user_name" />
            <asp:BoundField DataField="buy_date" HeaderText="购买日期" 
                SortExpression="buy_date" />
            <asp:BoundField DataField="stop_date" HeaderText="停用日期" 
                SortExpression="stop_date" />
            
            <asp:CheckBoxField DataField="active"  HeaderText="可用状态" 
                SortExpression="active" />
            
    
            </Columns>
            <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#666666" ForeColor="White" HorizontalAlign="Center" />
            <SelectedRowStyle BackColor="#C5BBAF" Font-Bold="True" ForeColor="#333333" />
            <HeaderStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White" />
            <EditRowStyle BackColor="#7C6F57" />
            <AlternatingRowStyle BackColor="White" />
        </asp:GridView>
    
    </div>
    </form>
   </td>
 </tr>
</table>
    
</body>
</html>
