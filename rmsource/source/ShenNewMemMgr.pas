{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                       中国人自己的免费第三方开发包                           }
{                   (C)Copyright 2001-2004 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            这一开发包是自由软件，您可以遵照自由软体基金会出版的GNU 较        }
{        宽松通用公共许可证条款来修改和重新发布这一程序，或者用许可证的        }
{        第二版，或者（根据您的选择）用任何更新的版本。                        }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 GNU 较宽松通用公         }
{        共许可证。                                                            }
{                                                                              }
{            您应该已经和开发包一起收到一份 GNU 较宽松通用公共许可证的         }
{        副本。如果还没有，写信给：                                            }
{            Free Software Foundation, Inc., 59 Temple Place - Suite           }
{        330, Boston, MA 02111-1307, USA.                                      }
{                                                                              }
{          原始文件名：CnMemProf.pas                                           }
{            单元作者：Chinbo(Chinbo)                                          }
{            下载地址：http://www.cnvcl.org                                    }
{            电子邮件：master@cnvcl.org                                        }
{                备注：从Delphi技术手册增强而来的内存管理器                    }
{                                                                              }
{******************************************************************************}

unit ShenNewMemMgr;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：内存防护单元
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：使用它的时候要把它放到Project文件的Uses的第一个，不然会出现误报。
*           然后在工程中加上
*             - mmPopupMsgDlg := True;
*               如果有内存泄漏，就弹出对话框
*             - mmShowObjectInfo := True;
*               有内存泄漏，且有RTTI，就会报告对象的类型
*             - 如果觉得程序的运行速度慢，可以设定
*               mmUseObjectList := False;
*               不能够报告详细的内存泄漏的地址以及对象信息，即使设定了
*               mmShowObjectInfo，这样经测试速度跟Delphi自带的速度相仿
*             - 如果不需要内存检查报告，可以设定
*               mmSaveToLogFile := False;
*             - 如果要自定义记录文件，可以设定
*               mmErrLogFile := '你的记录文件名';
*               默认文件名为exe文件的目录下的memory.log
*             - 可以使用SnapToFile过程抓取内存运行状态到指定文件。
*               在程序终止时会OutputDebugString出内存使用状况。
* 开发平台：PWin98SE + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串暂不符合本地化处理方式
* 更新记录：2004.03.29 V1.2
*               为避开D6D7下TypInfo导致的误报，使用编译指令控制 RTTI 信息记录，
*               打开编译开关 LOGRTTI 后可能有误报，比如 uses 了 DB 单元的时候。
*           2003.09.21 V1.1
*               不显示对象信息且有内存泄漏时多添加一个空行方便查看
*               更正了设定mmErrLogFile导致一个内存泄漏的假象
*               原因：在新内存管理器生效之前，mmErrLogFile指向的是引用计数为0的
*             常量，新内存管理器生效之后设定这个变量就向新内存管理器申请了空间，
*             且因为有全局的mmErrLogFile引用该区域，所以引用计数始终大于0，字符
*             串不能在新内存管理器移交之前及时释放，因此造成了内存泄漏的假象。
*           2002.08.06 V1.0
*               创建单元
================================================================================
|</PRE>}

{
  单元本地化处理任务：
    请将该单元中用到的字符串，重新定义到CnConsts.pas单元中（资源字符串）
    存放位置在CnConsts.pas单元的尾部
    
  方法：
    查找字符串，比如'内存管理监视器指针列表溢出，请增大列表项数！'，将它放到
    CnConsts.pas单元中，定义
      SCnMemMgrOutflow = '内存管理监视器指针列表溢出，请增大列表项数！';
    并用SCnMemMgrOutflow来替换原字符串
    
  注意：
    CnConsts中使用了预编译指令，还应定义一份英文的字符串
    如果定义在resourcestrings中的字符串编译通不过，把它放到consts中
    重复出现的字符串用同一个常量代替
    纯符号的字符串不用本地化处理，如') '
    Format函数中的字符串也应进行处理
    处理完后请修改相关的单元版本号、本地化说明   
}

interface

{ $DEFINE LOGRTTI}  // 默认不记录 RTTI 信息，避免D67下的 TypInfo 单元引起的误报

var
  GetMemCount: Integer = 0;
  FreeMemCount: Integer = 0;
  ReallocMemCount: Integer = 0;

  mmPopupMsgDlg: Boolean = True;
  mmShowObjectInfo: Boolean = False;
  mmUseObjectList: Boolean = True;
  mmSaveToLogFile: Boolean = False;
  mmErrLogFile: string[255] = 'c:\memo.txt';

