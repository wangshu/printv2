using System;
using System.Collections.Generic;
 
using System.Web;
using System.Web.UI;
using System.Data.Common;
using System.Web.UI.WebControls;

public partial class Userlist : System.Web.UI.Page
{
    private DbHelper dbh;
    private DbDataReader dbr;
    protected void Page_Load(object sender, EventArgs e)
    {
         if (Session["uname"] == null)
         {
            Response.Write("<script>alert('系统超时或非法登录，请重新登录！');window.location.href='default.aspx';</script>");
            return;
        }
        dbh = new DbHelper();
        string sql;
        sql = string.Format("select * from userinfo where parent_id='"+Session["uid"].ToString() +"'");
        DbCommand dbc = dbh.GetSqlStringCommond(sql);
        dbr = dbh.ExecuteReader(dbc);
        this.GridView1.DataSource = dbr;
        this.GridView1.DataBind(); 
          
    }
}
