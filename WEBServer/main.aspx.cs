using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.Common;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class main : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DbHelper dbh = new DbHelper();
        string user = Request.Form["uname"];
        string psw = Request.Form["psw"];
        string sql = "select count(*) as c from admin where username=@u and password=@p";
        DbCommand cmd = dbh.GetSqlStringCommond(sql);
        SqlParameter[] dbp = new SqlParameter[2];
        dbp[0] = new SqlParameter();
        dbp[0].ParameterName = "@u";
        dbp[0].Value = user;
        dbp[1] = new SqlParameter();
        dbp[1].ParameterName = "@p";
        dbp[1].Value = psw;
        sql = dbh.ExecuteScalar(cmd, dbp).ToString();
        if (sql != "1")
        {
            Response.Write("<script>alert('用户名密码错误，请重新输入！');window.location.href='default.aspx';</script>");

        }
        else
        {
            Session.Timeout = 30;
            Session["uname"] = user;
            Response.Write("<script> window.location.href='userlist.aspx';</script>");
        }
            
    }
}
