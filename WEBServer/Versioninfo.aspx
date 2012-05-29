<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Versioninfo.aspx.cs" Inherits="Versioninfo" %>

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
    <td  class=left >
     <!-- #include file = "left.aspx" -->
    </td>
    <td style="width:auto;height:auto" valign="top"> 
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        
        </asp:ScriptManager>
        <table style="width: 100%;">
            <tr>
                <td class="style4">
                    &nbsp;
                </td>
                <td class="style2" colspan="2">
                    &nbsp;
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td class="style6">
                    &nbsp;
                    <asp:Label ID="Label2" runat="server" Text="版本号"></asp:Label>
                </td>
                <td class="style9">
                    &nbsp;
                    <asp:TextBox ID="TextBox2" runat="server" Width="100%" v></asp:TextBox>
                </td>
                <td class="style7">
                </td>
                <td class="style8">
                    &nbsp;
                    <asp:Button ID="Button1" runat="server" onclick="Button1_Click" Text="添加" />
                </td>
            </tr>
            <tr>
                <td class="style4">
                    &nbsp;
                </td>
                <td class="style2" colspan="2">
                    &nbsp;
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td class="style5">
                    <asp:Label ID="Label1" runat="server" Text="版本说明"></asp:Label>
                </td>
                <td class="style3" colspan="2">
                    <asp:TextBox ID="TextBox1" runat="server" Height="100%" Width="114%" 
                        TextMode="MultiLine"></asp:TextBox>
                </td>
                <td class="style1">
                </td>
            </tr>
            <tr>
                <td class="style4">
                    &nbsp;</td>
                <td class="style2" colspan="2">
                    &nbsp;</td>
                <td>
                    &nbsp;</td>
            </tr>
            <tr>
                <td colspan="4">
                    <asp:GridView ID="GridView1" runat="server" CellPadding="4" ForeColor="#333333" 
                        GridLines="None" Width="100%" AutoGenerateColumns=false>
                         <Columns>
                
            
            <asp:BoundField DataField="version" HeaderText="版本" 
                SortExpression="buy_date" />
            <asp:BoundField DataField="memo" HeaderText="备注" 
                SortExpression="stop_date" />
            
             
            
    
            </Columns>
                        <RowStyle BackColor="#E3EAEB" />
                        <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="#666666" ForeColor="White" HorizontalAlign="Center" />
                        <SelectedRowStyle BackColor="#C5BBAF" Font-Bold="True" ForeColor="#333333" />
                        <HeaderStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White" />
                        <EditRowStyle BackColor="#7C6F57" />
                        <AlternatingRowStyle BackColor="White" />
                    </asp:GridView>
                </td>
            </tr>
        </table>
    </div>
    </form>
    </td></tr></table>
</body>
</html>