procedure SnapToFile(Filename: string);

implementation

uses
  Windows, SysUtils{$IFDEF LOGRTTI}, TypInfo{$ENDIF};

const
  MaxCount = High(Word);

var
  OldMemMgr: TMemoryManager;
  ObjList: array[0..MaxCount] of Pointer;
  FreeInList: Integer = 0;
  StartTime: DWORD;

{-----------------------------------------------------------------------------
  Procedure: AddToList
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: P: Pointer
  Result:    None
  添加指针
-----------------------------------------------------------------------------}

procedure AddToList(P: Pointer);
begin
  if FreeInList > High(ObjList) then
  begin
    MessageBox(0, '内存管理监视器指针列表溢出，请增大列表项数！',
      '内存管理监视器', mb_ok + mb_iconError);
    Exit;
  end;
  ObjList[FreeInList] := P;
  Inc(FreeInList);
end;

{-----------------------------------------------------------------------------
  Procedure: RemoveFromList
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: P: Pointer
  Result:    None
  移除指针
-----------------------------------------------------------------------------}

procedure RemoveFromList(P: Pointer);
var
  I: Integer;
begin
  for I := Pred(FreeInList) downto 0 do
    if ObjList[I] = P then
    begin
      Dec(FreeInList);
      Move(ObjList[I + 1], ObjList[I], (FreeInList - I) * SizeOf(Pointer));
      Exit;
    end;
end;

