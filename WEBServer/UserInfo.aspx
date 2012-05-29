<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserInfo.aspx.cs" Inherits="UserInfo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="~/css/stylesheet.css" /> 
    <style type="text/css">
        .style1
        {
            width: 274px;
        }
        .style2
        {
            width: 233px;
        }
        .style3
        {
            width: 141px;
        }
    </style>
</head>
<body>
 <table class=maintable>
  <tr  class=top>
   <td colspan="2">
   <!-- #include file = "top.aspx" -->
   </td>
  </tr>
   <tr>
    <td  class="left">
     <!-- #include file = "left.aspx" -->
    </td>
    <td style="width:auto;height:auto">
    <form id="form1" runat="server">
    <div>
    
        <table style="width:100%;">
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    <asp:Label ID="Label1" runat="server" Text="用户编号"></asp:Label>
                </td>
                <td class="style2">
                    <asp:TextBox ID="tb_guid" runat="server" ReadOnly="True"></asp:TextBox>
                </td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label2" runat="server" Text="用户名称"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:TextBox ID="tb_username" runat="server"></asp:TextBox>
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label3" runat="server" Text="购买日期"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:TextBox ID="tb_buydate" runat="server"></asp:TextBox>
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label4" runat="server" Text="停用日期"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:TextBox ID="tb_stopdate" runat="server"></asp:TextBox>
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label5" runat="server" Text="用户类型"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:Label ID="Label8" runat="server" Text="Label"></asp:Label>
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label6" runat="server" Text="用户状态"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:RadioButton ID="rb_stop" runat="server" Text="停用" />
                     
                    <asp:RadioButton ID="rb_active" runat="server" Text="活动" />
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td class="style3">
                    &nbsp;</td>
                <td class="style1">
                    &nbsp;</td>
                <td class="style2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td class="style3">
                    </td>
                <td class="style1">
                    <asp:Label ID="Label7" runat="server" Text="备       注"></asp:Label>
                    </td>
                <td class="style2">
                    <asp:TextBox ID="tb_memo" runat="server" Rows="5" Width="100%"></asp:TextBox>
                    </td>
                <td>
                    </td>
            </tr>
        </table>
    
    </div>
    <center>
      <asp:Button ID="Button1" runat="server" onclick="Button1_Click" Text="保存" />
    
    </center>
  </form>
  </td>
   </tr> 
 </table>
</body>
</html>
