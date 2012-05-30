Report Machine 3.0
===================

这是一个报表控件包，For Borland Delphi Versions 4,5,6,7.100% 源码.

最后更新日期：2003.4.15

目录
-----
  1.说明
  2.特点
  3.最后更新
  4.历史
  5.安装
  6.Demo程序
  7.注册
  8.版权说明
  9.感谢

1.说明
----
  Report Machine是一个报表控件包, Report Machine is reporting 
  tool component. It consists of report engine,designer and preview. Its capabilities 
  comparable with in QuickReport,ReportBuilder. It written on 100% Object Pascal 
  and can be installed in Delphi 4/5/6 and C++Builder 5/6.

2.特点
----
   复杂的报表？在report machine面前，还会有什么复杂的报表存在吗？
不，不会有的，因为这是一个功能强大，完全自动化、完全自由设计的报表控件。
对于一般的主从表，单表，你甚至只需要点动鼠标次数=你的数据字段个数就可以
完成一个完全自定义的，并且支持用户进行格式修改加工，重新设计格式的报表！
想想fast  report  吧，report  machine会fast  report会的，还会它不会的！
这是一个完全中文化报表控件，支持delphi3到delphi6，BCB3到BCB6。
它的最大优点就是：强大与自由！
  
  report  machine目前主要能做的：
  一、支持屏幕打印，控制方法多样，可以打印全部rxlib控件
全部InfoPower控件,TDBGrid,TStringGrid,TImage,TEdit等,TDBGridEh,f1book,
TDecisionGrid等等众多控件。
  二、支持最终用户设计、修改报表，只需连接相关的数据源，指出数据的位
置（设置报表样式），无论是主从表，子报表，套表，都可迅速生成。开发
一个报表只需几分钟的时间。
  三、报表样式可以保存为rmf格式，下次可通过读入使用（配合SQL脚本就可以生成
报表）。并可以把带数据的报表保存为rmp格式，在任何机器上都可以浏览、打印，
而不需要数据库。
  四、生成后的报表支持修改，包括字体的设置，边框的设置，修改内容等。
  五、报表编辑器内自带ado,bde,ibx,Diamond  dao,dbisam等数据访问控件，可以
通过这些控件开发独立的报表制作工具。其使用方法和delphi中的控件是一样的。
  六、完全、自由自定义页面、边距、字体,标题和页眉页脚，并可以在自认合适的
地方插入函数来实现当前日期，页合计，总合计等功能,合计字段可以放在页头，分
组头，并支持条件合计，对分组合计，分页合计，总计等只需简单地设置属性即可。
  七、完全支持d4--d7，c5--c6。
  八、报表中可以在自认合适的事件(on  beforeprint,on  afterprint等)中加入程
序脚本，以控制、或实现更复杂的打印效果。
九、更新迅速，可根据使用人员与用户的意见，不断的加入新的功能。
  十、首家支持缩放打印功能，可以根据打印时选择的纸张自动缩放报表。
  十一、多种格式转换，可以把做出的报表转换为html,xml,bmp,jpeg等等格式。
  十二、自动对超长记录折行，超长的内容也会自动折行。
  十三、最新增加TRMGridReport,类似于电子表格,非常非常适合制作复杂报表

  最新更新和问题解答请访问论坛：www.pcjingning.com

3.最后更新
--------
  v.3.0(Build 2003/04/15)
  - 发布ReportMachine3.0

4.历史记录
--------
  2003.04.15
    Report Machine 3.0


5.安装
-----
  以在delphi5中安装举例,在别的版本delphi中请用相应版本的包,比如在delphi6中,
  rm_r50.dpk换成rm_r60.dpk即可

  1.首先安装tb97，或者将tb97中的源程序释放到c:\rm\source目录中

  2.在Delphi IDE中卸载以前的Report Machine版本,然后打开rm_r50.dpk,选"compile",
    在打开rm_d50.dpk,选"Install".
     
    此版我把包分成了Runtime package和Designer package,所以要安装顺序安装

6.Demo程序
---------
  Report Machine包含一些例子，这是学习使用Report Machine的最快途径。

  http://rmachine.8u8.com/download/demos.rar 
  需要用BDE Administrator建立一个Database Alias: 
		名称: RMachineDemo
                Path: 

7.注册
------
  网上注册：http://rmachine.y365.com/html/register.htm
  汇款地址：天津市蓟县供电局计算站 王海丰  301900  (本地址长期有效，请在汇款单上
            著名email信箱，如不著名，我将无法通知下载方式，最好汇款后,email通知
            我一声)
  注册费：个人使用授权:90
          单位使用授权:900

8.版权声明
----------
  ReportMachine 的软件版权持有人- 王海丰
  本软件中部分代码或idea来自以下控件，在此对以下控件的作者表示感谢:
    FastReport (http://www.fast-report.com)
    TntUnicode (http://home.ccci.org/wolbrink/tnt)
    JEDI VCL (http://sourceforge.net/projects/jvcl)
    TP SysTools (http://sourceforge.net/projects/tpsystools/)

9.感谢
------
  感谢以下网友在ReportMachine开发过程中给予无私的帮助，我在这里谢谢了:
    丁丁(sinmax@163.net)
    小准(xiaochen@jnnj110.gov.cn)
    jim_waw(jim_waw@163.com)
    祝科峰(hzzkf@sina.com)
    arm(425007@sina.com)
    廖伯志(szliaobozhi@21cn.com)

如果你在使用中有什么问题或建议，或发现BUG,请与作者联系，谢谢!!!

  Report Machine WWW:
     http://www.reportmachine.net
     http://rmachine.yeah.net

  作者:
     wanghaifeng_1@163.net
