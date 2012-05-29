using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.Common;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Versioninfo : System.Web.UI.Page
{
    private DbHelper dbh;
    private DbDataReader dbr;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["uname"] == null)
        {
            Response.Write("<script>alert('系统超时或非法登录，请重新登录！');window.location.href='default.aspx';</script>");
        }
        dbh = new DbHelper();
        string sql;
        sql = string.Format("select * from version" );
        DbCommand dbc = dbh.GetSqlStringCommond(sql);
        dbr = dbh.ExecuteReader(dbc);
        this.GridView1.DataSource = dbr;
        this.GridView1.DataBind();
    }
    protected void Button1_Click(object sender, EventArgs e)
    {


        string sql;
        sql =string.Format( "insert version (version,memo) values('{0}','{1}')",this.TextBox1.Text,this.TextBox2.Text);
        DbCommand dbc = dbh.GetSqlStringCommond(sql);
    
        dbh.ExecuteNonQuery(dbc);
        sql = string.Format("select * from version" );
        DbCommand dbc2 = dbh.GetSqlStringCommond(sql);
        dbr = dbh.ExecuteReader(dbc2);
        this.GridView1.DataSource = dbr;
        this.GridView1.DataBind();
        this.TextBox1.Text="";
        this.TextBox2.Text = "";
    }
}
