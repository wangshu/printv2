Report Machine 5.61
===================

这是一个报表控件包，For Borland Delphi Versions 5,6,7,2005.100% 源码.

最后更新日期：2006.9.7

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
　　复杂的报表？在Report Machine面前，还会有什么复杂的报表存在吗？
  不，不会有的，因为这是一个功能强大，完全自动化、完全自由设计的报表控件。
  对于一般的主从表，单表，你甚至只需要点动鼠标次数=你的数据字段个数就可以
  完成一个完全自定义的，并且支持用户进行格式修改加工，重新设计格式的报表！
  想想fast report 吧，Report Machine会fast report会的，还会它不会的！
  这是一个完全中文化报表控件，支持delphi5到delphi7，BCB5到BCB6。
  它的最大优点就是：强大与自由！

  　Report Machine目前主要能做的：
　  1、支持屏幕打印，控制方法多样，可以打印全部rxlib控件
  全部InfoPower控件,TDBGrid,TStringGrid,TImage,TEdit等,TDBGridEh,f1book,
  TDecisionGrid等等众多控件。(例子1,例子2,例子3,例子4,例子5) 
　　2、支持最终用户设计、修改报表，只需连接相关的数据源，指出数据的位
  置（设置报表样式），无论是主从表，子报表，套表，都可迅速生成。开发
  一个报表只需几分钟的时间。
　　3、报表样式可以保存为rmf格式，下次可通过读入使用（配合SQL脚本就可以生成
  报表）。并可以把带数据的报表保存为rmp格式，在任何机器上都可以浏览、打印，
  而不需要数据库。
　　4、生成后的报表支持修改，包括字体的设置，边框的设置，修改内容等。
　　5、报表编辑器内自带ado,bde,ibx,Diamond dao,dbisam等数据访问控件，可以
  通过这些控件开发独立的报表制作工具。其使用方法和delphi中的控件是一样的。
　　6、完全、自由自定义页面、边距、字体,标题和页眉页脚，并可以在自认合适的
  地方插入函数来实现当前日期，页合计，总合计等功能,合计字段可以放在页头，分
  组头，并支持条件合计，对分组合计，分页合计，总计等只需简单地设置属性即可。
　　7、完全支持D5--D7，BCB5--BCB6。
　　8、报表中可以在自认合适的事件(on beforeprint,on afterprint等)中加入程
  序脚本，以控制、或实现更复杂的打印效果。
　　9、更新迅速，可根据使用人员与用户的意见，不断的加入新的功能。
　　10、多种格式转换，可以把做出的报表转换为html,xls,pdf,bmp,jpeg等等格式。
　　11、自动对超长记录折行，超长的内容也会自动折行，中文换行不会乱码。
　　12、首家支持缩放打印功能，可以根据打印时选择的纸张自动缩放报表。
　　13、首家支持即打即停．
　　14、首家提供类似excel的报表设计器，给你足够灵活方表的报表设计方式。
　　15、首家提供双报表设计器（第一种，第二种），满足所有的需求。
　　16、更是提供类似于ObjectPascal的script,实现特殊功能。
　　17、首家提供web,IntraWeb中的报表解决方案。
　　18、首家提供报表压缩处理，占用内存更少，生成报表速度更快。
　　19、首家提供合并单元格功能，更加适应处理复杂的中文报表。
　　20、自动填空行，每页打印数量等细节处理更完善。

　　最新更新和问题解答请访问论坛: http://www.delphireport.com.cn

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
  
  1.在Delphi IDE中卸载以前的Report Machine版本,然后打开rm_r50.dpk,选"compile",
    在打开rm_d50.dpk,选"Install".
     
    此版我把包分成了Runtime package和Designer package,所以要安装顺序安装

  2.试用版安装方法(以下假设将文件释放到c:\rm目录中)
    (1)Tools->Environments Option->Libary->Libary Path中增加：
                c:\rm\souce
                c:\rm\bpl 
                $(DELPHI)\Lib
                $(DELPHI)\Bin
                $(DELPHI)\Imports
                $(DELPHI)\Projects\Bpl
    (2)Component->Install Packages->Add,选bpl\rm_d70.bpl

6.Demo程序
---------
  Report Machine包含一些例子，这是学习使用Report Machine的最快途径。

  需要用BDE Administrator建立一个Database Alias: 
		名称: RMachineDemo
                Path: 

7.注册
------
  网上注册：http://www.reportmachine.net/gb/html/register.htm
  注册费：个人使用授权:130
          单位使用授权:1300

8.版权声明
----------
  ReportMachine 的软件版权持有人- 王海丰
  本软件中部分代码或idea来自以下控件，在此对以下控件的作者表示感谢:
    FastReport (http://www.fast-report.com)
    TntUnicode (http://home.ccci.org/wolbrink/tnt)
    JEDI VCL (http://sourceforge.net/projects/jvcl)
    TP SysTools (http://sourceforge.net/projects/tpsystools/)
    TB97 (http://www.jrsoftware.org/)

9.感谢
------
  感谢以下网友在ReportMachine开发过程中给予无私的帮助，我在这里谢谢了:
    丁丁(sinmax@163.net)
    小准(xiaochen@jnnj110.gov.cn)
    jim_waw(jim_waw@163.com)
    祝科峰(hzzkf@sina.com)
    arm(425007@sina.com)
    廖伯志(szliaobozhi@21cn.com)
    dejoy(dejoy@ynl.gov.cn)

如果你在使用中有什么问题或建议，或发现BUG,请与作者联系，谢谢!!!

  Report Machine WWW:
     http://www.reportmachine.net
     http://rmachine.yeah.net

  作者:
     wanghaifeng_1@tom.com
