(******************************************************************************
  关于TLegendMap(位于PathFind.pas)的用法
  1、FLegendMap:=TLegendMap.Create;
     FLegendMap.LoadMap('mapfile')
        --成功返回后生成地图数据FLegendMap.MapData[i, j]:TMapData
     FLegendMap.SetStartPos(StartX, StartY,PathSpace)
     Path:=FLegendMap.FindPath(StopX, StopY)
  2、FLegendMap:=TLegendMap.Create;
     FLegendMap.LoadMap('mapfile')
     Path:=FLegendMap.FindPath(StartX,StartY,StopX, StopY,PathSpace)

     其中
     Path为TPath = array of TPoint 为nil时表示不能到达
     第一个值为起点，最后一个值为终点
     High(Path)即路径需要的步数

     PathSpace为离开障碍物多少个象素
******************************************************************************)

(*****************************************************************************
  关于TPathMap的特点
  1、不需要传递地图数据，节省内存的频繁拷贝
  2、可自定义估价函数，根据自己需要产生不同路径

  关于TPathMap的用法
  1、定义估价函数MovingCost(X, Y, Direction: Integer)
     只需根据自定义的地图格式编写)
  2、FPathMap:=TPathMap.Create;
     FPathMap.MakePathMap(MapHeader.width, MapHeader.height, StartX, StartY,MovingCost);
     Path:=FPathMap.FindPathOnMap( EndX, EndY)
     其中Path为TPath = array of TPoint;

  如果不喜欢在TPathMap外部定义估价函数，可继承TPathMap，
  将地图数据的读取和估价函数封装成一个类使用。
*******************************************************************************)
unit PathFind;

interface

uses
  Windows, Classes, SysUtils, Graphics, Math;