{-----------------------------------------------------------------------------
  Procedure: SnapToFile
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: Filename: string
  Result:    None
  Modify:    与月共舞(yygw@yygw.net) 2002.08.06
             为方便本地化处理，进行了一些调整 
             代码可读性比原来下降 :-( 
  抓取快照
-----------------------------------------------------------------------------}

procedure SnapToFile(Filename: string);
var
  OutFile: TextFile;
  I, CurrFree, BlockSize: Integer;
  HeapStatus: THeapStatus;
  NowTime: DWORD;

  {$IFDEF LOGRTTI}
  Item: TObject;
  ptd: PTypeData;
  ppi: PPropInfo;
  {$ENDIF}

{-----------------------------------------------------------------------------
  Procedure: MSELToTime
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: const MSEL: DWORD
  Result:    string
  转换时间
-----------------------------------------------------------------------------}

  function MSELToTime(const MSEL: DWORD): string;
  begin
    Result := Format('%d 小时 %d 分 %d 秒。', [MSEL div 3600000, MSEL div 60000,
      MSEL div 1000]);
  end;

begin
  AssignFile(OutFile, Filename);
  try
    if FileExists(Filename) then
      Append(OutFile)
    else
      Rewrite(OutFile);
    NowTime := GetTickCount - StartTime;
    HeapStatus := GetHeapStatus;
    with HeapStatus do
    begin
      Writeln(OutFile, ':::::::::::::::::::::::::::::::::::::::::::::::::::::');
      Writeln(OutFile, DateTimeToStr(Now));
      Writeln(OutFile);
      Writeln(OutFile, '程序运行时间: ' + MSELToTime(NowTime));
      Writeln(OutFile, Format('可用地址空间: %d 千字节', [TotalAddrSpace div 1024]));
      Writeln(OutFile, Format('未提交部分: %d 千字节', [TotalUncommitted div 1024]));
      Writeln(OutFile, Format('已提交部分: %d 千字节', [TotalCommitted div 1024]));
      Writeln(OutFile, Format('空闲部分: %d 千字节', [TotalFree div 1024]));
      Writeln(OutFile, Format('已分配部分: %d 千字节', [TotalAllocated div 1024]));
      Writeln(OutFile, Format('地址空间载入: %d%%', [TotalAllocated div (TotalAddrSpace div 100)]));
      Writeln(OutFile, Format('全部小空闲内存块: %d 千字节', [FreeSmall div 1024]));
      Writeln(OutFile, Format('全部大空闲内存块: %d 千字节', [FreeBig div 1024]));
      Writeln(OutFile, Format('其它未用内存块: %d 千字节', [Unused div 1024]));
      Writeln(OutFile, Format('内存管理器消耗: %d 千字节', [Overhead div 1024]));
    end; //end with HeapStatus
    CurrFree := FreeInList;
    Writeln(OutFile);
    Write(OutFile, '内存对象数目: ');
    if mmUseObjectList then
    begin
      Write(OutFile, CurrFree);
      if not mmShowObjectInfo then
        Writeln(OutFile);
    end
    else
    begin
      Write(OutFile, GetMemCount - FreeMemCount);
      if GetMemCount = FreeMemCount then
        Write(OutFile, '，没有内存泄漏。')
      else
        Write(OutFile, '。');
      Writeln(OutFile);
    end; //end if mmUseObjectList
    if mmUseObjectList and mmShowObjectInfo then
    begin
      if CurrFree = 0 then
      begin
        Write(OutFile, '，没有内存泄漏。');
        Writeln(OutFile);
      end
      else
      begin
        Writeln(OutFile);
        for I := 0 to CurrFree - 1 do
        begin
          BlockSize := PDWORD(DWORD(ObjList[I]) - 4)^;
          Write(OutFile, Format('%4d) %s - %4d', [I + 1,
            IntToHex(Cardinal(ObjList[I]), 16), BlockSize]));
          Write(OutFile, Format('($%s)字节 - ', [IntToHex(BlockSize, 4)]));

          {$IFDEF LOGRTTI}
          try
            Item := TObject(ObjList[I]);
            //Use RTTI, in IDE may raise exception, But not problems
            if PTypeInfo(Item.ClassInfo).Kind <> tkClass then
              Write(OutFile, '不是对象')
            else
            begin
              ptd := GetTypeData(PTypeInfo(Item.ClassInfo));
              //是否具有名称
              ppi := GetPropInfo(PTypeInfo(Item.ClassInfo), 'Name');
              if ppi <> nil then
              begin
                Write(OutFile, GetStrProp(Item, ppi));
                Write(OutFile, ' : ');
              end
              else
                Write(OutFile, '(未命名): ');
              Write(OutFile, PTypeInfo(Item.ClassInfo).Name);
              Write(OutFile, Format(' (%d 字节) - In %s.pas',
                [ptd.ClassType.InstanceSize, ptd.UnitName]));
            end; //end if GET RTTI
          except
            on Exception do
              Write(OutFile, '不是对象');
          end; //end try
          {$ENDIF}

          Writeln(OutFile);
        end;
      end; //end if CurrFree
    end; //end if mmUseObjectList and mmShowObjectInfo
  finally
    CloseFile(OutFile);
  end; //end try
end;

{-----------------------------------------------------------------------------
  Procedure: NewGetMem
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: Size: Integer
  Result:    Pointer
  分配内存
-----------------------------------------------------------------------------}

function NewGetMem(Size: Integer): Pointer;
begin
  Inc(GetMemCount);
  Result := OldMemMgr.GetMem(Size);
  if mmUseObjectList then
    AddToList(Result);
end;

{-----------------------------------------------------------------------------
  Procedure: NewFreeMem
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: P: Pointer
  Result:    Integer
  释放内存
-----------------------------------------------------------------------------}

function NewFreeMem(P: Pointer): Integer;
begin
  Inc(FreeMemCount);
  Result := OldMemMgr.FreeMem(P);
  if mmUseObjectList then
    RemoveFromList(P);
end;

{-----------------------------------------------------------------------------
  Procedure: NewReallocMem
  Author:    Chinbo(Chinbo)
  Date:      06-八月-2002
  Arguments: P: Pointer; Size: Integer
  Result:    Pointer
  重新分配
-----------------------------------------------------------------------------}

function NewReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  Inc(ReallocMemCount);
  Result := OldMemMgr.ReallocMem(P, Size);
  if mmUseObjectList then
  begin
    RemoveFromList(P);
    AddToList(Result);
  end;
end;

const
  NewMemMgr: TMemoryManager = (
    GetMem: NewGetMem;
    FreeMem: NewFreeMem;
    ReallocMem: NewReallocMem);

initialization
  StartTime := GetTickCount;
  GetMemoryManager(OldMemMgr);
  SetMemoryManager(NewMemMgr);

finalization
  SetMemoryManager(OldMemMgr);
  if (GetMemCount - FreeMemCount) <> 0 then
  begin
    if mmPopupMsgDlg then
      MessageBox(0, PChar(Format('出现 %d 处内存漏洞。',
        [GetMemCount - FreeMemCount])), '内存管理监视器', MB_OK)
    else
      OutputDebugString(PChar(Format('出现 %d 处内存漏洞。', [GetMemCount -
        FreeMemCount])));
  end;
  OutputDebugString(PChar(Format('Get = %d  Free = %d  Realloc = %d',
    [GetMemCount,
    FreeMemCount, ReallocMemCount])));
  if mmErrLogFile = '' then
    mmErrLogFile := ExtractFileDir(ParamStr(0)) + '\Memory.Log';
  if mmSaveToLogFile then
    SnapToFile(mmErrLogFile);

end.

