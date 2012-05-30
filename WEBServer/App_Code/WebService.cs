using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Data.SqlClient; 
using System.Web;
using System.Web.Services;

/// <summary>
///WebService 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。 
// [System.Web.Script.Services.ScriptService]
public class WebService : System.Web.Services.WebService {
    private DbHelper dbh;
    private DbDataReader dbr;
    public WebService () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }

    [WebMethod]
    public bool CheckOpen(String Uid) {
        string sql;
        dbh = new DbHelper();
        sql = string.Format("select count(*) from userinfo where guid='{0}' and  active=1", Uid);
        DbCommand dbc = dbh.GetSqlStringCommond(sql);
        String s = dbh.ExecuteScalar(dbc).ToString();
        if (s.Equals("1"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    [WebMethod]
    public string CheckVersion()
    {
        String Sql = "select version from version where id in(select max(id)  from version)";
        DbCommand dbc = dbh.GetSqlStringCommond(Sql);
        String s = dbh.ExecuteScalar(dbc).ToString();
        return s;
    }
    
}