type
   //地图元素分类
  TTerrainTypes = (ttNormal, ttSand, ttForest, ttRoad, ttObstacle, ttPath);
  TTerrainParam = record
    CellColor: TColor;
    CellLabel: string[16];
    MoveCost: Integer;
  end;

  TPath = array of TPoint; //路径数组

  TPathMapCell = record //路径图元
    Distance: Integer; //离起点的距离
    Direction: Integer;
  end;
  TPathMapArray = array of array of TPathMapCell; // 路径图存储数组
  pTPathMapArray = ^TPathMapArray;


  TMapHeader = packed record
    wWidth: Word;
    wHeight: Word;
    sTitle: string[16];
    UpdateDate: TDateTime;
    Reserved: array[0..22] of AnsiChar;
  end;

  TMapInfo = packed record
    wBkImg: Word;
    wMidImg: Word;
    wFrImg: Word;
    btDoorIndex: byte; //$80 (巩娄), 巩狼 侥喊 牢郸胶
    btDoorOffset: byte; //摧腮 巩狼 弊覆狼 惑措 困摹, $80 (凯覆/摧塞(扁夯))
    btAniFrame: byte; //$80(Draw Alpha) +  橇贰烙 荐
    btAniTick: byte;
    btArea: byte; //瘤开 沥焊
    btLight: byte; //0..1..4 堡盔 瓤苞
  end;
  pTMapInfo = ^TMapInfo;

  TMapInfoArr = array[0..MaxListSize] of TMapInfo;
  pTMapInfoArr = ^TMapInfoArr;
  TMapInfoArray = array of array of TMapInfo;

  TCellParams = record
    TerrainType: TTerrainTypes;
    OnPath: Boolean;
  end;
  TMapData = array of array of TCellParams; //地图存储数组(算法可识别格式)

  TGetCostFunc = function(X, Y, Direction: Integer; PathWidth: Integer = 0): Integer;

  TPathMap = class //寻路类

  private
    FPath: TPath;
    FRunPath: TPath;
    FFillPathMap: Boolean;
    FFindPathOnMap: Boolean;
    function DirToDX(Direction: Integer): Integer;
    function DirToDY(Direction: Integer): Integer;
  public
    PathMapArray: TPathMapArray;
    Height: Integer;
    Width: Integer;
    GetCostFunc: TGetCostFunc;
    PathWidth: Integer;
    ClientRect: TRect;
    ScopeValue: Integer; //寻找范围
    StartFind: Boolean;
    constructor Create;
    procedure GetClientRect(X1, Y1, X2, Y2: Integer);
    procedure FindPathOnMap(X, Y: Integer);
    procedure WalkToRun(); //把WALK合并成RUN
    procedure WalkToHouseRun();
    procedure ConvertStep;
    function MapX(X: Integer): Integer;
    function MapY(Y: Integer): Integer;
    function LoaclX(X: Integer): Integer;
    function LoaclY(Y: Integer): Integer;
    property Path: TPath read FPath write FPath;
    property RunPath: TPath read FRunPath write FRunPath;
  protected
    function GetCost(X, Y, Direction: Integer): Integer; virtual;
    function FillPathMap(X1, Y1, X2, Y2: Integer): TPathMapArray;

  end;

  TLegendMap = class(TPathMap) //传奇地图读取及寻路类
  private

    MapHeader: TMapHeader;
  public
    //MapData: TMapData;
    Title: string;
    FindCount, BeginX, BeginY, EndX, EndY, FindX, FindY, PathPositionIndex: Integer;
    MapData: TMapInfoArray;
    House: Byte;
    constructor Create;

    procedure Find(StartX, StartY, StopX, StopY: Integer);
    procedure FindPath(StartX, StartY, StopX, StopY: Integer; PathSpace: Integer = 0); overload;
    procedure FindPath(StopX, StopY: Integer); overload;
    procedure SetStartPos(StartX, StartY, PathSpace: Integer);
    procedure Stop;
  protected
    function GetCost(X, Y, Direction: Integer): Integer; override;
  end;

  TWaveCell = record //路线点
    X, Y: Integer; //
    Cost: Integer; //
    Direction: Integer;
  end;

  TWave = class //路线类
  private
    FData: array of TWaveCell;
    FPos: Integer; //
    FCount: Integer; //
    FMinCost: Integer;
    function GetItem: TWaveCell;
  public
    property Item: TWaveCell read GetItem; //
    property MinCost: Integer read FMinCost; // Cost

    constructor Create;
    destructor Destroy; override;
    procedure Add(NewX, NewY, NewCost, NewDirection: Integer); //
    procedure Clear; //FCount
    function Start: Boolean; //
    function Next: Boolean; //
  end;

  TFindPathThread = class(TThread)
  private
    { Private declarations }
    FStartX, FStartY, FStopX, FStopY: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(StartX, StartY, StopX, StopY: Integer);
    destructor Destroy; override;
  end;

const
  TerrainParams: array[TTerrainTypes] of TTerrainParam = (
    (CellColor: clWhite; CellLabel: '平地'; MoveCost: 4),
    (CellColor: clOlive; CellLabel: '沙地'; MoveCost: 6),
    (CellColor: clGreen; CellLabel: '树林'; MoveCost: 10),
    (CellColor: clSilver; CellLabel: '马路'; MoveCost: 2),
    (CellColor: clBlack; CellLabel: '障碍物'; MoveCost: - 1),
    (CellColor: clRed; CellLabel: '路径'; MoveCost: 0));


implementation
uses
  MShare;

constructor TFindPathThread.Create(StartX, StartY, StopX, StopY: Integer);
begin
  FreeOnTerminate := True;
  FStartX := StartX;
  FStartY := StartY;
  FStopX := StopX;
  FStopY := StopY;
  inherited Create(True);
  Resume;
end;

destructor TFindPathThread.Destroy;
begin
  inherited Destroy;
end;

procedure TFindPathThread.Execute;
begin
  LegendMap.FindPath(FStartX, FStartY, FStopX, FStopY);
end;


constructor TWave.Create;
begin
  Clear; //
end;

destructor TWave.Destroy;
begin
  FData := nil; //
  inherited Destroy;
end;

function TWave.GetItem: TWaveCell;
begin
  Result := FData[FPos]; //
end;

procedure TWave.Add(NewX, NewY, NewCost, NewDirection: Integer);
begin
  if FCount >= Length(FData) then //
    SetLength(FData, Length(FData) + 30); //
  with FData[FCount] do
  begin
    X := NewX;
    Y := NewY;
    Cost := NewCost;
    Direction := NewDirection;
  end;
  if NewCost < FMinCost then //NewCost
    FMinCost := NewCost;
  Inc(FCount); //
end;

procedure TWave.Clear;
begin
  FPos := 0;
  FCount := 0;
  FData := nil; //
  FMinCost := High(Integer);
end;

function TWave.Start: Boolean;
begin
  FPos := 0; //
  Result := (FCount > 0); //
end;

function TWave.Next: Boolean;
begin
  Inc(FPos); //
  Result := (FPos < FCount); // false,
end;

{-------------------------------------------------------------------------------}

constructor TPathMap.Create;
begin
  inherited Create;
  ScopeValue := 120; // 寻路范围
end;


//*************************************************************
//    方向编号转为X方向符号
//     7  0  1
//     6  X  2
//     5  4  3
//*************************************************************

function TPathMap.DirToDX(Direction: Integer): Integer;
begin
  case Direction of
    0, 4: Result := 0;
    1..3: Result := 1;
  else
    Result := -1;
  end;
end;

function TPathMap.DirToDY(Direction: Integer): Integer;
begin
  case Direction of
    2, 6: Result := 0;
    3..5: Result := 1;
  else
    Result := -1;
  end;
end;
//*************************************************************
//    从TPathMap中找出 TPath
//*************************************************************


procedure TPathMap.FindPathOnMap(X, Y: Integer);
var
  I: Integer;
  nX, nY: Integer;
  Direction: Integer;
 // PathResult: TPath;
begin
  nX := LoaclX(X);
  nY := LoaclY(Y);
  if (nX < 0) or (nY < 0) or
    (nX >= ClientRect.Right - ClientRect.Left) or (nY >= ClientRect.Bottom - ClientRect.Top)
    then begin
    StartFind := False;
    PathMapArray := nil;
    Exit;
  end;

  if (Length(PathMapArray) <= 0) or (PathMapArray[nY, nX].Distance < 0) then begin
    StartFind := False;
    PathMapArray := nil;
    Exit;
  end;
  FFindPathOnMap := True;

  SetLength(FPath, PathMapArray[nY, nX].Distance + 1);
  while PathMapArray[nY, nX].Distance > 0 do begin
    if not StartFind then Break;
    FPath[PathMapArray[nY, nX].Distance] := Point(nX, nY);
    Direction := PathMapArray[nY, nX].Direction;
    nX := nX - DirToDX(Direction);
    nY := nY - DirToDY(Direction);
  end;
  FPath[0] := Point(nX, nY);
  for I := 0 to Length(FPath) - 1 do
    FPath[I] := Point(MapX(FPath[I].X), MapY(FPath[I].Y));

  ConvertStep;

  FFindPathOnMap := False;
  StartFind := False;
end;

procedure TPathMap.ConvertStep;
begin
  WalkToRun();
 { if (g_MySelf <> nil) and (g_MySelf.m_btHorse > 0) then
    WalkToHouseRun()
  else
    WalkToRun();}
end;

procedure TPathMap.WalkToRun(); //把WALK合并成RUN
  function GetNextDirection(sx, sy, dx, dy: Integer): Byte;
  var
    flagx, flagy: Integer;
  const
    DR_UP = 0;
    DR_UPRIGHT = 1;
    DR_RIGHT = 2;
    DR_DOWNRIGHT = 3;
    DR_DOWN = 4;
    DR_DOWNLEFT = 5;
    DR_LEFT = 6;
    DR_UPLEFT = 7;
  begin
    Result := DR_DOWN;
    if sx < dx then flagx := 1
    else if sx = dx then flagx := 0
    else flagx := -1;
    if abs(sy - dy) > 2
      then if (sx >= dx - 1) and (sx <= dx + 1) then flagx := 0;

    if sy < dy then flagy := 1
    else if sy = dy then flagy := 0
    else flagy := -1;
    if abs(sx - dx) > 2 then if (sy > dy - 1) and (sy <= dy + 1) then flagy := 0;

    if (flagx = 0) and (flagy = -1) then Result := DR_UP;
    if (flagx = 1) and (flagy = -1) then Result := DR_UPRIGHT;
    if (flagx = 1) and (flagy = 0) then Result := DR_RIGHT;
    if (flagx = 1) and (flagy = 1) then Result := DR_DOWNRIGHT;
    if (flagx = 0) and (flagy = 1) then Result := DR_DOWN;
    if (flagx = -1) and (flagy = 1) then Result := DR_DOWNLEFT;
    if (flagx = -1) and (flagy = 0) then Result := DR_LEFT;
    if (flagx = -1) and (flagy = -1) then Result := DR_UPLEFT;
  end;
var
  nDir1, nDir2: Integer;
  I, n01: Integer;
  WalkPath: TPath;
  nStep: Integer;
begin
  FRunPath := nil;
  WalkPath := nil;
  if (FPath <> nil) and (Length(FPath) > 1) then begin
    SetLength(WalkPath, Length(FPath));

    for I := 0 to Length(FPath) - 1 do
      WalkPath[I] := FPath[I];

    //WalkPath := FPath;
    nStep := 0;
    I := 0;
    while True do begin
      if not StartFind then Break;
      if I >= Length(WalkPath) then Break;
      if nStep >= 2 then begin
        nDir1 := GetNextDirection(WalkPath[I - 2].x, WalkPath[I - 2].y, WalkPath[I - 1].x, WalkPath[I - 1].y);
        nDir2 := GetNextDirection(WalkPath[I - 1].x, WalkPath[I - 1].y, WalkPath[I].x, WalkPath[I].y);
        if nDir1 = nDir2 then begin
          WalkPath[I - 1].x := -1;
          WalkPath[I - 1].y := -1;
          nStep := 0;
          //Continue;
        end else begin //需要转向不能合并
          Dec(I);
          nStep := 0;
          Continue;
        end;
      end;
      Inc(nStep);
      Inc(I);
    end;

    n01 := 0;
    for I := 1 to Length(WalkPath) - 1 do begin
      if (WalkPath[I].x <> -1) and (WalkPath[I].y <> -1) then begin
        Inc(n01);
        SetLength(FRunPath, n01);
        FRunPath[n01 - 1] := WalkPath[I];
      end;
    end;
    //for I := 0 to Length(FRunPath) - 1 do
      //DebugOutStr(Format('X:%D Y:%D', [FRunPath[I].x, FRunPath[I].y]));

    Exit;
  end;
  if (FPath <> nil) and (Length(FPath) > 0) then begin
    SetLength(FRunPath, Length(FPath) - 1);
    for I := 1 to Length(FPath) - 1 do
      FRunPath[I - 1] := FPath[I];
  end else begin
    SetLength(FRunPath, 0);
    FRunPath := nil;
  end;
end;

procedure TPathMap.WalkToHouseRun(); //把WALK合并成RUN
  function GetNextDirection(sx, sy, dx, dy: Integer): Byte;
  var
    flagx, flagy: Integer;
  const
    DR_UP = 0;
    DR_UPRIGHT = 1;
    DR_RIGHT = 2;
    DR_DOWNRIGHT = 3;
    DR_DOWN = 4;
    DR_DOWNLEFT = 5;
    DR_LEFT = 6;
    DR_UPLEFT = 7;
  begin
    Result := DR_DOWN;
    if sx < dx then flagx := 1
    else if sx = dx then flagx := 0
    else flagx := -1;
    if abs(sy - dy) > 2
      then if (sx >= dx - 1) and (sx <= dx + 1) then flagx := 0;

    if sy < dy then flagy := 1
    else if sy = dy then flagy := 0
    else flagy := -1;
    if abs(sx - dx) > 2 then if (sy > dy - 1) and (sy <= dy + 1) then flagy := 0;

    if (flagx = 0) and (flagy = -1) then Result := DR_UP;
    if (flagx = 1) and (flagy = -1) then Result := DR_UPRIGHT;
    if (flagx = 1) and (flagy = 0) then Result := DR_RIGHT;
    if (flagx = 1) and (flagy = 1) then Result := DR_DOWNRIGHT;
    if (flagx = 0) and (flagy = 1) then Result := DR_DOWN;
    if (flagx = -1) and (flagy = 1) then Result := DR_DOWNLEFT;
    if (flagx = -1) and (flagy = 0) then Result := DR_LEFT;
    if (flagx = -1) and (flagy = -1) then Result := DR_UPLEFT;
  end;
var
  nDir1, nDir2, nDir3: Integer;
  I, n01: Integer;
  WalkPath: TPath;
  nStep: Integer;
begin
  FRunPath := nil;
  WalkPath := nil;
  if (FPath <> nil) and (Length(FPath) > 1) then begin
    SetLength(WalkPath, Length(FPath));

    for I := 0 to Length(FPath) - 1 do
      WalkPath[I] := FPath[I];

    //WalkPath := FPath;
    nStep := 0;
    I := 0;
    while True do begin
      if not StartFind then Break;
      if I >= Length(WalkPath) then begin
        Break;
      end;
      if nStep >= 3 then begin
        nDir1 := GetNextDirection(WalkPath[I - 3].x, WalkPath[I - 3].y, WalkPath[I - 2].x, WalkPath[I - 2].y);
        nDir2 := GetNextDirection(WalkPath[I - 2].x, WalkPath[I - 2].y, WalkPath[I - 1].x, WalkPath[I - 1].y);
        nDir3 := GetNextDirection(WalkPath[I - 1].x, WalkPath[I - 1].y, WalkPath[I].x, WalkPath[I].y);
        if (nDir1 = nDir2) and (nDir2 = nDir3) then begin
          WalkPath[I - 1].x := -1;
          WalkPath[I - 1].y := -1;
          WalkPath[I - 2].x := -1;
          WalkPath[I - 2].y := -1;
          nStep := 0;
          Continue;
        end else
          if nDir1 = nDir2 then begin
          WalkPath[I - 2].x := -1;
          WalkPath[I - 2].y := -1;
          Dec(I);
          nStep := 0;
          Continue;
        end else
          if nDir2 = nDir3 then begin
          WalkPath[I - 1].x := -1;
          WalkPath[I - 1].y := -1;
          nStep := 0;
          Continue;
        end else begin //需要转向不能合并
          Dec(I);
          nStep := 0;
          Continue;
        end;
      end;
      Inc(nStep);
      Inc(I);
    end;

    n01 := 0;
    for I := 1 to Length(WalkPath) - 1 do begin
      if (WalkPath[I].x <> -1) and (WalkPath[I].y <> -1) then begin
        Inc(n01);
        SetLength(FRunPath, n01);
        FRunPath[n01 - 1] := WalkPath[I];
      end;
    end;
    //for I := 0 to Length(FRunPath) - 1 do
      //DebugOutStr(Format('X:%D Y:%D', [FRunPath[I].x, FRunPath[I].y]));
    Exit;
  end;
  if (FPath <> nil) and (Length(FPath) > 0) then begin
    SetLength(FRunPath, Length(FPath) - 1);
    for I := 1 to Length(FPath) - 1 do
      FRunPath[I - 1] := FPath[I];
  end else begin
    SetLength(FRunPath, 0);
    FRunPath := nil;
  end;
end;

//*************************************************************
//    寻路算法
//    X1,Y1为路径运算起点，X2，Y2为路径运算终点
//*************************************************************


function TPathMap.MapX(X: Integer): Integer;
begin
  Result := X + ClientRect.Left;
end;

function TPathMap.MapY(Y: Integer): Integer;
begin
  Result := Y + ClientRect.Top;
end;

function TPathMap.LoaclX(X: Integer): Integer;
begin
  Result := X - ClientRect.Left;
end;

function TPathMap.LoaclY(Y: Integer): Integer;
begin
  Result := Y - ClientRect.Top;
end;

procedure TPathMap.GetClientRect(X1, Y1, X2, Y2: Integer);
begin
  ClientRect := Bounds(0, 0, Width, Height);
 { ScopeValue := Max(Abs(X1 - X2), Abs(Y1 - Y2));
  ScopeValue := ScopeValue + ScopeValue div 2;
  if Width > ScopeValue then begin
    ClientRect.Left := Max(0, X1 - ScopeValue div 2);
    ClientRect.Right := ClientRect.Left + Min(Width, X1 + ScopeValue div 2);
  end;
  if Height > ScopeValue then begin
    ClientRect.Top := Max(0, Y1 - ScopeValue div 2);
    ClientRect.Bottom := ClientRect.Top + Min(Height, Y1 + ScopeValue div 2);
  end; }
end;

function TPathMap.FillPathMap(X1, Y1, X2, Y2: Integer): TPathMapArray;
var
  OldWave, NewWave: TWave;
  Finished: Boolean;
  I: TWaveCell;
  nX1, nY1, nX2, nY2: Integer;
  procedure PreparePathMap; //初始化PathMapArray
  var
    X, Y: Integer; //
  begin
    SetLength(Result, ClientRect.Bottom - ClientRect.Top, ClientRect.Right - ClientRect.Left);
    for Y := 0 to (ClientRect.Bottom - ClientRect.Top - 1) do begin
      if not StartFind then Exit;
      for X := 0 to (ClientRect.Right - ClientRect.Left - 1) do begin
        if not StartFind then Exit;
        Result[Y, X].Distance := -1;
      end;
    end;
  end;

//计算相邻8个节点的权cost，并合法点加入NewWave(),并更新最小cost
//合法点是指非障碍物且Result[X，Y]中未访问的点
  procedure TestNeighbours;
  var
    X, Y, C, D: Integer;
  begin
    for D := 0 to 7 do
    begin
      X := OldWave.Item.X + DirToDX(D);
      Y := OldWave.Item.Y + DirToDY(D);
      C := GetCost(X, Y, D);
      if (C >= 0) and (Result[Y, X].Distance < 0) then
        NewWave.Add(X, Y, C, D); //
    end;
  end;

  procedure ExchangeWaves; //
  var
    W: TWave;
  begin
    W := OldWave;
    OldWave := NewWave;
    NewWave := W;
    NewWave.Clear;
  end;
begin
  FFillPathMap := True;
  GetClientRect(X1, Y1, X2, Y2);

  nX1 := LoaclX(X1);
  nY1 := LoaclY(Y1);
  nX2 := LoaclX(X2);
  nY2 := LoaclY(Y2);

  if X2 < 0 then nX2 := X2;
  if Y2 < 0 then nY2 := Y2;

  if (X2 >= 0) and (Y2 >= 0) then begin
    if (abs(nX1 - nX2) > (ClientRect.Right - ClientRect.Left)) or
      (abs(nY1 - nY2) > (ClientRect.Bottom - ClientRect.Top)) then begin
      SetLength(Result, 0, 0);
      FFillPathMap := False;
      Exit;
    end;
  end;

  PreparePathMap; // 初始化PathMapArray ,Distance:=-1

  OldWave := TWave.Create;
  NewWave := TWave.Create;
  Result[nY1, nX1].Distance := 0; // 起点Distance:=0
  OldWave.Add(nX1, nY1, 0, 0); //将起点加入OldWave
  TestNeighbours; //

  Finished := ((nX1 = nX2) and (nY1 = nY2)); //检验是否到达终点
  while not Finished do begin
    ExchangeWaves;
    if not StartFind then Break;
    if not OldWave.Start then
      Break;
    repeat
      if not StartFind then Break;
      I := OldWave.Item;
      I.Cost := I.Cost - OldWave.MinCost; // 如果大于MinCost
      if I.Cost > 0 then // 加入NewWave
        NewWave.Add(I.X, I.Y, I.Cost, I.Direction) //更新Cost= cost-MinCost
      else begin //  处理最小COST的点
        if Result[I.Y, I.X].Distance >= 0 then
          Continue;

        Result[I.Y, I.X].Distance := Result[I.Y - DirToDY(I.Direction), I.X -
          DirToDX(I.Direction)].Distance + 1; // 此点 Distance:=上一个点Distance+1

        Result[I.Y, I.X].Direction := I.Direction;
          //
        Finished := ((I.X = nX2) and (I.Y = nY2)); //检验是否到达终点
        if Finished then
          Break;
        TestNeighbours;
      end;
    until not OldWave.Next; //
  end; // OldWave;
  NewWave.Free;
  OldWave.Free;
  FFillPathMap := False;
end;

function TPathMap.GetCost(X, Y, Direction: Integer): Integer;
begin
  Direction := (Direction and 7);
  if (X < 0) or (X >= ClientRect.Right - ClientRect.Left) or (Y < 0) or (Y >= ClientRect.Bottom - ClientRect.Top) then
    Result := -1
  else
    Result := GetCostFunc(X, Y, Direction, PathWidth);
end;

constructor TLegendMap.Create;
begin
  inherited Create;
  StartFind := False;
  FFillPathMap := False;
  FFindPathOnMap := False;
  PathPositionIndex := 0;
  FindCount := 0;
end;

procedure TLegendMap.Stop;
begin
  FPath := nil;
  FRunPath := nil;
  StartFind := False;
  BeginX := -1;
  BeginY := -1;
  EndX := -1;
  EndY := -1;

  FindX := -1;
  FindY := -1;

  g_nAutoWalkX := -1;
  g_nAutoWalkY := -1;
  g_dwAutoWalkTick := GetTickCount;
  PathPositionIndex := 0;
  g_nAutoWalkErrorCount := 0;
  FindCount := 0;
  SetLength(PathMapArray, 0, 0);
  PathMapArray := nil;
end;

procedure TLegendMap.FindPath(StopX, StopY: Integer);
begin
  StartFind := False;
  while FFillPathMap or FFindPathOnMap do
    Sleep(1);

  Inc(FindCount);

  SetLength(PathMapArray, 0, 0);
  PathMapArray := nil;
  FindX := StopX;
  FindY := StopY;
  FPath := nil;
  FRunPath := nil;
  StartFind := True;
  FindPathOnMap(StopX, StopY);
end;

procedure TLegendMap.Find(StartX, StartY, StopX, StopY: Integer);
var
  FindPathThread: TFindPathThread;
begin
  FindPathThread := TFindPathThread.Create(StartX, StartY, StopX, StopY);
end;

procedure TLegendMap.FindPath(StartX, StartY, StopX, StopY: Integer; PathSpace: Integer = 0);
var
  FindPathThread: TFindPathThread;
begin
  StartFind := False;
  while FFillPathMap or FFindPathOnMap do Sleep(1);

  Inc(FindCount);
  SetLength(PathMapArray, 0, 0);
  PathMapArray := nil;
  FRunPath := nil;
  FPath := nil;
  FindX := StopX;
  FindY := StopY;
  PathWidth := PathSpace;
  StartFind := True;
  PathMapArray := FillPathMap(StartX, StartY, StopX, StopY);
  FindPathOnMap(StopX, StopY);
end;

procedure TLegendMap.SetStartPos(StartX, StartY, PathSpace: Integer);
begin
  BeginX := StartX;
  BeginY := StartY;
  PathWidth := PathSpace;
  PathMapArray := FillPathMap(StartX, StartY, -1, -1);
end;

function TLegendMap.GetCost(X, Y, Direction: Integer): Integer;
var
  cost: Integer;
  nX, nY: Integer;
begin
  Direction := (Direction and 7);
  if (X < 0) or (X >= ClientRect.Right - ClientRect.Left) or (Y < 0) or (Y >= ClientRect.Bottom - ClientRect.Top) then
    Result := -1
  else begin
    nX := MapX(X);
    nY := MapY(Y);

    if PlayScene.NewCanWalkEx(nX, nY) then Result := 4 else Result := -1;

    if ((Direction and 1) = 1) and (Result > 0) then // 如果是斜方向,则COST增加
      Result := Result + (Result shr 1); //应为Result*sqt(2),此处近似为1.5
  end;
end;

end.
