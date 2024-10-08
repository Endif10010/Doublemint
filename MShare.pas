unit MShare;

interface
uses
  Windows, Classes, SysUtils, Forms, Graphics, Textures, DXDraws, DWinCtl, DrawScrn,
  IntroScn, PlayScn, clEvent, MapUnit, GameImages, Wil, Wis, Wzl, Uib, Fir, Actor, Grobal2, IniFiles, SoundUtil,
  Share, SoundEngn, ClFunc, PathFind, Controls, GuaJi, HashTable;
const
  U_DRESSNAME = '[身上装备 衣服]';
  U_WEAPONNAME = '[身上装备 武器]';
  U_RIGHTHANDNAME = '[身上装备 照明物]';
  U_NECKLACENAME = '[身上装备 项链]';
  U_HELMETNAME = '[身上装备 头盔]';
  U_ARMRINGLNAME = '[身上装备 左手镯]';
  U_ARMRINGRNAME = '[身上装备 右手镯]';
  U_RINGLNAME = '[身上装备 左戒指]';
  U_RINGRNAME = '[身上装备 右戒指]';

  U_BUJUKNAME = '[身上装备 物品]';
  U_BELTNAME = '[身上装备 腰带]';
  U_BOOTSNAME = '[身上装备 鞋子]';
  U_CHARMNAME = '[身上装备 宝石]';
type
  TDBHeader = Integer;
  TQueryBagItem = (q_QueryHum, q_QueryHero);

  TSceneLayer = (t_Actor, t_Control, t_HintMsg, t_Other);
  TTimerCommand = (tcSoftClose, tcReSelConnect, tcFastQueryChr, tcQueryItemPrice);
  TChrAction = (caNone, caWalk, caRun, caHorseRun, caHit, caSpell, caSitdown);
  TConnectionStep = (cnsStart, cnsLogin, cnsSelChr, cnsReSelChr, cnsPlay);

  pTConnectionStep = ^TConnectionStep;

  pTChrAction = ^TChrAction;
  TLoadMode = (lmUseWil, lmUseFir, lmAutoWil, lmAutoFir);
  TMirServer = record
    sServerName: string[30];
    sServeraddr: string[30];
    nServerPort: Integer;
    boFullScreen: Boolean;
    nScreenWidth: Integer;
    nScreenHegiht: Integer;
    nClientCrc: Cardinal;
    nLoginCrc: Cardinal;
  end;
  pTMirServer = ^TMirServer;

  TMapDescInfo = record
    sMapName: string;
    sDescName: string;
    nX, nY: Integer;
    FColor: TColor;
    boBigMap: Boolean;
  end;
  pTMapDescInfo = ^TMapDescInfo;

  TMapDescList = record
    sMapName: string;
    Large: TList;
    Small: TList;
  end;
  pTMapDescList = ^TMapDescList;

  TConfigClient = record
    nSize: Integer;
    nCrc: Cardinal;
    nConfigSize: Integer;

    nDataOffSet: Integer;
    nDataSize: Integer;

    nBackBmpOffSet: Integer;
    nBackBmpSize: Integer;

    nBindItemOffSet: Integer;
    nBindItemSize: Integer;

    nShowItemOffSet: Integer;
    nShowItemSize: Integer;

    nItemDescOffSet: Integer;
    nItemDescSize: Integer;

    btMainInterface: Byte;
    btChatMode: Byte;
    boShowFullScreen: Boolean;

    btItemColor: Byte;

    sPassword: string[50];

    WEffectImg: TLoadMode;
    WDragonImg: TLoadMode;
    WMainImages: TLoadMode;
    WMain2Images: TLoadMode;
    WMain3Images: TLoadMode;
    WChrSelImages: TLoadMode;
    WMMapImages: TLoadMode;
    WHumWingImages: TLoadMode;
    WHum1WingImages: TLoadMode;
    WHum2WingImages: TLoadMode;
    WBagItemImages: TLoadMode;
    WStateItemImages: TLoadMode;
    WDnItemImages: TLoadMode;
    WHumImgImages: TLoadMode;
    WHairImgImages: TLoadMode;
    WHair2ImgImages: TLoadMode;
    WWeaponImages: TLoadMode;
    WMagIconImages: TLoadMode;
    WNpcImgImages: TLoadMode;
    WFirNpcImgImages: TLoadMode;
    WMagicImages: TLoadMode;
    WMagic2Images: TLoadMode;
    WMagic3Images: TLoadMode;
    WMagic4Images: TLoadMode;
    WMagic5Images: TLoadMode;
    WMagic6Images: TLoadMode;
    WHorseImages: TLoadMode;
    WHumHorseImages: TLoadMode;
    WHairHorseImages: TLoadMode;
    WMonImages: array[0..30] of TLoadMode;

    sDomainName: string[255];
    nDomainName: Cardinal;

    sCheckProcessesUrl: string[100];
    PlugArr: array[0..10 - 1] of string[20];
  end;

  TClientOption = record
    nSize: Cardinal;
    nCrc: Cardinal;
    sClosePage1: string[100];
    sClosePage2: string[100];
    boArr: array[0..10 - 1] of Boolean;
    nArr: array[0..10 - 1] of Integer;
  end;
  pTClientOption = ^TClientOption;

  TProcessWindowInfo = record
    Caption: string;
    ChildWindows: TStringList;
    CaptionResult: Boolean;
    ChildResult: Boolean;
  end;
  pTProcessWindowInfo = ^TProcessWindowInfo;

  TItemType = (i_Other, i_HPMPDurg, i_Dress, i_Weapon, i_Jewelry, i_Decoration, i_Decorate, i_All);

  //[其它] [药品] [武器][衣服][头盔][首饰]

{
其他类
药品类
服装类
武器类
首饰类
饰品类
装饰类
}

 { TBindClientItem = record
    btItemType: Byte;
    sItemName: string;
    sBindItemName: string;
  end;
  pTBindClientItem = ^TBindClientItem;}

 {
  TMapWalkXY = record
    nWalkStep: Integer;
    nMonCount: Integer;
    nX: Integer;
    nY: Integer;
  end;
  pTMapWalkXY = ^TMapWalkXY;}

  TShowItem = record
    ItemType: TItemType;
    sItemName: string;
    sItemType: string;
    boHintMsg: Boolean;
    boPickup: Boolean;
    boShowName: Boolean;
    //boSpecial: Boolean;
    //btColor: Byte;
  end;
  pTShowItem = ^TShowItem;

  TShowBoss = record
    sBossName: string[14];
    boShowName: Boolean;
    boHintMsg: Boolean;
    //btColor: Byte;
  end;
  pTShowBoss = ^TShowBoss;

  THintBoss = record
    boHint: Boolean;
    Actor: TActor;
  end;
  pTHintBoss = ^THintBoss;

  THintItem = record
    boHint: Boolean;
    DropItem: pTDropItem;
  end;
  pTHintItem = ^THintItem;

  TMovingItem = record
    Index: Integer;
    Index2: Integer;
    Item: TClientItem;
    Owner: TObject;
  end;
  pTMovingItem = ^TMovingItem;

  TPowerBlock = array[0..100 - 1] of Word;
  TNPCFontColor = array[0..9 - 1] of Byte;

  TServerInfo = record
    sServerCaption: string;
    sServerName: string;
  end;
  pTServerInfo = ^TServerInfo;

  TShopItem = record
    btItemType: Byte;
    nBeginIdx: Integer;
    nEndIdx: Integer;
    StdItem: TStdItem;
    sMemo1: string[20];
    sMemo2: string[150];
  end;
  pTShopItem = ^TShopItem;

  TPlayShopItem = record
    ShopItem: TShopItem;
    nPicturePosition: Integer;
    dwPlaySpeedTick: LongWord;
  end;
  pTPlayShopItem = ^TPlayShopItem;

  TDrawItemEffect = record
    nIndex: Integer;
    btDrawCount: Byte;
    dwDrawTick: LongWord;
  end;
  pTDrawItemEffect = ^TDrawItemEffect;

  TDrawStarsEffect = record
    nIndex: Integer;
    nCount: Integer;
    dwDrawTick: LongWord;
  end;
  pTDrawStarsEffect = ^TDrawStarsEffect;


  TVibration = record
    X, Y: Integer;
  end;


  TUpgradeItems = array[0..2] of TClientItem;

  TSerieMagic = record
    nMagicID: Integer;
    Magic: TClientMagic;
  end;
  pTSerieMagic = ^TSerieMagic;

  TItemDesc = record
    Name: string;
    Desc: string;
  end;
  pTItemDesc = ^TItemDesc;

  TConfig = record
    btMainInterface: Byte; //0仿盛大 1仿征途 2仿外传
    btChatMode: Byte;
    boChangeSpeed: Boolean; //是否变速

    boCanRunHuman: Boolean; //穿人
    boCanRunMon: Boolean; //穿NPC
    boCanRunNpc: Boolean; //穿怪
    boCanStartRun: Boolean; //是否允许免助跑
    boParalyCanRun: Boolean; //麻痹是否可以跑
    boParalyCanWalk: Boolean; //麻痹是否可以走
    boParalyCanHit: Boolean; //麻痹是否可以攻击
    boParalyCanSpell: Boolean; //麻痹是否可以魔法


    //外挂功能变量结束
    boMoveSlow: Boolean; //负重 行动慢
    boAttackSlow: Boolean; //攻击减慢
    boStable: Boolean; //稳如泰山





    btActorLableColor: Byte;
    nStruckChgColor: Integer; //攻击变色

    dwMoveTime: LongWord;
    dwMagicPKDelayTime: LongWord;
    dwSpellTime: LongWord;
    dwHitTime: LongWord;
    dwStepMoveTime: LongWord;
    btHearMsgFColor: Byte; //喊话字体颜色


    //boShowFullScreen: Boolean;

//==================================
    boShowActorLable: Boolean;
    boHideBlueLable: Boolean;
    boShowNumberLable: Boolean; //数字显示
    boShowJobAndLevel: Boolean; //等级和职业
    boShowUserName: Boolean;
    boShowMonName: Boolean;
    boShowItemName: Boolean;
    boShowMoveLable: Boolean;
    boShowGreenHint: Boolean;
    boBGSound: Boolean; //背景音乐
    boItemHint: Boolean;
    boMagicLock: Boolean; //魔法锁定
    boOrderItem: Boolean;
    boOnlyShowCharName: Boolean;
    boPickUpItemAll: Boolean;
    boCloseGroup: Boolean;
    boDuraWarning: Boolean;
    boNotNeedShift: Boolean;
    boAutoHorse: Boolean;
    boCompareItem: Boolean;
//==================================
    boAutoHideMode: Boolean;
    dwAutoHideModeTick: LongWord;
    nAutoHideModeTime: Integer;

    boAutoUseMagic: Boolean;
    nAutoUseMagicIdx: Integer;
    dwAutoUseMagicTick: LongWord;
    nAutoUseMagicTime: Integer;

    dwSmartShieldTick: LongWord;

    boSmartLongHit: Boolean;
    boSmartWideHit: Boolean;
    boSmartFireHit: Boolean;
    boSmartSwordHit: Boolean;
    boSmartCrsHit: Boolean;
    boSmartZrjfHit: Boolean;
    boSmartKaitHit: Boolean;
    boSmartPokHit: Boolean;
    boSmartShield: Boolean;
    boSmartWjzq: Boolean;

    boStruckShield: Boolean;

    dwSmartWjzqTick: LongWord;

    boSmartPosLongHit: Boolean; //隔位刺杀
    boSmartWalkLongHit: Boolean; //走位刺杀
//==================================
    boChangeSign: Boolean;
    boChangePoison: Boolean;
    nPoisonIndex: Integer;
//==================================
    boUseHotkey: Boolean;
    nSerieSkill: Integer;
    nHeroCallHero: Integer;
    nHeroSetTarget: Integer;
    nHeroUnionHit: Integer;
    nHeroSetAttackState: Integer;
    nHeroSetGuard: Integer;
    nSwitchAttackMode: Integer;
    nSwitchMiniMap: Integer;
//=================================
    boHeroControlStatus: Boolean;
//=================================
    boRenewHumHPIsAuto1: Boolean;
    boRenewHumMPIsAuto1: Boolean;

    nRenewHumHPIndex1: Integer;
    nRenewHumMPIndex1: Integer;

    nRenewHumHPTime1: Integer;
    nRenewHumHPPercent1: Integer;

    nRenewHumMPTime1: Integer;
    nRenewHumMPPercent1: Integer;



    boRenewHumHPIsAuto2: Boolean;
    boRenewHumMPIsAuto2: Boolean;

    nRenewHumHPIndex2: Integer;
    nRenewHumMPIndex2: Integer;

    nRenewHumHPTime2: Integer;
    nRenewHumHPPercent2: Integer;

    nRenewHumMPTime2: Integer;
    nRenewHumMPPercent2: Integer;


//=================================

    boRenewHeroHPIsAuto1: Boolean;
    boRenewHeroMPIsAuto1: Boolean;

    nRenewHeroHPIndex1: Integer;
    nRenewHeroMPIndex1: Integer;

    nRenewHeroHPTime1: Integer;
    nRenewHeroHPPercent1: Integer;

    nRenewHeroMPTime1: Integer;
    nRenewHeroMPPercent1: Integer;


    boRenewHeroHPIsAuto2: Boolean;
    boRenewHeroMPIsAuto2: Boolean;

    nRenewHeroHPIndex2: Integer;
    nRenewHeroMPIndex2: Integer;

    nRenewHeroHPTime2: Integer;
    nRenewHeroHPPercent2: Integer;

    nRenewHeroMPTime2: Integer;
    nRenewHeroMPPercent2: Integer;



    boRenewCloseIsAuto: Boolean;
    nRenewCloseTime: Integer;
    nRenewClosePercent: Integer;

    boRenewBookIsAuto: Boolean;
    nRenewBookTime: Integer;
    nRenewBookPercent: Integer;
    nRenewBookNowBookIndex: Integer;
    sRenewBookNowBookItem: string;

    boRenewChangeSignIsAuto: Boolean;
    boRenewChangePoisonIsAuto: Boolean;
    nRenewPoisonIndex: Integer;

    boRenewHeroLogOutIsAuto: Boolean;
    nRenewHeroLogOutTime: Integer;
    nRenewHeroLogOutPercent: Integer;
//==============================================================================
    boGuaji: Boolean;
  end;
  pTConfig = ^TConfig;

  TImageList = class(TObject)
  private
    ImagesArr: array of TGameImages;
    procedure SetIndex(Index: Integer; Images: TGameImages);
    function GetCount: Integer;
  protected
    function ImageOf(Index: Integer): TGameImages; virtual; abstract;
    function IndexOf(Index: Integer): TGameImages; virtual; abstract;
    procedure Initialize(); virtual; abstract;
    procedure Finalize; virtual; abstract;
    property Images[Index: Integer]: TGameImages read ImageOf;
    property Indexs[Index: Integer]: TGameImages read IndexOf write SetIndex;
  public
    constructor Create();
    destructor Destroy; override;
    procedure ClearCache;
    property Count: Integer read GetCount;
  end;

  TMonImageList = class(TImageList)

  private
    function ImageOf(Index: Integer): TGameImages; override;
    function IndexOf(Index: Integer): TGameImages; override;
  public
    procedure Initialize(); override;
    procedure Finalize; override;
    property Images;
    property Indexs;
  end;

  THumImageList = class(TImageList)

  private
  public
    procedure Initialize(); override;
    procedure Finalize; override;
    function GetImage(Dress, Sex, Frame: Integer; var X, Y: Integer): TTexture;
  end;

  TWeaponImageList = class(TImageList)

  private
  public
    procedure Initialize(); override;
    procedure Finalize; override;
    function GetImage(Weapon, Sex, Frame: Integer; var X, Y: Integer): TTexture;
  end;

  TFileItemDB = class
    m_FileItemList: TList;
    m_ShowItemList: THashTable;
  private
  public
    constructor Create();
    destructor Destroy; override;
    function Find(sItemName: string): pTShowItem;
    procedure Get(sItemType: string; var ItemList: TList); overload;
    procedure Get(ItemType: TItemType; var ItemList: TList); overload;
    function Add(ShowItem: pTShowItem): Boolean;
    procedure Hint(DropItem: pTDropItem);
    procedure LoadFormList(LoadList: TStringList);
    procedure LoadFormFile();
    procedure SaveToFile();
    procedure BackUp;
  end;
  TFileBossDB = class
    m_nFileHandle: THandle;
    m_Header: TDBHeader;
    m_DeleteList: TList;
    m_ShowBossList: TList;
    m_HintBossList: TList;
    m_sDBFileName: string;
  private
    function AddRecord(ShowBoss: pTShowBoss; var Index: Integer): Boolean;
    function DelRecord(Index: Integer): Boolean;
  public
    constructor Create(sFileName: string);
    destructor Destroy; override;
    function Open(): Boolean;
    function OpenEx(): Boolean;
    function Find(sBossName: string): pTShowBoss;
    function Add(ShowBoss: pTShowBoss): Boolean;
    procedure AddHintActor(Actor: TActor);
    procedure Hint();
    procedure Delete(sBossName: string);
    procedure Close();
    procedure LoadList();
    procedure SaveToFile();
  end;

  TMapDesc = class

  private
    FStringList: TStringList;
  public
    constructor Create();
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    function Get(const MapName: string; const BigMap: Boolean; var DescList: TList): Boolean;
  end;

var
  DScreen: TDrawScreen;
  IntroScene: TIntroScene;
  LoginScene: TLoginScene;
  SelectChrScene: TSelectChrScene;
  PlayScene: TPlayScene;
  LoginNoticeScene: TLoginNotice;
  EventMan: TClEventManager;
  Map: TMap;

  SoundEngine: TPlaySound;
  NpcImageList: TList;
  ItemImageList: TList;
  WeaponImageList: TList;
  HumImageList: TList;
  g_dwFlipTick: LongWord = 0;
  g_ReceiveList: TGStringList;
  g_sProcMsg: string;
  g_wYear, g_wMonth, g_wDay: Word;
  g_sRunGatePassWord: string = '123456';
  g_sLogoText: string = 'MakeGM';
  g_sGoldName: string = '金币';
  g_sGameGoldName: string = '元宝';
  g_sGamePointName: string = '游戏点';
  g_sWarriorName: string = '武士'; //职业名称
  g_sWizardName: string = '魔法师'; //职业名称
  g_sTaoistName: string = '道士'; //职业名称
  g_sUnKnowName: string = 'Unknown';

  g_MainHandle: THandle;

  g_sMainParam1: string; //读取设置参数
  g_sMainParam2: string; //读取设置参数
  g_sMainParam3: string; //读取设置参数
  g_sMainParam4: string; //读取设置参数
  g_sMainParam5: string; //读取设置参数
  g_sMainParam6: string; //读取设置参数

  g_DXDraw: TDXDraw;
  //g_DWinMan: TDWinManager;
  //g_DXSound: TDXSound;
  //g_Sound: TSoundEngine;
  g_boFullScreen: Boolean = True;

  WhisperName: string;


  g_WisMainImages: TGameImages;
  g_WisMain2Images: TGameImages;
  g_WisMain3Images: TGameImages;

  g_WisDnItemImages: TGameImages;
  g_WisBagItemImages: TGameImages;
  g_WisStateItemImages: TGameImages;
  g_WisWeapon2Images: TGameImages;

  g_cboEffectImg: TGameImages;
  g_cboHairImgImages: TGameImages;
  g_cboHumImgImages: TGameImages;
  g_cboHumWingImages: TGameImages;
  g_cboWeaponImages: TGameImages;

  g_WEffectImg: TGameImages;
  g_WDragonImg: TGameImages;

  g_WMainImages: TGameImages;
  g_WMain2Images: TGameImages;
  g_WMain3Images: TGameImages;
  g_WChrSelImages: TGameImages;
  g_WMMapImages: TGameImages;
  g_WTilesImages: TGameImages;
  g_WSmTilesImages: TGameImages;
  g_WHumWingImages: TGameImages;
  g_WHum1WingImages: TGameImages;
  g_WHum2WingImages: TGameImages;
  g_WBagItemImages: TGameImages;
  g_WStateItemImages: TGameImages;
  g_WDnItemImages: TGameImages;
  g_WHumImgImages: TGameImages;
  g_WHum2ImgImages: TGameImages;
  g_WHairImgImages: TGameImages;
  g_WHair2ImgImages: TGameImages;
  g_WWeaponImages: TGameImages;
  g_WMagIconImages: TGameImages;
  g_WNpcImgImages: TGameImages;
  g_WMagicImages: TGameImages;
  g_WMagic2Images: TGameImages;
  g_WMagic3Images: TGameImages;
  g_WMagic4Images: TGameImages;
  g_WMagic5Images: TGameImages;
  g_WMagic6Images: TGameImages;

  g_WEventEffectImages: TGameImages;
  g_WObjectArr: array[0..19] of TGameImages;

  g_WObjectArr16: array[0..19] of TGameImages;
  g_WTilesImages16: TGameImages;
  g_WSmTilesImages16: TGameImages;

  g_WUIBImages: TUibImages;
  g_WBookImages: TUibImages;
  g_WMiniMapImages: TUibImages;
  g_WCqFirImages: TGameImages;
  g_WHorseImages: TGameImages;
  g_WHumHorseImages: TGameImages;
  g_WHairHorseImages: TGameImages;


  g_WNpcFaceImages: TGameImages;

  g_WFirNpcImgImages: TGameImages;


  g_WMonImages: TMonImageList;

  g_PowerBlock: TPowerBlock = (//10
    $55, $8B, $EC, $83, $C4, $E8, $89, $55, $F8, $89, $45, $FC, $C7, $45, $EC, $E8,
    $03, $00, $00, $C7, $45, $E8, $64, $00, $00, $00, $DB, $45, $EC, $DB, $45, $E8,
    $DE, $F9, $DB, $45, $FC, $DE, $C9, $DD, $5D, $F0, $9B, $8B, $45, $F8, $8B, $00,
    $8B, $55, $F8, $89, $02, $DD, $45, $F0, $8B, $E5, $5D, $C3,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
    );
  g_PowerBlock1: TPowerBlock = (
    $55, $8B, $EC, $83, $C4, $E8, $89, $55, $F8, $89, $45, $FC, $C7, $45, $EC, $64,
    $00, $00, $00, $C7, $45, $E8, $64, $00, $00, $00, $DB, $45, $EC, $DB, $45, $E8,
    $DE, $F9, $DB, $45, $FC, $DE, $C9, $DD, $5D, $F0, $9B, $8B, $45, $F8, $8B, $00,
    $8B, $55, $F8, $89, $02, $DD, $45, $F0, $8B, $E5, $5D, $C3,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
    );

  g_nThisCRC: Integer;
  g_sServerName: string; //服务器显示名称
  g_sServerMiniName: string; //服务器名称
  g_sServerAddr: string = '127.0.0.1';
  g_nServerPort: Integer = 7000;
  g_sSelChrAddr: string;
  g_nSelChrPort: Integer;
  g_sRunServerAddr: string;
  g_nRunServerPort: Integer;

  g_sSelChrName: string;

  g_boSendLogin: Boolean; //是否发送登录消息
  g_boServerConnected: Boolean;
  g_boServerConnecting: Boolean = False;
  g_SoftClosed: Boolean; //小退游戏
  g_ChrAction: TChrAction;
  g_ConnectionStep: TConnectionStep;

  g_boSound: Boolean; //开启声音
  g_boBGSound: Boolean; //开启背景音乐

  g_FontArr: array[0..MAXFONT - 1] of string = (
    '宋体',
    '新宋体',
    '仿宋',
    '楷体',
    'Courier New',
    'Arial',
    'MS Sans Serif',
    'Microsoft Sans Serif'
    );

  g_nCurFont: Integer = 0;
  g_sCurFontName: string = '宋体';


  g_sFontName: string = '楷体';

  g_ImgMixSurface: TTexture;
  g_MiniMapSurface: TTexture;
  g_RandomSurface: TTexture;

  g_btFColor: Byte = 9;
  g_btBColor: Byte = 18;
  g_btAlpha: Byte = 150;

  g_boFirstTime: Boolean;
  g_sMapTitle: string;
  g_nMapMusic: Integer;
  g_sMapMusic: string;
  g_nPlayMusicCount: Integer;

  g_MapDesc: TMapDesc;


  g_ServerList: TStringList;
  g_MagicList: TList; //技能列表
  g_HeroMagicList: TList; //英雄技能列表

  g_GroupMembers: TStringList; //组成员列表
  g_SaveItemList: TList;
  g_MenuItemList: TList;
  g_DropedItemList: TGList; //地面物品列表
  g_ChangeFaceReadyList: TList; //
  g_FreeActorList: TList; //释放角色列表
  g_SoundList: TStringList; //声音列表

  g_nBonusPoint: Integer;
  g_nSaveBonusPoint: Integer;
  g_BonusTick: TNakedAbility;
  g_BonusAbil: TNakedAbility;
  g_NakedAbil: TNakedAbility;
  g_BonusAbilChg: TNakedAbility;

  g_sGuildName: string; //行会名称
  g_sGuildRankName: string; //职位名称

  g_dwLastAttackTick: LongWord; //最后攻击时间(包括物理攻击及魔法攻击)
  g_dwLastMoveTick: LongWord; //最后移动时间
  g_dwLatestStruckTick: LongWord; //最后弯腰时间
  g_dwLatestSpellTick: LongWord; //最后魔法攻击时间
  g_dwLatestFireHitTick: LongWord; //最后列火攻击时间
  g_dwLatestRushRushTick: LongWord; //最后被推动时间
  g_dwLatestHitTick: LongWord; //最后物理攻击时间(用来控制攻击状态不能退出游戏)
  g_dwLatestMagicTick: LongWord; //最后放魔法时间(用来控制攻击状态不能退出游戏)

  g_dwLatestKTZHitTick: LongWord; //最后开天攻击时间
  g_dwLatestPKJHitTick: LongWord; //最后破空攻击时间
  g_dwLatestZRJFHitTick: LongWord; //最后逐日剑法攻击时间
  g_dwMagicDelayTime: LongWord;
  g_dwMagicPKDelayTime: LongWord;

  g_nMouseCurrX: Integer; //鼠标所在地图位置座标X
  g_nMouseCurrY: Integer; //鼠标所在地图位置座标Y
  g_nMouseX: Integer; //鼠标所在屏幕位置座标X
  g_nMouseY: Integer; //鼠标所在屏幕位置座标Y

  g_nTargetX: Integer; //目标座标
  g_nTargetY: Integer; //目标座标
  g_TargetCret: TActor;
  g_FocusCret: TActor;
  g_MagicTarget: TActor;

  g_boAttackSlow: Boolean; //腕力不够时慢动作攻击.
  g_boMoveSlow: Boolean; //负重不够时慢动作跑
  g_nMoveSlowLevel: Integer;
  g_boMapMoving: Boolean;
  g_boMapMovingWait: Boolean;
  g_boCheckBadMapMode: Boolean; //是否显示相关检查地图信息(用于调试)
  g_boCheckSpeedHackDisplay: Boolean; //是否显示机器速度数据
  g_boShowGreenHint: Boolean;
  g_boShowWhiteHint: Boolean;
  g_boViewMiniMap: Boolean; //是否显示小地图
  g_nViewMinMapLv: Integer; //Jacky 小地图显示模式(0为不显示，1为透明显示，2为清析显示)
  g_nMiniMapIndex: Integer; //小地图号
  g_boShowMiniMapXY: Boolean;
  g_nMinMapX: Integer;
  g_nMinMapY: Integer;

  g_nMinMapMoveX: Integer;
  g_nMinMapMoveY: Integer;

  //NPC 相关
  g_sCurMerchantName: string;
  g_sCurMerchantSay: string;
  g_nCurMerchantFace: Integer;
  g_nCurMerchant: Integer;
  g_nCurMerchantFaceIdx: Integer;

  g_nMDlgX: Integer;
  g_nMDlgY: Integer;
  g_dwChangeGroupModeTick: LongWord;
  g_dwDealActionTick: LongWord;
  g_dwQueryMsgTick: LongWord;
  g_nDupSelection: Integer;

  g_boAllowGroup: Boolean;

  //人物信息相关
  g_nMySpeedPoint: Integer; //敏捷
  g_nMyHitPoint: Integer; //准确
  g_nMyAntiPoison: Integer; //魔法躲避
  g_nMyPoisonRecover: Integer; //中毒恢复
  g_nMyHealthRecover: Integer; //体力恢复
  g_nMySpellRecover: Integer; //魔法恢复
  g_nMyAntiMagic: Integer; //魔法躲避
  g_nMyHungryState: Integer; //饥饿状态
  g_wAvailIDDay: Word;
  g_wAvailIDHour: Word;
  g_wAvailIPDay: Word;
  g_wAvailIPHour: Word;

  g_nMyHeroSpeedPoint: Integer; //敏捷
  g_nMyHeroHitPoint: Integer; //准确
  g_nMyHeroAntiPoison: Integer; //魔法躲避
  g_nMyHeroPoisonRecover: Integer; //中毒恢复
  g_nMyHeroHealthRecover: Integer; //体力恢复
  g_nMyHeroSpellRecover: Integer; //魔法恢复
  g_nMyHeroAntiMagic: Integer; //魔法躲避
  g_nMyHeroHungryState: Integer; //饥饿状态

  g_MySelf: THumActor;
  g_MyHero: THumActor; //我的英雄


  g_MyDrawActor: THumActor; //未用
  g_UseItems: TUseItems;
  g_ItemArr: TItemArr;
  g_HeroUseItems: TUseItems;
  g_HeroItemArr: THeroItemArr;

  g_DrawUseItems: array[0..13] of TDrawItemEffect;
  g_DrawUseItems1: array[0..13] of TDrawItemEffect;
  g_DrawHeroUseItems: array[0..13] of TDrawItemEffect;

  g_DrawItemArr: array[0..45] of TDrawItemEffect;
  g_DrawHeroItemArr: array[0..39] of TDrawItemEffect;

  g_DrawDealRemoteItems: array[0..19] of TDrawItemEffect;
  g_DrawDealItems: array[0..19] of TDrawItemEffect;


  g_DrawUseItems_: array[0..13] of TDrawItemEffect;
  g_DrawUseItems1_: array[0..13] of TDrawItemEffect;
  g_DrawHeroUseItems_: array[0..13] of TDrawItemEffect;

  g_DrawItemArr_: array[0..45] of TDrawItemEffect;
  g_DrawHeroItemArr_: array[0..39] of TDrawItemEffect;

  g_DrawDealRemoteItems_: array[0..19] of TDrawItemEffect;
  g_DrawDealItems_: array[0..19] of TDrawItemEffect;



  g_ItemArrEffect: array[0..MAXHEROBAGITEM - 1] of TDrawItemEffect;
  g_HeroItemArrEffect: array[0..MAXHEROBAGITEM - 1] of TDrawItemEffect;
  g_UseItemsEffect: array[Low(TUseItems)..High(TUseItems)] of TDrawItemEffect;
  g_HeroUseItemsEffect: array[Low(TUseItems)..High(TUseItems)] of TDrawItemEffect;
  g_UseItemsEffect1: array[Low(TUseItems)..High(TUseItems)] of TDrawItemEffect;
  g_DealItemsEffect: array[0..9] of TDrawItemEffect;
  g_DealRemoteItemsEffect: array[0..9] of TDrawItemEffect;

  g_DuelItemsEffect: array[0..4] of TDrawItemEffect;
  g_DuelRemoteItemsEffect: array[0..4] of TDrawItemEffect;

  g_StoreItemsEffect: array[0..14] of TDrawItemEffect;
  g_StoreRemoteItemsEffect: array[0..14] of TDrawItemEffect;

  g_ShopItemsEffect: array[0..4, 0..9] of TDrawItemEffect; //商铺物品
  g_SuperShopItemsEffect: array[0..4] of TDrawItemEffect; //商铺物品

  g_UpgradeItemsEffect: array[0..2] of TDrawItemEffect;

  g_boBagLoaded: Boolean;
  g_boServerChanging: Boolean;

  //键盘相关
  g_ToolMenuHook: HHOOK;
  g_nLastHookKey: Integer;
  g_dwLastHookKeyTime: LongWord;

  g_nCaptureSerial: Integer; //抓图文件名序号
  g_nSendCount: Integer; //发送操作计数
  g_nReceiveCount: Integer; //接改操作状态计数
  g_nTestSendCount: Integer;
  g_nTestReceiveCount: Integer;
  g_nSpellCount: Integer; //使用魔法计数
  g_nSpellFailCount: Integer; //使用魔法失败计数
  g_nFireCount: Integer; //
  g_nDebugCount: Integer;
  g_nDebugCount1: Integer;
  g_nDebugCount2: Integer;

  //买卖相关
  g_SellDlgItem: TClientItem;
  g_SellDlgItemSellWait: TClientItem;
  g_DealDlgItem: TClientItem;
  g_boQueryPrice: Boolean;
  g_dwQueryPriceTime: LongWord;
  g_sSellPriceStr: string;

  //交易相关
  g_DealItems: array[0..9] of TClientItem;
  g_DealRemoteItems: array[0..19] of TClientItem;
  g_nDealGold: Integer;
  g_nDealRemoteGold: Integer;
  g_boDealEnd: Boolean;
  g_sDealWho: string; //交易对方名字
  g_MouseItem: TClientItem;
  g_MouseStateItem: TClientItem;
  g_MouseUserStateItem: TClientItem;

  g_MouseHeroItem: TClientItem;
  g_MouseHeroStateItem: TClientItem;
  g_MouseHeroUserStateItem: TClientItem;

  g_MouseFindUserItem: TClientItem;


  g_btItemMoving: Byte = 0; //物品移动状态
  g_boItemMoving: Boolean; //正在移动物品
  g_MovingItem: TMovingItem;
  g_WaitingUseItem: TMovingItem;
  g_WaitingMoveItemValue: TMovingItem;
  g_WaitingHeroUseItem: TMovingItem;
  g_FocusItem: pTDropItem;
  g_boClearFocusItemMsg: Boolean = False;
  //g_WaitingFindUserItem: TMovingItem;

  g_HintList: TStringList;

  g_boViewFog: Boolean; //是否显示黑暗
  g_boForceNotViewFog: Boolean = False; //免蜡烛
  g_nDayBright: Integer;
  g_nAreaStateValue: Integer; //显示当前所在地图状态(攻城区域、)

  g_boNoDarkness: Boolean;
  g_nRunReadyCount: Integer; //助跑就绪次数，在跑前必须走几步助跑

  g_EatingItem: TClientItem;
  g_dwEatTime: LongWord; //timeout...

  g_HeroEatingItem: TClientItem;
  g_dwHeroEatTime: LongWord; //timeout...

  g_dwDizzyDelayStart: LongWord;
  g_dwDizzyDelayTime: LongWord;

  g_boDoFadeOut: Boolean;
  g_boDoFadeIn: Boolean;
  g_nFadeIndex: Integer;
  g_boDoFastFadeOut: Boolean;

  g_boAutoDig: Boolean; //自动锄矿
  g_boSelectMyself: Boolean; //鼠标是否指到自己

  //游戏速度检测相关变量
  g_dwFirstServerTime: LongWord = 0;
  g_dwFirstClientTime: LongWord = 0;
  //ServerTimeGap: int64;
  g_nTimeFakeDetectCount: Integer = 0;
  g_nServer_ClientTime: Integer = 0;
  g_nSpeedHackCount: Integer = 0;
  g_ClientSpeedTime: TSortStringList;


  g_dwSHGetTime: LongWord = 0;
  g_dwSHTimerTime: LongWord = 0;
  g_nSHFakeCount: Integer = 0; //检查机器速度异常次数，如果超过4次则提示速度不稳定

  g_dwLatestClientTime2: LongWord;
  g_dwFirstClientTimerTime: LongWord; //timer 矫埃
  g_dwLatestClientTimerTime: LongWord;
  g_dwFirstClientGetTime: LongWord; //gettickcount 矫埃
  g_dwLatestClientGetTime: LongWord;
  g_nTimeFakeDetectSum: Integer;
  g_nTimeFakeDetectTimer: Integer;

  g_dwLastestClientGetTime: LongWord;

  //外挂功能变量开始
  g_dwDropItemFlashTime: LongWord = 5 * 1000; //地面物品闪时间间隔
  g_nHitTime: Integer = 1400; //攻击间隔时间间隔
  g_nItemSpeed: Integer = 60;
  g_dwSpellTime: LongWord = 500; //魔法攻间隔时间

  g_nWalkStep: Integer = 1; //走路布数
  g_nRunStep: Integer = 1; //跑步布数

  g_DeathColorEffect: TColorEffect = ceGrayScale;
  g_boClientCanSet: Boolean = True;

  g_boShowPublicMsg: Boolean = True; //公共信息
  g_boShowGroupMsg: Boolean = True; //组队信息
  g_boShowGuildMsg: Boolean = True; //行会信息
  g_boShowWhisperMsg: Boolean = True; //私聊信息
  g_boShowHearMsg: Boolean = True; //喊话信息
  g_boAutoShowHearMsg: Boolean = False; //喊话信息
  g_dwAutoShowMsgTick: LongWord; //自动喊话间隔
  g_sAutoShowMsg: string;

  g_btHearMsgFColor: Byte = $FD;
  g_btWhisperMsgFColor: Byte = $FC; //私聊颜色

  g_boCanRunHuman: Boolean = False; //穿人
  g_boCanRunMon: Boolean = False; //穿NPC
  g_boCanRunNpc: Boolean = False; //穿怪




  g_boCanRunAllInWarZone: Boolean = False;
  g_boCanStartRun: Boolean = True; //是否允许免助跑
  g_boParalyCanRun: Boolean = False; //麻痹是否可以跑
  g_boParalyCanWalk: Boolean = False; //麻痹是否可以走
  g_boParalyCanHit: Boolean = False; //麻痹是否可以攻击
  g_boParalyCanSpell: Boolean = False; //麻痹是否可以魔法

  g_boShowRedHPLable: Boolean = True; //显示血条
  g_boShowHPNumber: Boolean = False; //显示血量数字
  g_boShowJob: Boolean = False; //显示职业
  g_boShowLevel: Boolean = False; //显示等级
  g_boDuraAlert: Boolean = False; //物品持久警告
  g_boMagicLock: Boolean = True; //魔法锁定
  g_boAutoPuckUpItem: Boolean = False;

  g_boShowHumanInfo: Boolean = True;
  g_boShowMonsterInfo: Boolean = False;
  g_boShowNpcInfo: Boolean = False;
  //外挂功能变量结束
  g_dwAutoPickupTick: LongWord;
  g_dwAutoPickupTime: LongWord = 400; //自动捡物品间隔
//  g_AutoPickupList: TList;
  g_MagicLockActor: TActor;
  g_boNextTimePowerHit: Boolean;
  g_boCanLongHit: Boolean;
  g_boCanWideHit: Boolean;
  g_boCanCrsHit: Boolean;
  g_boCanTwnHit: Boolean;
  g_boCanStnHit: Boolean;
  //g_boCanPhHit: Boolean;
  g_boNextTimeFireHit: Boolean;
  g_boNextTimeKTZHit: Boolean;
  g_boNextTimePKJHit: Boolean;

  g_boNextTime60Hit: Boolean;

  g_boNextTimeZRJFHit: Boolean;



  g_nHitCmd: Integer;
  //g_dwCanPhHitTick: LongWord;

  //g_ShowItemList: TGList;
  g_boShowAllItem: Boolean = False; //显示地面所有物品名称

  g_boDrawTileMap: Boolean = True;
  g_boDrawDropItem: Boolean = True;

  g_boShowSysMessage: Boolean = False;

  g_dwAutoFireTick: LongWord = 0;
  g_dwAutoPKJTick: LongWord = 0;
  g_dwAutoKTZTick: LongWord = 0;
  g_dwAutoZRJFTick: LongWord = 0;

  g_nFireHitDelayTime: Integer = 20000;
  g_nKTZHitDelayTime: Integer = 20000;
  g_nPKJHitDelayTime: Integer = 20000;
  g_nSwordHitDelayTime: Integer = 20000;
  //g_dwAutoShieldTick: LongWord = 0;

  g_ShopItems: array[0..4, 0..9] of TShopItem; //商铺物品
  g_SuperShopItems: array[0..4] of TShopItem; //商铺物品

  g_nRankingsTablePage: Integer = 0;
  g_nRankingsTableType: Integer = 0;
  g_nRankingsPage: Integer = -1;
  g_nRankingsPageCount: Integer = 0;
  g_UserLevelRankings: array[0..9] of TUserLevelRanking;
  g_HeroLevelRankings: array[0..9] of THeroLevelRanking;
  g_UserMasterRankings: array[0..9] of TUserMasterRanking;


  g_SellItems: array[1..10] of TClientSellItem;

  g_UpgradeItems: TUpgradeItems;
  g_UpgradeItemsWait: TUpgradeItems;

  g_dwUpgradeItemsWaitTick: LongWord;

  g_MouseSellItems: TClientSellItem;

  g_nSellItemType: Integer = 0;
  g_nSellItemPage: Integer = 0;
  g_nSellItemPageCount: Integer = 0;
  g_sSellItem: string;

  g_boGetSuperShopItems: Boolean = False;

  g_MouseShopItems: TPlayShopItem;

  g_nMerchantPosition: Integer;
  g_MerchantFontColor: TNPCFontColor;
  g_MerchantFontColorTick: LongWord; //GetTickCount;
  g_SelMerchant: Integer;
  g_nUseMerchantCount: Integer;

  g_nMerchantStartType: Integer = -1;
  g_sMerchantReadAddr: string = '';

  g_nDownWorkCount: Integer = 0;
  g_nDownWorkCountMax: Integer = 0;
  g_boDownWorkBegin: Boolean = False;
  g_boDownWorkEnd: Boolean = False;
  g_boStartPlay: Boolean = False;
  g_dwStartPlayTick: LongWord;
  g_nWaiteTime: Integer = 0;
  g_sSongName: string = '';
  g_sDownSongAddr: string = '';

  g_boStartPlayMedia: Boolean = False;

  g_nMoveX: Integer = 0;
  g_nMoveY: Integer = 0;

  g_dwRecallHeroTick: LongWord = 0;
  g_dwFirDragonTick: LongWord = 0;
  g_nFirDragon: Integer = 0;


  //g_nRandomCode: Integer = 0;
  //g_sRandomCode: string = '';

  g_boMiniMize: Boolean = False;
  g_nNewsound: Integer;

  g_dwHeroTogetherUseSpell: LongWord = 0;

  g_nCodeMsgSize: Integer;

  g_OpenBoxingItem: TClientItem;
  g_dwOpenBoxTime: LongWord;

  g_boShowItemBox: Boolean = False;
  g_boOpenItemBox: Boolean = False;
  g_boGetBoxItem: Boolean = False;
  g_boGetBoxItemOK: Boolean = False;

  g_btBoxItem: Byte = 4;
  g_btRandomBoxItem: Byte = 4;
  g_btSelBoxItemIndex: Byte = 4;
  g_btBoxType: Byte = 0;
  g_nBoxIndex: Integer = 0;
  g_nBoxButtonIndex: Integer = 515;
  g_dwOpenBoxTick: LongWord;
  g_dwRandomBoxItemTick: LongWord;
  g_dwShowGetBoxItemButtonTick: LongWord;

  g_dwBoxFlashTick: LongWord;
  g_nBoxTrunCount: Integer = 0;
  g_dwChgSpeed: LongWord = 100;
  g_nChgCount: Integer = 0;
  g_boSelItemOK: Boolean = False;
  g_nBoxFlashIdx: Integer = 0;

  g_BoxItems: array[0..8] of TClientItem;

  g_boBoxItemsVisible: Boolean = False;

  g_nBagItemIndex: Integer = -1;

  g_MoveRect: TRect;

  g_ConfigClient: TConfigClient;

  g_Config: TConfig = (
    boChangeSpeed: False; //是否变速

    boCanRunHuman: True; //穿人
    boCanRunMon: True; //穿NPC
    boCanRunNpc: True; //穿怪
    boCanStartRun: False; //是否允许免助跑
    boParalyCanRun: False; //麻痹是否可以跑
    boParalyCanWalk: False; //麻痹是否可以走
    boParalyCanHit: False; //麻痹是否可以攻击
    boParalyCanSpell: False; //麻痹是否可以魔法

    //外挂功能变量结束
    boMoveSlow: False;
    boAttackSlow: True; //免负重
    boStable: True;

    btActorLableColor: 255;
    nStruckChgColor: 0;

    dwMoveTime: 900;
    dwMagicPKDelayTime: 600;
    dwSpellTime: 500;
    dwHitTime: 1400;
    dwStepMoveTime: 90;
    btHearMsgFColor: 255;

//==================================
    boShowActorLable: True;
    boHideBlueLable: True;
    boShowNumberLable: True; //数字显示
    boShowJobAndLevel: True; //等级和职业
    boShowUserName: True;
    boShowMonName: False;
    boShowItemName: True;
    boShowMoveLable: True;
    boShowGreenHint: False;
    boBGSound: True;
    boItemHint: True;
    boMagicLock: True; //魔法锁定
    boOrderItem: True;
    boOnlyShowCharName: False;
    boPickUpItemAll: True;
    boCloseGroup: True;
    boDuraWarning: True;
    boNotNeedShift: True;
    boAutoHorse: True;
    boCompareItem: True;
//==================================
    boAutoHideMode: False;
    nAutoHideModeTime: 5;
    boAutoUseMagic: False;
    nAutoUseMagicTime: 5;
    dwSmartShieldTick: 0;

    boSmartLongHit: True;
    boSmartWideHit: True;
    boSmartFireHit: True;
    boSmartSwordHit: True;
    boSmartCrsHit: True;
    boSmartZrjfHit: True;
    boSmartKaitHit: True;
    boSmartPokHit: True;
    boSmartShield: True;
    boSmartWjzq: True;
    boStruckShield: True;

    boSmartPosLongHit: True; //隔位刺杀
    boSmartWalkLongHit: False; //走位刺杀

    boChangeSign: False;
    boChangePoison: False;
    nPoisonIndex: 0;
//=========================
    boUseHotkey: False;
    nSerieSkill: 0;
    nHeroCallHero: 0;
    nHeroSetTarget: 0;
    nHeroUnionHit: 0;
    nHeroSetAttackState: 0;
    nHeroSetGuard: 0;
    nSwitchAttackMode: 0;
    nSwitchMiniMap: 0;
//=================================
    boRenewHumHPIsAuto1: False;
    boRenewHumMPIsAuto1: False;

    nRenewHumHPIndex1: - 1;
    nRenewHumMPIndex1: - 1;

    nRenewHumHPTime1: 1;
    nRenewHumHPPercent1: 10;

    nRenewHumMPTime1: 1;
    nRenewHumMPPercent1: 10;



    boRenewHumHPIsAuto2: False;
    boRenewHumMPIsAuto2: False;

    nRenewHumHPIndex2: - 1;
    nRenewHumMPIndex2: - 1;

    nRenewHumHPTime2: 1;
    nRenewHumHPPercent2: 10;

    nRenewHumMPTime2: 1;
    nRenewHumMPPercent2: 10;


//=================================

    boRenewHeroHPIsAuto1: False;
    boRenewHeroMPIsAuto1: False;

    nRenewHeroHPIndex1: - 1;
    nRenewHeroMPIndex1: - 1;

    nRenewHeroHPTime1: 1;
    nRenewHeroHPPercent1: 10;

    nRenewHeroMPTime1: 1;
    nRenewHeroMPPercent1: 10;


    boRenewHeroHPIsAuto2: False;
    boRenewHeroMPIsAuto2: False;

    nRenewHeroHPIndex2: - 1;
    nRenewHeroMPIndex2: - 1;

    nRenewHeroHPTime2: 1;
    nRenewHeroHPPercent2: 10;

    nRenewHeroMPTime2: 1;
    nRenewHeroMPPercent2: 10;



    boRenewCloseIsAuto: False;
    nRenewCloseTime: 30;
    nRenewClosePercent: 10;

    boRenewBookIsAuto: False;
    nRenewBookTime: 3;
    nRenewBookPercent: 100;
    nRenewBookNowBookIndex: - 1;
    sRenewBookNowBookItem: '';

    boRenewChangeSignIsAuto: False;
    boRenewChangePoisonIsAuto: False;
    nRenewPoisonIndex: 0;


    boRenewHeroLogOutIsAuto: False;
    nRenewHeroLogOutTime: 10;
    nRenewHeroLogOutPercent: 10;

//==============================================================================
    boGuaji: False;
    );


  g_ItemDescList: TGStringList; //物品说明
  g_ItemDescFileList: TStringList = nil;
  g_ExtractStringList: TStringList;


  g_UnbindItemList: TList = nil;

  g_UnbindItemFileList: TStringList = nil;
  g_ShowItemFileList: TStringList = nil;
  g_ShowItemList: TFileItemDB;
  g_dwPickUpItemTick: LongWord;
  g_dwHintItemDuraTick: LongWord;


  g_OldItemArr: array[0..5] of TClientItem;


  g_nBookType: Integer = 0;
  g_nBookPage: Integer = 0;

  //挑战相关
  g_DuelItems: array[0..4] of TClientItem;
  g_DuelRemoteItems: array[0..4] of TClientItem;

  g_DrawDuelRemoteItems: array[0..4] of TDrawItemEffect;
  g_DrawDuelItems: array[0..4] of TDrawItemEffect;
  g_DrawDuelRemoteItems_: array[0..4] of TDrawItemEffect;
  g_DrawDuelItems_: array[0..4] of TDrawItemEffect;

  g_nDuelGold: Integer = 0;
  g_nDuelRemoteGold: Integer = 0;
  g_boDuelEnd: Boolean;
  g_sDuelWho: string = ''; //挑战对方名字
  g_dwDuelActionTick: LongWord;
  g_DuelDlgItem: TClientItem;

//摆摊
  g_StoreItems: array[0..14] of TStoreItem;
  g_StoreRemoteItems: array[0..14] of TStoreItem;
  g_DrawStoreItems: array[0..14] of TDrawItemEffect;
  g_DrawStoreRemoteItems: array[0..14] of TDrawItemEffect;
  g_DrawStoreItems_: array[0..14] of TDrawItemEffect;
  g_DrawStoreRemoteItems_: array[0..14] of TDrawItemEffect;
  g_SelectStoreItem: TStoreItem;

  g_boStartStoreing: Boolean = False;
  g_WaitingStoreItem: TMovingItem;
  g_sStoreMasterName: string = '';
  g_nStoreMasterRecogId: Integer = 0;
  g_dwStartStoreTick: LongWord;
  g_dwQueryStoreTick: LongWord;

  g_StarsCount: Integer = 0;
  g_StarsWidth: Integer = 16;
  g_StarsHeigth: Integer = 14;
  g_DrawStarsTick: array[0..255 - 1] of TDrawStarsEffect;
  g_nDrawIndex: Integer = 0;

  g_DrawSnowTick: array[0..12 - 1] of TDrawItemEffect;

  //g_nTopDrawPos: Integer = 0;
  //g_nLeftDrawPos: Integer = 0;

  g_btTest: Byte = 251;

  g_dwLatestFindItemTick: LongWord;

  g_dwProcessKeyTick: LongWord;

  g_boMinimized: Boolean = True;
  g_boCanDraw: Boolean = True;
  boOutbugStr: Boolean = True; //False;
  g_dwLastSpeedHackTick: LongWord = 0;
  g_nSpeedHackIndex: Integer = 0;

  g_dwGetProcessesTick: LongWord;

  g_boGetBoxItemMouseMove: Boolean = False;

  g_btR: Byte;
  g_btG: Byte;
  g_btB: Byte;

  //g_UnbindItemList: TGList = nil;

  g_dwMiniMapTime: LongWord;
  {
  g_boDWinManMouseDown: Boolean = True;
  g_boDWinManMouseUp: Boolean = True;
  g_boDWinManMouseMove: Boolean = True;

  }
  g_boSnow: Boolean = False;
  g_nSnowLev: Integer = 0;
  //g_ShowFormList: TList;

  g_boClose: Boolean = False;
  {
  g_nPos: PInteger;
  g_nLen: PInteger;
  g_nSize: PInteger;
  g_nCrc: PInteger;

  }
  g_Buffer: PAnsiChar;
  g_ConfigBuffer: PAnsiChar;
  g_sConfigBuffer: string;
  g_MemoryStream: TMemoryStream;
  g_sAppFilePath: string;
  g_dwHumLimit: Integer = 30;
  g_ProcessesList: TStringList;
  g_WindowsTitleList: TList;
  g_nProcessIndex: Integer = -1;
  g_ProcessWindowInfo: pTProcessWindowInfo = nil;
  g_dwProcessTime: LongWord;
  g_nProcessInterval: Integer = 2;
  g_dwRunTime: LongWord;


  g_boGetRandomBuffer: Boolean = False;

  g_NewStatus: TNewStatus = sNone;
  g_NewStatusDelayTime: Integer = 0;
  g_nNewStatusX: Integer;
  g_nNewStatusY: Integer;

  g_dwAutoFindPathTick: LongWord;
  g_dwConfusionTick: LongWord;
  g_dwShowVersionBmpTick: LongWord;
  g_dwShowVersionBmpTime: LongWord = 1000 * 3;

  g_dwAutoWalkTick: LongWord;
  g_nAutoWalkX: Integer;
  g_nAutoWalkY: Integer;
  g_nAutoWalkErrorCount: Integer = 0;
  LegendMap: TLegendMap;



  g_dwAutoOrderItemTick: LongWord;
  g_dwMoveItemTick: LongWord;



  g_boReSelConnect: Boolean = False;
  g_dwReSelConnectTick: LongWord;
  g_ClientRect: TRect;




  g_dwRenewHumHPTick1: Longword;
  g_dwRenewHumMPTick1: Longword;
  g_dwRenewHumHPTick2: Longword;
  g_dwRenewHumMPTick2: Longword;

  g_dwRenewHeroHPTick1: Longword;
  g_dwRenewHeroMPTick1: Longword;
  g_dwRenewHeroHPTick2: Longword;
  g_dwRenewHeroMPTick2: Longword;


  g_dwRenewBookTick: Longword;
  g_dwRenewCloseTick: Longword;
  g_dwRenewHeroLogOutTick: Longword;

  g_dwGameLoginHandle: THandle;


  g_boLoadUserConfig: Boolean = False;

  g_nPoisonIndex: Integer = 1;

  g_boShowVersionBmp: Boolean = True;

  //g_nAutoMoveTargetX: Integer = -1; //自动目标座标
  //g_nAutoMoveTargetY: Integer = -1; //自动目标座标
  g_nMapWidth, g_nMapHeight: Integer;
  g_nMapMoveX, g_nMapMoveY: Integer;
  g_nScreenMoveX, g_nScreenMoveY: Integer;
  g_nOScreenMoveX, g_nOScreenMoveY: Integer;

  //g_Path: TPath;
  //g_boDrawPath: Boolean = False;
  g_dwFindPathTick: LongWord;

  //g_nPathPoisonIndex: Integer = 0;

  g_GuaJi: TGuaJi;

  g_MediaList: TGStringList;
  g_dwPlayMediaTick: LongWord;
  g_dwPlayMediaTime: LongWord = 1000;
  g_nPlayMediaCount: Integer = 0;


  g_nSelfThreadProcessId: Integer = 0;


  g_nVibrationPos: Integer = 0;
  g_VibrationValue: array of TVibration;
  g_nVibrationTotal: Integer = 0;
  g_nVibrationCount: Integer = 0;
  g_nVibrationX: Integer = 0;
  g_nVibrationY: Integer = 0;
  g_boVibration: Boolean = False;

  g_SerieMagic: array[0..7] of TSerieMagic;
  g_boSerieMagicing: Boolean = False; //是否正在连击
  g_boSerieMagic: Boolean = False; //是否准备连击

  g_nSerieIndex: Integer = -1;
  g_nCurrenMagic: Integer = -1;
  g_nSerieError: Integer = 0;
  g_dwSerieMagicTick: LongWord;

  g_SerieTarget: TActor;
  g_SerieMagicList: TList;
  g_SerieMagicingList: TList;


  g_QueryBagItem: TQueryBagItem = q_QueryHum;
  g_boQueryHumBagItem: Boolean = False;
  g_boQueryHeroBagItem: Boolean = False;



  //g_BackSurfaces: array[TSceneLayer] of TTexture;


  g_BackSurface: TTexture;

  g_dwWeapon56Tick: array[0..2] of LongWord;
  g_dwWeapon56Index: array[0..2] of Integer;

  g_CartInfoList: TGList;

  g_boHumProtect: Boolean = False;
  g_boHeroProtect: Boolean = False;


  //g_Flib_CS: TRTLCriticalSection;


  g_dwShowEditChatTick: LongWord = 0;
  g_nShowEditChatCount: Integer = 0;
  g_dwShowChatMemoTick: LongWord = 0;
  g_nShowChatMemoCount: Integer = 0;

  g_boStartMoveItemValue: Boolean = False;

  g_ServerEffectImageList: TStringList;
  g_ClientEffectImageList: TStringList;
  g_CreateEffectImageList: TStringList;


  g_boGetCheckProcessesList: Boolean = False;
  g_boGetCheckTitleList: Boolean = False;
  g_boAppClose: Boolean = False;
procedure DebugOutStr(Msg: string);
function GetWinTempDir: string;
function GetDownFileName(sAddr: string): string;
procedure LoadWMImagesLib();
procedure IniTWilImagesLib();
procedure UnLoadWMImagesLib();
procedure FreeOldWMImagesLib();
procedure WMImagesFinalize();
procedure ObjectsClearCache;
procedure ClearWMImagesLib();

function GetObjs(nUnit, nIdx: Integer): TTexture;
function GetObjsEx(nUnit, nIdx: Integer; var px, py: Integer): TTexture;

function GetObjs16(nUnit, nIdx: Integer): TTexture;
function GetObjsEx16(nUnit, nIdx: Integer; var px, py: Integer): TTexture;

function GetMonAction(nAppr: Integer): pTMonsterAction;
function GetJobName(nJob: Integer): string;
function GetSexName(nSex: Integer): string;
procedure UpDataFreeActorList(Actor: TActor);

function GetNpcImg(wAppr: Word; var WMImage: TGameImages): Boolean;
function GetWStateImg(idx: Integer): TTexture; overload;
function GetWStateImg(idx: Integer; var ax, ay: Integer): TTexture; overload;
function GetWWeaponImg(Weapon, m_btSex, nFrame: Integer; var ax, ay: Integer): TTexture;
function GetWHumImg(Dress, m_btSex, nFrame: Integer; var ax, ay: Integer): TTexture;
function GetRGB(c256: Byte): Integer;
function GetRGB16(c256, btBitCount: Byte): Integer;
function CanDraw: Boolean;
procedure PomiTextOut(dsurface: TTexture; X, Y: Integer; Str: string);
function GetActorDir(nX, nY: Integer): string;


function BooleanToStr(boBool: Boolean): string;
procedure ClearMoveRect();
function GetStorePriceName(btType: Byte): string;

function GetInputKey(Key: Integer; var Shift: TShiftState): Word;
function GetKeyDownStr(Key: Word; Shift: TShiftState; var nKey: Integer): string;


procedure LoadBindItemList;
procedure UnLoadBindItemList;
procedure SaveBindItemList;
function FindBindItemName(sItemName: string): string; overload;
function FindBindItemName(btType: Integer): string; overload;
function FindBindItemName(btType: Integer; sItemName: string): string; overload;
function FindUnBindItemName(sItemName: string): string; overload;
function FindUnBindItemName(btType: Integer): string; overload;
function FindUnBindItemName(btType: Integer; sItemName: string): string; overload;

function FindItemArrItemName(btType: Byte): Integer; overload;
function FindItemArrItemName(sItemName: string): Integer; overload;

function FindItemArrBindItemName(btType: Byte): Integer; overload;
function FindItemArrBindItemName(sItemName: string): Integer; overload;

function FindHeroItemArrItemName(btType: Byte): Integer; overload;
function FindHeroItemArrItemName(sItemName: string): Integer; overload;

function FindHeroItemArrBindItemName(btType: Byte): Integer; overload;
function FindHeroItemArrBindItemName(sItemName: string): Integer; overload;

function FindBagItemName(sItemName: string): Integer;


function HeroBagItemCount: Integer;
function BagItemCount: Integer;
function FindHumItemIndex(Index: Integer): Integer;
function FindHeroItemIndex(Index: Integer): Integer;
procedure DeleteBindItem(BindItem: pTBindItemFile);

procedure LoadUserConfig();
procedure SaveUserConfig();

function GetItemType(ItemType: string): TItemType;
function GetItemTypeName(ItemType: TItemType): string;

procedure ActorXYToMapXY(nCurrX, nCurrY: Integer; var nX, nY: Integer);
procedure MapXYToActorXY(nMapX, nMapY: Integer; var nX, nY: Integer);
procedure MapToScreen(nMapWH, nScreenWH, nMapXY: Integer; var nXY: Integer);
procedure ScreenToMap(nMapWH, nScreenWH, nScreenXY: Integer; var nXY: Integer);

procedure LoadItemDescList;
procedure UnLoadItemDescList;
function GetItemDesc(sItemName: string): string;

function GetGameImages(LoadMode: TLoadMode; const FileName: string): TGameImages;
function GetGameImagesFileName(LoadMode: TLoadMode; const FileName: string): string;
procedure UnLoadCartInfoList;

function GetHumUseItemByBagItem(nStdMode: Integer): Integer;
function GetHeroUseItemByBagItem(nStdMode: Integer): Integer;
function GetUseItemName(nIndex: Integer): string;
implementation
uses FState, HUtil32;

function GetUseItemName(nIndex: Integer): string;
begin
  case nIndex of //
    0: Result := U_DRESSNAME;
    1: Result := U_WEAPONNAME;
    2: Result := U_RIGHTHANDNAME;
    3: Result := U_NECKLACENAME;
    4: Result := U_HELMETNAME;
    5: Result := U_ARMRINGLNAME;
    6: Result := U_ARMRINGRNAME;
    7: Result := U_RINGLNAME;
    8: Result := U_RINGRNAME;
    9: Result := U_BUJUKNAME;
    10: Result := U_BELTNAME;
    11: Result := U_BOOTSNAME;
    12: Result := U_CHARMNAME;
  end;
end;

procedure UnLoadCartInfoList;
var
  I: Integer;
begin
  g_CartInfoList.Lock;
  try
    for I := 0 to g_CartInfoList.Count - 1 do begin
      Dispose(pTCartInfo(g_CartInfoList.Items[I]));
    end;
    g_CartInfoList.Clear;
  finally
    g_CartInfoList.UnLock;
  end;
end;

function GetGameImages(LoadMode: TLoadMode; const FileName: string): TGameImages;
var
  sFileName, sFileExt: string;
begin
  Result := nil;
  sFileExt := UpperCase(ExtractFileExt(FileName));

  if sFileExt <> '.WIS' then begin
    sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    if (LoadMode = lmAutoFir) then begin //优先读取DATA文件 如果Data不文件存在则读取WIL
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end else
      if LoadMode = lmAutoWil then begin //优先读取WIL文件 如果WIL文件不存在则读取DATA
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end else
      if LoadMode = lmUseFir then begin //只读取DATA文件
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
    end else
      if LoadMode = lmUseWil then begin //只读取WIL文件
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end;
  end else begin
    sFileName := FileName;
  end;

  {if Comparetext(sFileExt, '.Data') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wil';
    end;
  end;}

  sFileExt := UpperCase(ExtractFileExt(sFileName));

  if sFileExt = '.WIL' then begin
    sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
    if not FileExists(sFileName) then
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wil';
  end else
    if sFileExt = '.WIS' then begin
    sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
    if not FileExists(sFileName) then
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wis';
  end;

  sFileExt := UpperCase(ExtractFileExt(sFileName));
  {
  if Comparetext(sFileExt, '.WIL') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
      if not FileExists(sFileName) then begin
        sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wil';
      end;
    end;
  end else
    if Comparetext(sFileExt, '.WIS') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
      if not FileExists(sFileName) then begin
        sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wis';
      end;
    end;
  end;
  }

  //if FileExists(sFileName) then begin
  if sFileExt = '.DATA' then begin
    Result := TFirImages.Create;
    Result.FileName := sFileName;
  end else
    if sFileExt = '.WIL' then begin
    Result := TWilImages.Create;
    Result.FileName := sFileName;
  end else
    if sFileExt = '.WIS' then begin
    Result := TWisImages.Create;
    Result.FileName := sFileName;
  end else
    if sFileExt = '.WZL' then begin
    Result := TWzlImages.Create;
    Result.FileName := sFileName;
    //DebugOutStr('TWzlImages:'+sFileName);
  end else begin
    Result := TWilImages.Create;
    Result.FileName := sFileName;
  end;
  //DebugOutStr(sFileName);
end;

function GetGameImagesFileName(LoadMode: TLoadMode; const FileName: string): string;
var
  sFileName, sFileExt: string;
begin
  Result := FileName;
  sFileExt := UpperCase(ExtractFileExt(FileName));
  if sFileExt <> '.WIS' then begin
    sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    if (LoadMode = lmAutoFir) then begin //优先读取DATA文件 如果Data不文件存在则读取WIL
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end else
      if LoadMode = lmAutoWil then begin //优先读取WIL文件 如果WIL文件不存在则读取DATA
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
      if not FileExists(sFileName) then
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end else
      if LoadMode = lmUseFir then begin //只读取DATA文件
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.Data';
    end else
      if LoadMode = lmUseWil then begin //只读取WIL文件
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end;
  end else begin
    sFileName := FileName;
  end;

  sFileExt := UpperCase(ExtractFileExt(sFileName));

  if sFileExt = '.WIL' then begin
    sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
    if not FileExists(sFileName) then
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wil';
  end else
    if sFileExt = '.WIS' then begin
    sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wzl';
    if not FileExists(sFileName) then
      sFileName := ExtractFilePath(sFileName) + ExtractFileNameOnly(sFileName) + '.wis';
  end;
  sFileExt := UpperCase(ExtractFileExt(sFileName));
   {
  if Comparetext(ExtractFileExt(sFileName), '.Data') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
    end;
  end;

  if Comparetext(ExtractFileExt(sFileName), '.WIL') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wzl';
      if not FileExists(sFileName) then begin
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wil';
      end;
    end;
  end else
    if Comparetext(ExtractFileExt(sFileName), '.WIS') = 0 then begin
    if not FileExists(sFileName) then begin
      sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wzl';
      if not FileExists(sFileName) then begin
        sFileName := ExtractFilePath(FileName) + ExtractFileNameOnly(FileName) + '.wis';
      end;
    end;
  end;
  }
  Result := sFileName;

end;

procedure LoadItemDescList;
var
  I, npos: Integer;
  sLineText: string;
  LoadList: TStringList;
  ItemDesc: pTItemDesc;
begin
  LoadList := TStringList.Create;
  if FileExists(ITEMDESCFILE) then begin
    try
      LoadList.LoadFromFile(ITEMDESCFILE);
    except
    end;
  end;

  for I := 0 to LoadList.Count - 1 do begin
    sLineText := Trim(LoadList.Strings[I]);
    if (sLineText <> '') and (sLineText[1] <> ';') then begin
      npos := Pos('=', sLineText);
      if npos > 0 then begin
        New(ItemDesc);
        ItemDesc.Name := Trim(Copy(sLineText, 1, npos - 1));
        ItemDesc.desc := Trim(Copy(sLineText, npos + 1, Length(sLineText)));
        g_ItemDescList.AddObject(ItemDesc.Name, TObject(ItemDesc));
      end;
    end;
  end;
  //g_ItemDescList.SaveToFile('g_ItemDescList.txt');
  LoadList.Free;
end;

procedure UnLoadItemDescList;
var
  I: Integer;
begin
  for I := 0 to g_ItemDescList.Count - 1 do begin
    Dispose(pTItemDesc(g_ItemDescList.Objects[I]));
  end;
  g_ItemDescList.Free;
end;

function GetItemDesc(sItemName: string): string;
var
  I: Integer;
  sItemDesc, S: string;
begin
  Result := '';
  sItemDesc := '';
  g_ExtractStringList.Clear;
  if Length(sItemName) > 4 then begin
    if (sItemName[1] = '(') and (sItemName[4] = ')') and (sItemName[2] + sItemName[3] = '绑') then
      sItemName := Copy(sItemName, 5, Length(sItemName) - 4);
  end;
  {if CompareText(sItemName, '(绑)') <> 0 then begin
    sItemName := Copy(sItemName, 5, Length(sItemName) - 4);
  end;}
  //nPos := Pos('(绑)', sItemName);
  //if nPos > 0 then
   //sItemName := Copy(sItemName, 5, Length(sItemName) - 4);
  g_ItemDescList.Lock;
  try
    for I := 0 to g_ItemDescList.Count - 1 do begin
      if CompareText(g_ItemDescList.Strings[I], sItemName) = 0 then begin
        sItemDesc := pTItemDesc(g_ItemDescList.Objects[I]).desc;
        Break;
      end;
    end;
  finally
    g_ItemDescList.UnLock;
  end;
  Result := sItemDesc;
  if sItemDesc <> '' then begin
    if Pos('\', sItemDesc) > 0 then begin
      while True do begin
        if sItemDesc = '' then break;
        sItemDesc := GetValidStr3(sItemDesc, S, ['\']);
        S := Trim(S);
        if S = '' then break;
        g_ExtractStringList.Add(S);
      end;
    end else begin
      g_ExtractStringList.Add(sItemDesc);
    end;
  end;
end;

function GetExtractStrings(sText: string): TStringList;
begin
  Result := g_ExtractStringList;
  g_ExtractStringList.Clear;
end;


procedure ActorXYToMapXY(nCurrX, nCurrY: Integer; var nX, nY: Integer);
begin
  nX := nCurrX * 48 div 32;
  nY := nCurrY * 32 div 32;
end;

procedure MapXYToActorXY(nMapX, nMapY: Integer; var nX, nY: Integer);
begin
  nX := nMapX * 32 div 48;
  nY := nMapY * 32 div 32;
end;

procedure MapToScreen(nMapWH, nScreenWH, nMapXY: Integer; var nXY: Integer);
begin
  nXY := Round(nScreenWH * nMapXY / nMapWH);
end;

procedure ScreenToMap(nMapWH, nScreenWH, nScreenXY: Integer; var nXY: Integer);
begin
  nXY := Round(nMapWH * nScreenXY / nScreenWH);
end;

procedure LoadBindItemList;
var
  I: Integer;
  LoadList: TStringList;
  sFileName: string;
  BindItem: pTBindItemFile;
  sLineText, sType, sItemName, sBindItemName: string;
  nType: Integer;
begin
  //sFileName := BINDITEMFILE;
 {
  LoadList := TStringList.Create;
  if FileExists(sFileName) then begin
    try
      LoadList.LoadFromFile(sFileName);
    except
      LoadList.Clear;
    end;
  end else begin
    LoadList.Add('0' + #9 + '金创药(中量)' + #9 + '金创药(中)包');
    LoadList.Add('1' + #9 + '魔法药(中量)' + #9 + '魔法药(中)包');
    LoadList.Add('0' + #9 + '强效金创药' + #9 + '超级金创药');
    LoadList.Add('1' + #9 + '强效魔法药' + #9 + '超级魔法药');
    LoadList.Add('2' + #9 + '太阳水' + #9 + '太阳水');
    LoadList.Add('2' + #9 + '强效太阳水' + #9 + '强效太阳水');
    LoadList.Add('2' + #9 + '疗伤药' + #9 + '疗伤药包');
    LoadList.Add('2' + #9 + '万年雪霜' + #9 + '雪霜包');
    LoadList.SaveToFile(sFileName);
  end;
  }
  for I := 0 to g_UnbindItemFileList.Count - 1 do begin
    sLineText := Trim(g_UnbindItemFileList.Strings[I]);
    if sLineText = '' then Continue;
    if (sLineText <> '') and (sLineText[1] = ';') then Continue;
    sLineText := GetValidStr3(sLineText, sType, [' ', #9]);
    sLineText := GetValidStr3(sLineText, sItemName, [' ', #9]);
    sLineText := GetValidStr3(sLineText, sBindItemName, [' ', #9]);
    nType := Str_ToInt(sType, -1);
    if (nType in [0..3]) and (sItemName <> '') and (sBindItemName <> '') then begin
      New(BindItem);
      BindItem.btItemType := nType;
      BindItem.sItemName := sItemName;
      BindItem.sBindItemName := sBindItemName;
      g_UnbindItemList.Add(BindItem);
    end;
  end;
end;


procedure UnLoadBindItemList;
var
  I: Integer;
begin
  //if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    Dispose(pTBindItemFile(g_UnbindItemList.Items[I]));
  end;
  FreeAndNil(g_UnbindItemList);
end;

procedure SaveBindItemList;
var
  I: Integer;
  SaveList: TStringList;
  sFileName: string;
  BindItem: pTBindItemFile;
begin
  if g_UnbindItemList = nil then Exit;
  SaveList := TStringList.Create;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    BindItem := pTBindItemFile(g_UnbindItemList.Items[I]);
    SaveList.Add(IntToStr(BindItem.btItemType) + #9 + BindItem.sItemName + #9 + BindItem.sBindItemName);
  end;
  //sFileName := BINDITEMFILE;
  //sFileName := CreateUserDirectory + 'BindItemList.Dat';
  SaveList.SaveToFile(sFileName);
  SaveList.Free;
end;

procedure DeleteBindItem(BindItem: pTBindItemFile);
var
  I: Integer;
begin
  if g_UnbindItemList = nil then Exit;
  for I := g_UnbindItemList.Count - 1 downto 0 do begin
    if g_UnbindItemList.Items[I] = BindItem then begin
      Dispose(pTBindItemFile(g_UnbindItemList.Items[I]));
      g_UnbindItemList.Delete(I);
      Break;
    end;
  end;
end;

function FindBindItemName(btType: Integer): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if pTBindItemFile(g_UnbindItemList.Items[I]).btItemType = btType then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sBindItemName;
      Break;
    end;
  end;
end;

function FindBindItemName(sItemName: string): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if CompareText(pTBindItemFile(g_UnbindItemList.Items[I]).sItemName, sItemName) = 0 then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sBindItemName;
      Break;
    end;
  end;
end;

function FindBindItemName(btType: Integer; sItemName: string): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if (pTBindItemFile(g_UnbindItemList.Items[I]).btItemType = btType) and
      (CompareText(pTBindItemFile(g_UnbindItemList.Items[I]).sBindItemName, sItemName) = 0) then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sBindItemName;
      Break;
    end;
  end;
end;

function FindUnBindItemName(btType: Integer): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if pTBindItemFile(g_UnbindItemList.Items[I]).btItemType = btType then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sItemName;
      Break;
    end;
  end;
end;

function FindUnBindItemName(btType: Integer; sItemName: string): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if (pTBindItemFile(g_UnbindItemList.Items[I]).btItemType = btType) and
      (CompareText(pTBindItemFile(g_UnbindItemList.Items[I]).sItemName, sItemName) = 0) then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sItemName;
      Break;
    end;
  end;
end;

function FindUnBindItemName(sItemName: string): string;
var
  I: Integer;
begin
  Result := '';
  if g_UnbindItemList = nil then Exit;
  for I := 0 to g_UnbindItemList.Count - 1 do begin
    if CompareText(pTBindItemFile(g_UnbindItemList.Items[I]).sItemName, sItemName) = 0 then begin
      Result := pTBindItemFile(g_UnbindItemList.Items[I]).sItemName;
      Break;
    end;
  end;
end;

function FindBagItemName(sItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(g_ItemArr) to High(g_ItemArr) do begin
    if g_ItemArr[I].s.Name <> '' then begin
      if g_ItemArr[I].s.Name = sItemName then begin
        Result := I;
        Break;
      end;
    end;
  end;
end;


function FindItemArrItemName(btType: Byte): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(g_ItemArr) to High(g_ItemArr) do begin
    if g_ItemArr[I].s.Name <> '' then begin
      if FindUnBindItemName(btType, g_ItemArr[I].s.Name) <> '' then begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

function FindItemArrItemName(sItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FindUnBindItemName(sItemName) <> '' then begin
    for I := Low(g_ItemArr) to High(g_ItemArr) do begin
      if g_ItemArr[I].s.Name <> '' then begin
        if g_ItemArr[I].s.Name = sItemName then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function FindItemArrBindItemName(btType: Byte): Integer;
var
  I: Integer;
begin
  Result := -1;
  if BagItemCount <= 40 then begin
    for I := Low(g_ItemArr) to High(g_ItemArr) do begin
      if g_ItemArr[I].s.Name <> '' then begin
        if FindBindItemName(btType, g_ItemArr[I].s.Name) <> '' then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function FindItemArrBindItemName(sItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if BagItemCount <= 40 then begin
    for I := Low(g_ItemArr) + 6 to High(g_ItemArr) do begin
      if g_ItemArr[I].s.Name <> '' then begin
        if CompareText(FindBindItemName(sItemName), g_ItemArr[I].s.Name) = 0 then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function FindHeroItemArrItemName(btType: Byte): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
    if g_HeroItemArr[I].s.Name <> '' then begin
      if FindUnBindItemName(btType, g_HeroItemArr[I].s.Name) <> '' then begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

function FindHeroItemArrItemName(sItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FindUnBindItemName(sItemName) <> '' then begin
    for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
      if g_HeroItemArr[I].s.Name <> '' then begin
        if CompareText(sItemName, g_HeroItemArr[I].s.Name) = 0 then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function FindHeroItemArrBindItemName(btType: Byte): Integer;
var
  I: Integer;
begin
  Result := -1;
  if g_MyHero.m_nBagCount - HeroBagItemCount >= 6 then begin
    for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
      if g_HeroItemArr[I].s.Name <> '' then begin
        if (FindBindItemName(btType, g_HeroItemArr[I].s.Name) <> '') then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function FindHeroItemArrBindItemName(sItemName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if g_MyHero.m_nBagCount - HeroBagItemCount >= 6 then begin
    for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
      if g_HeroItemArr[I].s.Name <> '' then begin
        if (CompareText(FindBindItemName(sItemName), g_HeroItemArr[I].s.Name) = 0) then begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function BagItemCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(g_ItemArr) to High(g_ItemArr) do begin
    if g_ItemArr[I].s.Name <> '' then Inc(Result);
  end;
end;

function HeroBagItemCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
    if g_HeroItemArr[I].s.Name <> '' then Inc(Result);
  end;
end;

function FindHumItemIndex(Index: Integer): Integer;
var
  I: Integer;
  BindItem: pTBindItemFile;
begin
  Result := -1;
  if (Index >= 0) and (Index < g_UnbindItemList.Count) then begin
    BindItem := g_UnbindItemList.Items[Index];
    for I := Low(g_ItemArr) + 6 to High(g_ItemArr) do begin
      if g_ItemArr[I].s.Name <> '' then begin
        if CompareText(BindItem.sItemName, g_ItemArr[I].s.Name) = 0 then begin
          Result := I;
          Exit;
        end;
      end;
    end;
    if BagItemCount <= 40 then begin
      for I := Low(g_ItemArr) to High(g_ItemArr) do begin
        if g_ItemArr[I].s.Name <> '' then begin
          if CompareText(BindItem.sBindItemName, g_ItemArr[I].s.Name) = 0 then begin
            Result := I;
            Exit;
          end;
        end;
      end;
    end;
    for I := Low(g_ItemArr) to High(g_ItemArr) do begin
      if g_ItemArr[I].s.Name <> '' then begin
        if CompareText(BindItem.sItemName, g_ItemArr[I].s.Name) = 0 then begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;
end;

function FindHeroItemIndex(Index: Integer): Integer;
var
  I: Integer;
  BindItem: pTBindItemFile;
begin
  Result := -1;
  if (Index >= 0) and (Index < g_UnbindItemList.Count) then begin
    BindItem := g_UnbindItemList.Items[Index];
    for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
      if g_HeroItemArr[I].s.Name <> '' then begin
        if CompareText(BindItem.sItemName, g_HeroItemArr[I].s.Name) = 0 then begin
          Result := I;
          Exit;
        end;
      end;
    end;
    if g_MyHero.m_nBagCount - HeroBagItemCount >= 6 then begin
      for I := Low(g_HeroItemArr) to High(g_HeroItemArr) do begin
        if g_HeroItemArr[I].s.Name <> '' then begin
          if CompareText(BindItem.sBindItemName, g_HeroItemArr[I].s.Name) = 0 then begin
            Result := I;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function GetInputKey(Key: Integer; var Shift: TShiftState): Word;
begin
  Result := 0;
  Shift := [];
  Result := Loword(Key);
  if Hiword(Key) = 1 then Shift := [ssShift];
  if Hiword(Key) = 2 then Shift := [ssCtrl];
  if Hiword(Key) = 4 then Shift := [ssAlt];
end;

function GetKeyDownStr(Key: Word; Shift: TShiftState; var nKey: Integer): string;
  function GetKey(Key: Word): string;
  begin
    nKey := 0;
    if ((Key >= 48) and (Key <= 57)) or ((Key >= 65) and (Key <= 90)) or
      ((Key >= 96) and (Key <= 105)) then begin
      Result := Chr(Key);
      nKey := Key;
    end;
    if Key = VK_TAB then begin
      nKey := Key;
      Result := 'Tab';
    end;
    if Key = VK_SCROLL then begin
      nKey := Key;
      Result := 'Scroll';
    end;
    if Key in [VK_F1..VK_F12] then begin
      nKey := Key;
      case Key of
        VK_F1: Result := 'F1';
        VK_F2: Result := 'F2';
        VK_F3: Result := 'F3';
        VK_F4: Result := 'F4';
        VK_F5: Result := 'F5';
        VK_F6: Result := 'F6';
        VK_F7: Result := 'F7';
        VK_F8: Result := 'F8';
        VK_F9: Result := 'F9';
        VK_F10: Result := 'F10';
        VK_F11: Result := 'F11';
        VK_F12: Result := 'F12';
      end;
    end;
    if (Key >= 186) and (Key <= 222) then // 其他键
    begin
      nKey := Key;
      case Key of
        186: Result := ';';
        187: Result := '=';
        188: Result := ',';
        189: Result := '-';
        190: Result := '.';
        191: Result := '/';
        192: Result := '`';
        219: Result := '[';
        220: Result := '\';
        221: Result := ']';
        222: Result := Char(27);
      end;
    end;

    if (Key >= 8) and (Key <= 46) then //方向键
    begin
      nKey := Key;
      case Key of
        8: Result := '退格';
        9: Result := 'Tab';
        13: Result := 'Enter';
        32: Result := '空格';
        33: Result := 'PageUp';
        34: Result := 'PageDown';
        35: Result := 'End';
        36: Result := 'Home';
        45: Result := 'Insert';
        46: Result := 'Delete';
      end;
    end;
  end;
var
  nK: Integer;
  sKey: string;
begin
  nK := 0;
  sKey := '';
  Result := '';
  if (Key <> VK_MENU) and (Key <> VK_CONTROL) and (Key <> VK_SHIFT) and (Key <> VK_TAB) and (Key <> VK_SCROLL) and (((Key >= 48) and (Key <= 57)) or ((Key >= 65) and (Key <= 90)) or ((Key >= 96) and (Key <= 105)) or (Key >= 186) and (Key <= 222)) then begin
    if ssShift in Shift then begin
      Result := 'Shift+';
      nK := 1;
    end else
      if ssAlt in Shift then begin
      Result := 'Alt+';
      nK := 4;
    end else
      if ssCtrl in Shift then begin
      Result := 'Ctrl+';
      nK := 2;
    end;
  end;
  sKey := GetKey(Key);
  if sKey <> '' then begin
    nKey := MakeLong(nKey, nK);
    Result := Result + sKey;
  end;
end;

function GetStorePriceName(btType: Byte): string;
begin
  Result := g_sGoldName;
  case btType of
    0: Result := g_sGoldName;
    1: Result := g_sGameGoldName;
    2: Result := '声望';
    3: Result := g_sGamePointName;
  end;
end;

procedure ClearMoveRect();
begin
  FillChar(g_MoveRect, SizeOf(TRect), #0);
end;

procedure PomiTextOut(dsurface: TTexture; X, Y: Integer; Str: string);
var
  I, n: Integer;
  d: TTexture;
begin
  for I := 1 to Length(Str) do begin
    n := Byte(Str[I]) - Byte('0');
    if n in [0..9] then begin
      d := g_WMainImages.Images[30 + n];
      if d <> nil then
        dsurface.Draw(X + I * 8, Y, d.ClientRect, d, True);
    end else begin
      if Str[I] = '-' then begin
        d := g_WMainImages.Images[40];
        if d <> nil then
          dsurface.Draw(X + I * 8, Y, d.ClientRect, d, True);
      end;
    end;
  end;
end;

function CanDraw: Boolean;
begin
  Result := False;
  if g_DXDraw <> nil then begin
    Result := g_DXDraw.CanDraw and (not g_boMinimized) and g_boCanDraw;
  end;
end;

function GetRGB(c256: Byte): Integer;
begin
  Result := RGB(g_DefColorTable[c256].rgbRed,
    g_DefColorTable[c256].rgbGreen,
    g_DefColorTable[c256].rgbBlue);
end;

function GetRGB16(c256, btBitCount: Byte): Integer;
  function MakeColor(r, g, b, BitCount: Byte): dword;
  begin
    if BitCount = 16 then
      Result := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3))
    else
      Result := RGB(b, g, r);
  end;
begin
  Result := MakeColor(g_DefColorTable[c256].rgbRed,
    g_DefColorTable[c256].rgbGreen,
    g_DefColorTable[c256].rgbBlue, btBitCount);
end;

function GetNpcImg(wAppr: Word; var WMImage: TGameImages): Boolean;
var
  I: Integer;
  FileName: string;
begin
  Result := False;
  for I := 0 to NpcImageList.Count - 1 do begin
    WMImage := TGameImages(NpcImageList.Items[I]);
    if WMImage.Appr = wAppr then
    begin
      Result := True;
      Exit;
    end;
  end;
  FileName := ExtractFilePath(Paramstr(0)) + 'Npc' + IntToStr(wAppr) + '.wil';
  WMImage := GetGameImages(g_ConfigClient.WNpcImgImages, FileName);
  WMImage.Appr := wAppr;
  WMImage.Initialize;
  NpcImageList.Add(WMImage);
  Result := True;
end;

function GetWStateImg(idx: Integer; var ax, ay: Integer): TTexture;
var
  I: Integer;
  FileName: string;
  FileIdx: Integer;
  WMImage: TGameImages;
begin
  Result := nil;
  if idx < 10000 then
  begin
    Result := g_WStateItemImages.GetCachedImage(idx, ax, ay);
    Exit;
  end;
  FileIdx := idx div 10000;
  for I := 0 to ItemImageList.Count - 1 do begin
    WMImage := TGameImages(ItemImageList.Items[I]);
    if WMImage.Appr = FileIdx then begin
      Result := WMImage.GetCachedImage(idx - FileIdx * 10000, ax, ay);
      Exit;
    end;
  end;
  FileName := ExtractFilePath(Paramstr(0)) + 'Items' + IntToStr(FileIdx) + '.wil';
  WMImage := GetGameImages(g_ConfigClient.WBagItemImages, FileName);
  WMImage.Appr := FileIdx;
  WMImage.Initialize;
  ItemImageList.Add(WMImage);
  Result := WMImage.GetCachedImage(idx - FileIdx * 10000, ax, ay);
end;

function GetWStateImg(idx: Integer): TTexture;
var
  I: Integer;
  FileName: string;
  FileIdx: Integer;
  WMImage: TGameImages;
begin
  Result := nil;
  if idx < 10000 then begin
    Result := g_WStateItemImages.Images[idx];
    Exit;
  end;
  FileIdx := idx div 10000;
  for I := 0 to ItemImageList.Count - 1 do begin
    WMImage := TGameImages(ItemImageList.Items[I]);
    if WMImage.Appr = FileIdx then begin
      Result := WMImage.Images[idx - FileIdx * 10000]; //取物品所在IDX位置
      Exit;
    end;
  end;
  FileName := ExtractFilePath(Paramstr(0)) + 'StateItem' + IntToStr(FileIdx) + '.wil';
  WMImage := GetGameImages(g_ConfigClient.WStateItemImages, FileName);
  WMImage.Appr := FileIdx;
  WMImage.Initialize;
  ItemImageList.Add(WMImage);
  Result := WMImage.Images[idx - FileIdx * 10000]; //取物品所在IDX位置
end;

function GetWWeaponImg(Weapon, m_btSex, nFrame: Integer; var ax, ay: Integer): TTexture;
var
  I: Integer;
  FileName: string;
  FileIdx: Integer;
  WMImage: TGameImages;
  nAppr: Integer;
  nWeapon: Integer;
begin
  Result := nil;
  FileIdx := Weapon - m_btSex;
  //DebugOutStr('GetWWeaponImg Weapon=' + IntToStr(Weapon)); //g_WisWeapon2Images 从38开始
  if (FileIdx < 160) then begin
    if (FileIdx >= 38 * 2) then
      Result := g_WisWeapon2Images.GetCachedImage(HUMANFRAME * (Weapon - 38 * 2) + nFrame, ax, ay)
    else
      Result := g_WWeaponImages.GetCachedImage(HUMANFRAME * Weapon + nFrame, ax, ay);
    Exit;
  end;

  nAppr := (FileIdx - 160) div 40 + 2;

  nWeapon := (Weapon - 160);

  if nWeapon >= 40 then
    nWeapon := nWeapon - (nAppr - 2) * 40;

  for I := 0 to WeaponImageList.Count - 1 do begin
    WMImage := TGameImages(WeaponImageList.Items[I]);
    if WMImage.Appr = nAppr then begin
      Result := WMImage.GetCachedImage(HUMANFRAME * nWeapon + nFrame, ax, ay);
      Exit;
    end;
  end;

  FileName := ExtractFilePath(Paramstr(0)) + 'Data\Weapon' + IntToStr(nAppr) + '.wil'; //Shape > 50  开始
  //DebugOutStr(FileName + ' GetWWeaponImg nWeapon=' + IntToStr(nWeapon));
  WMImage := GetGameImages(g_ConfigClient.WWeaponImages, FileName);
  WMImage.Appr := nAppr;
  WMImage.Initialize;
  WeaponImageList.Add(WMImage);
  Result := WMImage.GetCachedImage(HUMANFRAME * nWeapon + nFrame, ax, ay);
end;

function GetWHumImg(Dress, m_btSex, nFrame: Integer; var ax, ay: Integer): TTexture;
var
  I: Integer;
  FileName: string;
  FileIdx: Integer;
  WMImage: TGameImages;
  nAppr: Integer;
  nDress: Integer;
begin
  Result := nil;
  FileIdx := Dress - m_btSex;
  //nAppr := FileIdx div 100;
  //DebugOutStr('GetWHumImg Dress=' + IntToStr(Dress));

  if FileIdx <= 22 then begin
    Result := g_WHumImgImages.GetCachedImage(HUMANFRAME * Dress + nFrame, ax, ay);
    Exit;
  end;

  nAppr := FileIdx div 24 + 1;
  nDress := Dress - (nAppr - 1) * 24;

  for I := 0 to HumImageList.Count - 1 do begin
    WMImage := TGameImages(HumImageList.Items[I]);
    if WMImage.Appr = nAppr then begin
      Result := WMImage.GetCachedImage(HUMANFRAME * nDress + nFrame, ax, ay);
      Exit;
    end;
  end;

  FileName := ExtractFilePath(Paramstr(0)) + 'Data\Hum' + IntToStr(nAppr) + '.wil';

  WMImage := GetGameImages(g_ConfigClient.WHumImgImages, FileName);
  WMImage.Appr := nAppr;
  WMImage.Initialize;
  HumImageList.Add(WMImage);
  Result := WMImage.GetCachedImage(HUMANFRAME * nDress + nFrame, ax, ay);
end;

constructor TImageList.Create();
begin
  //FillChar(WMonImagesArr, SizeOf(TWilImages) * 100, 0);
  SetLength(ImagesArr, 0);
end;

destructor TImageList.Destroy;
var
  I: Integer;
begin
  for I := Low(ImagesArr) to High(ImagesArr) do begin
    if ImagesArr[I] <> nil then begin
      ImagesArr[I].Finalize;
      FreeAndNil(ImagesArr[I]);
    end;
  end;
  SetLength(ImagesArr, 0);
end;

function TImageList.GetCount: Integer;
begin
  Result := Length(ImagesArr);
end;

procedure TImageList.SetIndex(Index: Integer; Images: TGameImages);
begin
  if (Index >= Low(ImagesArr)) and (Index <= High(ImagesArr)) then begin
    ImagesArr[Index] := Images;
  end;
end;

procedure TImageList.ClearCache;
var
  I: Integer;
begin
  for I := 0 to Length(ImagesArr) - 1 do begin
    if (ImagesArr[I] <> nil) and ImagesArr[I].Initialized then
      ImagesArr[I].ClearCache;
  end;
end;


//=============== TWeaponImageList================

function TWeaponImageList.GetImage(Weapon, Sex, Frame: Integer; var X, Y: Integer): TTexture;
var
  FileName: string;
  FileIdx: Integer;
  nAppr: Integer;
  nWeapon: Integer;
begin
  Result := nil;
  FileIdx := Weapon - Sex;
  nAppr := FileIdx div 100;

  if (FileIdx <= 100) then begin
    if ImagesArr[0] = nil then begin
      FileName := WEAPONIMAGESFILE;
      ImagesArr[0] := GetGameImages(g_ConfigClient.WWeaponImages, FileName);
      ImagesArr[0].Initialize;
    end;
    if ImagesArr[0] <> nil then
      Result := ImagesArr[0].GetCachedImage(HUMANFRAME * Weapon + Frame, X, Y);
    Exit;
  end;

  nWeapon := Weapon - nAppr * 100;
  FileName := ExtractFilePath(Paramstr(0)) + Format(WEAPONIMAGESFILES, [nAppr]);
  if nAppr > High(ImagesArr) then SetLength(ImagesArr, nAppr + 1);

  if ImagesArr[nAppr] = nil then begin
    ImagesArr[nAppr] := GetGameImages(g_ConfigClient.WWeaponImages, FileName);
    ImagesArr[nAppr].Initialize;
  end;

  if ImagesArr[nAppr] <> nil then
    ImagesArr[nAppr].GetCachedImage(HUMANFRAME * nWeapon + Frame, X, Y);
end;

procedure TWeaponImageList.Initialize();
var
  sFileName: string;
  nUnit: Integer;
begin
  for nUnit := Low(ImagesArr) to High(ImagesArr) do begin
    if nUnit = 0 then begin
      sFileName := WEAPONIMAGESFILE;
    end else begin
      sFileName := Format(WEAPONIMAGESFILES, [nUnit]);
    end;
    ImagesArr[nUnit] := GetGameImages(g_ConfigClient.WWeaponImages, ExtractFilePath(Paramstr(0)) + sFileName);
    ImagesArr[nUnit].Initialize;
  end;
end;

procedure TWeaponImageList.Finalize;
var
  I: Integer;
begin
  for I := Low(ImagesArr) to High(ImagesArr) do begin
    if ImagesArr[I] <> nil then begin
      ImagesArr[I].Finalize;
      FreeAndNil(ImagesArr[I]);
    end;
  end;
  SetLength(ImagesArr, 0);
end;

//=============== THumImageList================

function THumImageList.GetImage(Dress, Sex, Frame: Integer; var X, Y: Integer): TTexture;
var
  FileName: string;
  FileIdx: Integer;
  nAppr: Integer;
  nDress: Integer;
begin
  Result := nil;
  FileIdx := Dress - Sex;
  nAppr := FileIdx div 100;

  if (FileIdx <= 100) then begin
    if ImagesArr[0] = nil then begin
      FileName := HUMIMGIMAGESFILE;
      ImagesArr[0] := GetGameImages(g_ConfigClient.WHumImgImages, ExtractFilePath(Paramstr(0)) + FileName);
      ImagesArr[0].Initialize;
    end;
    if ImagesArr[0] <> nil then
      Result := ImagesArr[0].GetCachedImage(HUMANFRAME * Dress + Frame, X, Y);
    Exit;
  end;

  nDress := Dress - nAppr * 100;
  FileName := Format(HUMIMGIMAGESFILES, [nAppr]);
  if nAppr > High(ImagesArr) then SetLength(ImagesArr, nAppr + 1);

  if ImagesArr[nAppr] = nil then begin
    ImagesArr[nAppr] := GetGameImages(g_ConfigClient.WHumImgImages, ExtractFilePath(Paramstr(0)) + FileName);
    ImagesArr[nAppr].Initialize;
  end;

  if ImagesArr[nAppr] <> nil then
    ImagesArr[nAppr].GetCachedImage(HUMANFRAME * nDress + Frame, X, Y);
end;

procedure THumImageList.Initialize();
var
  sFileName: string;
  nUnit: Integer;
begin
  for nUnit := Low(ImagesArr) to High(ImagesArr) do begin
    if nUnit = 0 then begin
      sFileName := HUMIMGIMAGESFILE;
    end else begin
      sFileName := Format(HUMIMGIMAGESFILES, [nUnit]);
    end;

    ImagesArr[nUnit] := GetGameImages(g_ConfigClient.WHumImgImages, ExtractFilePath(Paramstr(0)) + sFileName);
    ImagesArr[nUnit].Initialize;
  end;
end;

procedure THumImageList.Finalize;
var
  I: Integer;
begin
  for I := Low(ImagesArr) to High(ImagesArr) do begin
    if ImagesArr[I] <> nil then begin
      ImagesArr[I].Finalize;
      FreeAndNil(ImagesArr[I]);
    end;
  end;
  SetLength(ImagesArr, 0);
end;

//=============== TMonImageList================

function TMonImageList.IndexOf(Index: Integer): TGameImages;
var
  sFileName: string;
  nUnit: Integer;
begin
  nUnit := Index;

  if Index < Low(ImagesArr) then nUnit := 1;
  if Index > High(ImagesArr) then SetLength(ImagesArr, Index + 1);
  if ImagesArr[nUnit] = nil then begin
    sFileName := Format(MONIMAGEFILE, [nUnit]);
    if nUnit = 80 then sFileName := DRAGONIMAGEFILE;
    if nUnit = 90 then sFileName := EFFECTIMAGEFILE;

    ImagesArr[nUnit] := GetGameImages(g_ConfigClient.WMonImages[nUnit], ExtractFilePath(Paramstr(0)) + sFileName);
    ImagesArr[nUnit].Initialize;
  end;
  Result := ImagesArr[nUnit];
end;

function TMonImageList.ImageOf(Index: Integer): TGameImages;
var
  sFileName: string;
  nUnit: Integer;
begin
  nUnit := Index div 10;
  if nUnit in [80, 90] then begin
    if nUnit = 80 then Result := g_WDragonImg;
    if nUnit = 90 then Result := g_WEffectImg;
  end else begin
    Inc(nUnit);
    if nUnit < Low(ImagesArr) then nUnit := 1;
    if nUnit > High(ImagesArr) then SetLength(ImagesArr, nUnit + 1);
    if ImagesArr[nUnit] = nil then begin
      sFileName := Format(MONIMAGEFILE, [nUnit]);
      ImagesArr[nUnit] := GetGameImages(g_ConfigClient.WMonImages[nUnit], ExtractFilePath(Paramstr(0)) + sFileName);
      ImagesArr[nUnit].Initialize;
    end;
    Result := ImagesArr[nUnit];
  end;
  //DebugOutStr('Index:' + IntToStr(Index) + ' nUnit:' + IntToStr(nUnit));
end;

procedure TMonImageList.Initialize();
var
  sFileName: string;
  nUnit: Integer;
begin
  for nUnit := Low(ImagesArr) to High(ImagesArr) do begin
    sFileName := Format(MONIMAGEFILE, [nUnit]);
    ImagesArr[nUnit] := GetGameImages(g_ConfigClient.WMonImages[nUnit], ExtractFilePath(Paramstr(0)) + sFileName);
    ImagesArr[nUnit].Initialize;
  end;
end;

procedure TMonImageList.Finalize;
var
  I: Integer;
begin
  for I := Low(ImagesArr) to High(ImagesArr) do begin
    if ImagesArr[I] <> nil then begin
      ImagesArr[I].Finalize;
      FreeAndNil(ImagesArr[I]);
    end;
  end;
  SetLength(ImagesArr, 0);
end;

procedure DebugOutStr(Msg: string);
var
  flname: string;
  fhandle: TextFile;
begin
  if not boOutbugStr then Exit;
  flname := '.\!debug.txt';
  if FileExists(flname) then begin
    AssignFile(fhandle, flname);
    Append(fhandle);
  end else begin
    AssignFile(fhandle, flname);
    Rewrite(fhandle);
  end;
  Writeln(fhandle, DateTimeToStr(Now) + ' ' + Msg);
  CloseFile(fhandle);
end;

procedure UpDataFreeActorList(Actor: TActor);
var
  I: Integer;
begin
  if g_FreeActorList <> nil then begin
    for I := 0 to g_FreeActorList.Count - 1 do begin
      if Actor = TActor(g_FreeActorList[I]) then Exit;
    end;
    g_FreeActorList.Add(Actor);
  end;
end;

procedure LoadWMImagesLib();
var
  sFilePath: string;
begin

  sFilePath := ExtractFilePath(Paramstr(0));
  g_WEffectImg := GetGameImages(g_ConfigClient.WEffectImg, sFilePath + EFFECTIMAGEFILE);
  g_WDragonImg := GetGameImages(g_ConfigClient.WEffectImg, sFilePath + DRAGONIMAGEFILE);
  g_WMainImages := GetGameImages(g_ConfigClient.WMainImages, sFilePath + MAINIMAGEFILE);
  g_WMain2Images := GetGameImages(g_ConfigClient.WMain2Images, sFilePath + MAINIMAGEFILE2);
  g_WMain3Images := GetGameImages(g_ConfigClient.WMain3Images, sFilePath + MAINIMAGEFILE3);
  g_WChrSelImages := GetGameImages(g_ConfigClient.WChrSelImages, sFilePath + CHRSELIMAGEFILE);
  g_WMMapImages := GetGameImages(g_ConfigClient.WMMapImages, sFilePath + MINMAPIMAGEFILE);
  g_WTilesImages := GetGameImages(lmUseWil, sFilePath + TITLESIMAGEFILE);
  g_WSmTilesImages := GetGameImages(lmUseWil, sFilePath + SMLTITLESIMAGEFILE);
  g_WHumWingImages := GetGameImages(g_ConfigClient.WHumWingImages, sFilePath + HUMWINGIMAGESFILE);
  g_WHum1WingImages := GetGameImages(g_ConfigClient.WHum1WingImages, sFilePath + HUM1WINGIMAGESFILE);
  g_WHum2WingImages := GetGameImages(g_ConfigClient.WHum2WingImages, sFilePath + HUM2WINGIMAGESFILE);
  g_WBagItemImages := GetGameImages(g_ConfigClient.WBagItemImages, sFilePath + BAGITEMIMAGESFILE);
  g_WStateItemImages := GetGameImages(g_ConfigClient.WStateItemImages, sFilePath + STATEITEMIMAGESFILE);
  g_WDnItemImages := GetGameImages(g_ConfigClient.WDnItemImages, sFilePath + DNITEMIMAGESFILE);
  g_WHumImgImages := GetGameImages(g_ConfigClient.WHumImgImages, sFilePath + HUMIMGIMAGESFILE);
  g_WHairImgImages := GetGameImages(g_ConfigClient.WHairImgImages, sFilePath + HAIRIMGIMAGESFILE);
  g_WHair2ImgImages := GetGameImages(g_ConfigClient.WHair2ImgImages, sFilePath + HAIRIMGIMAGESFILE2);
  g_WWeaponImages := GetGameImages(g_ConfigClient.WWeaponImages, sFilePath + WEAPONIMAGESFILE);
  g_WMagIconImages := GetGameImages(g_ConfigClient.WMagIconImages, sFilePath + MAGICONIMAGESFILE);
  g_WNpcImgImages := GetGameImages(g_ConfigClient.WNpcImgImages, sFilePath + NPCIMAGESFILE);
  g_WFirNpcImgImages := GetGameImages(g_ConfigClient.WFirNpcImgImages, sFilePath + FNPCIMAGESFILE);
  g_WMagicImages := GetGameImages(g_ConfigClient.WMagicImages, sFilePath + MAGICIMAGESFILE);
  g_WMagic2Images := GetGameImages(g_ConfigClient.WMagic2Images, sFilePath + MAGIC2IMAGESFILE);
  g_WMagic3Images := GetGameImages(g_ConfigClient.WMagic3Images, sFilePath + MAGIC3IMAGESFILE);
  g_WMagic4Images := GetGameImages(g_ConfigClient.WMagic4Images, sFilePath + MAGIC4IMAGESFILE);
  g_WMagic5Images := GetGameImages(g_ConfigClient.WMagic5Images, sFilePath + MAGIC5IMAGESFILE);
  g_WMagic6Images := GetGameImages(g_ConfigClient.WMagic6Images, sFilePath + MAGIC6IMAGESFILE);
  g_WCqFirImages := GetGameImages(lmUseFir, sFilePath + CQFIRIMAGESFILE);

  FillChar(g_WObjectArr, SizeOf(g_WObjectArr), 0);
  FillChar(g_WObjectArr16, SizeOf(g_WObjectArr16), 0);

  g_WMonImages := TMonImageList.Create;

  g_WHorseImages := GetGameImages(lmUseWil, sFilePath + HORSEIMAGESFILE);
  g_WHumHorseImages := GetGameImages(lmUseWil, sFilePath + HUMHORSEIMAGESFILE);
  g_WHairHorseImages := GetGameImages(lmUseWil, sFilePath + HAIRHORSEIMAGESFILE);
  g_WNpcFaceImages := GetGameImages(lmUseWil, sFilePath + NPCFACEIMAGEFILE);

  g_WBookImages := TUibImages.Create();
  g_WBookImages.FileName := sFilePath;
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\1.uib'); //0
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\2.uib'); //1
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\3.uib'); //2
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\4.uib'); //3
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\5.uib'); //4
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\CommandNormal.uib'); //5
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\1\CommandDown.uib'); //6

  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\2\1.uib'); //7
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\3\1.uib'); //8
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\4\1.uib'); //9
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\5\1.uib'); //10
  g_WBookImages.m_FileList.Add(sFilePath + 'Data\books\6\1.uib'); //11

  g_WUIBImages := TUibImages.Create();
  g_WUIBImages.FileName := sFilePath;
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookBkgnd.uib'); //0
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookCloseNormal.uib'); //1
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookCloseDown.uib'); //2
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookNextPageNormal.uib'); //3
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookNextPageDown.uib'); //4
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookPrevPageNormal.uib'); //5
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\BookPrevPageDown.uib'); //6
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\GloryButton.uib'); //7
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\HeroStatusWindow.uib'); //8
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\StateWindowHero.uib'); //9
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\StateWindowHuman.uib'); //10
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\snda.uib'); //11
  g_WUIBImages.m_FileList.Add(sFilePath + 'Data\ui\cqfir.uib'); //12

  g_WMiniMapImages := TUibImages.Create();
  g_WMiniMapImages.FileName := sFilePath;
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\301.mmap'); //0
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\302.mmap'); //1
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\303.mmap'); //2
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\304.mmap'); //3
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\306.mmap'); //4
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\307.mmap'); //5
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\308.mmap'); //6
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\309.mmap'); //7
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\310.mmap'); //8
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\311.mmap'); //9
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\312.mmap'); //10
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\313.mmap'); //11
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\314.mmap'); //12
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\315.mmap'); //13
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\316.mmap'); //14
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\317.mmap'); //15
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\318.mmap'); //16
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\320.mmap'); //17
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\321.mmap'); //18
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\322.mmap'); //19
  g_WMiniMapImages.m_FileList.Add(sFilePath + 'Data\minimap\323.mmap'); //20
  g_WMiniMapImages.m_FileList.SaveToFile('WMiniMapImages.txt');
  g_WTilesImages16 := TFirImages.Create();
  g_WSmTilesImages16 := TFirImages.Create();

//--------------------------------WIS-------------------------------------------
  g_WisMainImages := GetGameImages(lmUseWil, sFilePath + WISMAINIMAGEFILE);
  g_WisMain2Images := GetGameImages(lmUseWil, sFilePath + WISMAINIMAGEFILE2);
  g_WisMain3Images := GetGameImages(lmUseWil, sFilePath + WISMAINIMAGEFILE3);

  g_WisDnItemImages := GetGameImages(lmUseWil, sFilePath + WISDNITEMIMAGESFILE);
  g_WisBagItemImages := GetGameImages(lmUseWil, sFilePath + WISBAGITEMIMAGESFILE);
  g_WisStateItemImages := GetGameImages(lmUseWil, sFilePath + WISSTATEITEMIMAGESFILE);
  g_WisWeapon2Images := GetGameImages(lmUseWil, sFilePath + WISEAPONIMAGESFILE);

  g_cboEffectImg := GetGameImages(lmUseWil, sFilePath + CBOEFFECTIMAGEFILE);
  g_cboHairImgImages := GetGameImages(lmUseWil, sFilePath + CBOHAIRIMGIMAGESFILE);
  g_cboHumImgImages := GetGameImages(lmUseWil, sFilePath + CBOHUMIMGIMAGESFILE);
  g_cboHumWingImages := GetGameImages(lmUseWil, sFilePath + CBOHUMWINGIMAGESFILE);
  g_cboWeaponImages := GetGameImages(lmUseWil, sFilePath + CBOWEAPONIMAGESFILE);


end;

procedure IniTWilImagesLib();
var
  sFilePath: string;
begin
  sFilePath := ExtractFilePath(Paramstr(0));

  g_WCqFirImages.Initialize;
  g_WEffectImg.Initialize;
  g_WDragonImg.Initialize;
  g_WMainImages.Initialize;
  g_WMain2Images.Initialize;
  g_WMain3Images.Initialize;
  g_WChrSelImages.Initialize;
  g_WMMapImages.Initialize;
  g_WTilesImages.Initialize;
  g_WSmTilesImages.Initialize;
  g_WHumWingImages.Initialize;
  g_WHum1WingImages.Initialize;
  g_WHum2WingImages.Initialize;
  g_WBagItemImages.Initialize;
  g_WStateItemImages.Initialize;
  g_WDnItemImages.Initialize;
  g_WHumImgImages.Appr := 0;
  g_WHumImgImages.Initialize;
  g_WHairImgImages.Initialize;
  g_WHair2ImgImages.Initialize;
  g_WWeaponImages.Appr := 0;
  g_WWeaponImages.Initialize;
  g_WMagIconImages.Initialize;
  g_WNpcImgImages.Initialize;
  g_WFirNpcImgImages.Initialize;
  g_WMagicImages.Initialize;
  g_WMagic2Images.Initialize;
  g_WMagic3Images.Initialize;
  g_WMagic4Images.Initialize;
  g_WMagic5Images.Initialize;
  g_WMagic6Images.Initialize;
  g_WHorseImages.Initialize;
  g_WHumHorseImages.Initialize;
  g_WHairHorseImages.Initialize;

  g_WBookImages.Initialize;
  g_WUIBImages.Initialize;
  g_WMiniMapImages.Initialize;

  g_WTilesImages16.FileName := sFilePath + TITLESIMAGEFILE;
  g_WTilesImages16.Initialize;

  g_WSmTilesImages16.FileName := sFilePath + SMLTITLESIMAGEFILE;
  g_WSmTilesImages16.Initialize;

  g_WNpcFaceImages.Initialize;

//----------------------------------wis-----------------------------------------

  //g_WisMainImages.FileName := sFilePath + WISMAINIMAGEFILE;
  g_WisMainImages.Initialize;

  //g_WisMain2Images.FileName := WISMAINIMAGEFILE2;
  //g_WisMain2Images.Initialize;

  //g_WisMain3Images.FileName := WISMAINIMAGEFILE3;
  //g_WisMain3Images.Initialize;


  //g_WisDnItemImages.FileName := WISDNITEMIMAGESFILE;
  //g_WisDnItemImages.Initialize;

  //g_WisBagItemImages.FileName := WISBAGITEMIMAGESFILE;
  //g_WisBagItemImages.Initialize;

  //g_WisStateItemImages.FileName := WISSTATEITEMIMAGESFILE;
  //g_WisStateItemImages.Initialize;

  //g_WisWeapon2Images.FileName := sFilePath + WISEAPONIMAGESFILE;
  g_WisWeapon2Images.Initialize;

  //g_cboEffectImg.FileName := sFilePath + CBOEFFECTIMAGEFILE;
  g_cboEffectImg.Initialize;

  //g_cboHairImgImages.FileName := sFilePath + CBOHAIRIMGIMAGESFILE;
  g_cboHairImgImages.Initialize;

  //g_cboHumImgImages.FileName := sFilePath + CBOHUMIMGIMAGESFILE;
  g_cboHumImgImages.Initialize;

  //g_cboHumWingImages.FileName := sFilePath + CBOHUMWINGIMAGESFILE;
  g_cboHumWingImages.Initialize;

  //g_cboWeaponImages.FileName := sFilePath + CBOWEAPONIMAGESFILE;
  g_cboWeaponImages.Initialize;




  g_ClientEffectImageList.AddObject(g_WCqFirImages.FileName, g_WCqFirImages);
  g_ClientEffectImageList.AddObject(g_WEffectImg.FileName, g_WEffectImg);
  g_ClientEffectImageList.AddObject(g_WDragonImg.FileName, g_WDragonImg);
  g_ClientEffectImageList.AddObject(g_WMainImages.FileName, g_WMainImages);
  g_ClientEffectImageList.AddObject(g_WMain2Images.FileName, g_WMain2Images);
  g_ClientEffectImageList.AddObject(g_WMain3Images.FileName, g_WMain3Images);
  g_ClientEffectImageList.AddObject(g_WChrSelImages.FileName, g_WChrSelImages);
  g_ClientEffectImageList.AddObject(g_WMMapImages.FileName, g_WMMapImages);
  g_ClientEffectImageList.AddObject(g_WTilesImages.FileName, g_WTilesImages);
  g_ClientEffectImageList.AddObject(g_WSmTilesImages.FileName, g_WSmTilesImages);
  g_ClientEffectImageList.AddObject(g_WHumWingImages.FileName, g_WHumWingImages);
  g_ClientEffectImageList.AddObject(g_WHum1WingImages.FileName, g_WHum1WingImages);
  g_ClientEffectImageList.AddObject(g_WHum2WingImages.FileName, g_WHum2WingImages);
  g_ClientEffectImageList.AddObject(g_WBagItemImages.FileName, g_WBagItemImages);
  g_ClientEffectImageList.AddObject(g_WStateItemImages.FileName, g_WStateItemImages);
  g_ClientEffectImageList.AddObject(g_WDnItemImages.FileName, g_WDnItemImages);

  g_ClientEffectImageList.AddObject(g_WHumImgImages.FileName, g_WHumImgImages);
  g_ClientEffectImageList.AddObject(g_WHairImgImages.FileName, g_WHairImgImages);
  g_ClientEffectImageList.AddObject(g_WHair2ImgImages.FileName, g_WHair2ImgImages);

  g_ClientEffectImageList.AddObject(g_WWeaponImages.FileName, g_WWeaponImages);
  g_ClientEffectImageList.AddObject(g_WMagIconImages.FileName, g_WMagIconImages);
  g_ClientEffectImageList.AddObject(g_WNpcImgImages.FileName, g_WNpcImgImages);
  g_ClientEffectImageList.AddObject(g_WFirNpcImgImages.FileName, g_WFirNpcImgImages);
  g_ClientEffectImageList.AddObject(g_WMagicImages.FileName, g_WMagicImages);
  g_ClientEffectImageList.AddObject(g_WMagic2Images.FileName, g_WMagic2Images);
  g_ClientEffectImageList.AddObject(g_WMagic3Images.FileName, g_WMagic3Images);
  g_ClientEffectImageList.AddObject(g_WMagic4Images.FileName, g_WMagic4Images);
  g_ClientEffectImageList.AddObject(g_WMagic5Images.FileName, g_WMagic5Images);
  g_ClientEffectImageList.AddObject(g_WMagic6Images.FileName, g_WMagic6Images);
  g_ClientEffectImageList.AddObject(g_WHorseImages.FileName, g_WHorseImages);
  g_ClientEffectImageList.AddObject(g_WHumHorseImages.FileName, g_WHumHorseImages);
  g_ClientEffectImageList.AddObject(g_WHairHorseImages.FileName, g_WHairHorseImages);

  g_ClientEffectImageList.AddObject(g_WBookImages.FileName, g_WBookImages);
  g_ClientEffectImageList.AddObject(g_WUIBImages.FileName, g_WUIBImages);
  g_ClientEffectImageList.AddObject(g_WMiniMapImages.FileName, g_WMiniMapImages);


  g_ClientEffectImageList.AddObject(g_WTilesImages16.FileName, g_WTilesImages16);

  g_ClientEffectImageList.AddObject(g_WSmTilesImages16.FileName, g_WSmTilesImages16);

  g_ClientEffectImageList.AddObject(g_WNpcFaceImages.FileName, g_WNpcFaceImages);

//----------------------------------wis-----------------------------------------

    //g_ClientEffectImageList.AddObject(//g_WisMainImages.FileName := sFilePath + WISMAINIMAGEFILE;
  g_ClientEffectImageList.AddObject(g_WisMainImages.FileName, g_WisMainImages);

    //g_ClientEffectImageList.AddObject(//g_WisMain2Images.FileName := WISMAINIMAGEFILE2;
    //g_ClientEffectImageList.AddObject(//g_WisMain2Images.FileName,);

    //g_ClientEffectImageList.AddObject(//g_WisMain3Images.FileName := WISMAINIMAGEFILE3;
    //g_ClientEffectImageList.AddObject(//g_WisMain3Images.FileName,);


    //g_ClientEffectImageList.AddObject(//g_WisDnItemImages.FileName := WISDNITEMIMAGESFILE;
    //g_ClientEffectImageList.AddObject(//g_WisDnItemImages.FileName,);

    //g_ClientEffectImageList.AddObject(//g_WisBagItemImages.FileName := WISBAGITEMIMAGESFILE;
    //g_ClientEffectImageList.AddObject(//g_WisBagItemImages.FileName,);

    //g_ClientEffectImageList.AddObject(//g_WisStateItemImages.FileName := WISSTATEITEMIMAGESFILE;
    //g_ClientEffectImageList.AddObject(//g_WisStateItemImages.FileName,);

    //g_ClientEffectImageList.AddObject(//g_WisWeapon2Images.FileName := sFilePath + WISEAPONIMAGESFILE;
  g_ClientEffectImageList.AddObject(g_WisWeapon2Images.FileName, g_WisWeapon2Images);

    //g_ClientEffectImageList.AddObject(//g_cboEffectImg.FileName := sFilePath + CBOEFFECTIMAGEFILE;
  g_ClientEffectImageList.AddObject(g_cboEffectImg.FileName, g_cboEffectImg);

    //g_ClientEffectImageList.AddObject(//g_cboHairImgImages.FileName := sFilePath + CBOHAIRIMGIMAGESFILE;
  g_ClientEffectImageList.AddObject(g_cboHairImgImages.FileName, g_cboHairImgImages);

    //g_ClientEffectImageList.AddObject(//g_cboHumImgImages.FileName := sFilePath + CBOHUMIMGIMAGESFILE;
  g_ClientEffectImageList.AddObject(g_cboHumImgImages.FileName, g_cboHumImgImages);

    //g_ClientEffectImageList.AddObject(//g_cboHumWingImages.FileName := sFilePath + CBOHUMWINGIMAGESFILE;
  g_ClientEffectImageList.AddObject(g_cboHumWingImages.FileName, g_cboHumWingImages);

    //g_ClientEffectImageList.AddObject(//g_cboWeaponImages.FileName := sFilePath + CBOWEAPONIMAGESFILE;
  g_ClientEffectImageList.AddObject(g_cboWeaponImages.FileName, g_cboWeaponImages);
end;

procedure ObjectsClearCache;
var
  I: Integer;
begin
  for I := 0 to Length(g_WObjectArr) - 1 do begin
    if (g_WObjectArr[I] <> nil) and g_WObjectArr[I].Initialized then
      g_WObjectArr[I].ClearCache;
  end;

  for I := 0 to Length(g_WObjectArr16) - 1 do begin
    if (g_WObjectArr16[I] <> nil) and g_WObjectArr16[I].Initialized then
      g_WObjectArr16[I].ClearCache;
  end;
end;

procedure WMImagesFinalize();
var
  I: Integer;
begin
  for I := Low(g_WObjectArr) to High(g_WObjectArr) do begin
    if g_WObjectArr[I] <> nil then begin
      g_WObjectArr[I].Finalize;
      FreeAndNil(g_WObjectArr[I]);
    end;
    g_WObjectArr[I] := nil;
  end;

  for I := Low(g_WObjectArr16) to High(g_WObjectArr16) do begin
    if g_WObjectArr16[I] <> nil then begin
      g_WObjectArr16[I].Finalize;
      FreeAndNil(g_WObjectArr16[I]);
    end;
    g_WObjectArr16[I] := nil;
  end;

  FillChar(g_WObjectArr, SizeOf(g_WObjectArr), 0);

  FillChar(g_WObjectArr16, SizeOf(g_WObjectArr16), 0);

  for I := 0 to NpcImageList.Count - 1 do begin
    TGameImages(NpcImageList.Items[I]).Free;
  end;
  for I := 0 to ItemImageList.Count - 1 do begin
    TGameImages(ItemImageList.Items[I]).Free;
  end;
  for I := 0 to WeaponImageList.Count - 1 do begin
    TGameImages(WeaponImageList.Items[I]).Free;
  end;
  for I := 0 to HumImageList.Count - 1 do begin
    TGameImages(HumImageList.Items[I]).Free;
  end;
  NpcImageList.Clear;
  ItemImageList.Clear;
  WeaponImageList.Clear;
  HumImageList.Clear;

  g_WMonImages.Finalize;

  g_WEffectImg.Finalize;

  g_WDragonImg.Finalize;

  g_WMainImages.Finalize;

  g_WMain2Images.Finalize;

  g_WMain3Images.Finalize;

  g_WChrSelImages.Finalize;

  g_WMMapImages.Finalize;

  g_WTilesImages.Finalize;

  g_WSmTilesImages.Finalize;

  g_WTilesImages16.Finalize;

  g_WSmTilesImages16.Finalize;


  g_WHumWingImages.Finalize;

  g_WHum1WingImages.Finalize;

  g_WHum2WingImages.Finalize;

  g_WBagItemImages.Finalize;

  g_WStateItemImages.Finalize;

  g_WDnItemImages.Finalize;

  g_WHumImgImages.Finalize;

  g_WHairImgImages.Finalize;

  g_WHair2ImgImages.Finalize;

  g_WWeaponImages.Finalize;

  g_WMagIconImages.Finalize;

  g_WNpcImgImages.Finalize;

  g_WFirNpcImgImages.Finalize;

  g_WMagicImages.Finalize;

  g_WMagic2Images.Finalize;

  g_WMagic3Images.Finalize;

  g_WMagic4Images.Finalize;

  g_WMagic5Images.Finalize;

  g_WMagic6Images.Finalize;

  g_WCqFirImages.Finalize;

  g_WHorseImages.Finalize;

  g_WHumHorseImages.Finalize;

  g_WHairHorseImages.Finalize;

  g_WBookImages.Finalize;

  g_WUIBImages.Finalize;

  g_WMiniMapImages.Finalize;

  g_WNpcFaceImages.Finalize;

//-------------------------------------wis--------------------------------------
  g_WisMainImages.Finalize;
  g_WisMain2Images.Finalize;
  g_WisMain3Images.Finalize;

  g_WisDnItemImages.Finalize;
  g_WisBagItemImages.Finalize;
  g_WisStateItemImages.Finalize;
  g_WisWeapon2Images.Finalize;

  g_cboEffectImg.Finalize;
  g_cboHairImgImages.Finalize;
  g_cboHumImgImages.Finalize;
  g_cboHumWingImages.Finalize;
  g_cboWeaponImages.Finalize;

  for I := 0 to g_CreateEffectImageList.Count - 1 do begin
    TGameImages(g_CreateEffectImageList.Objects[I]).Finalize;
  end;
end;

procedure UnLoadWMImagesLib();
var
  I: Integer;
begin
  for I := Low(g_WObjectArr) to High(g_WObjectArr) do begin
    if g_WObjectArr[I] <> nil then begin
      g_WObjectArr[I].Finalize;
      FreeAndNil(g_WObjectArr[I]);
    end;
  end;

  for I := Low(g_WObjectArr16) to High(g_WObjectArr16) do begin
    if g_WObjectArr16[I] <> nil then begin
      g_WObjectArr16[I].Finalize;
      FreeAndNil(g_WObjectArr16[I]);
    end;
  end;

  g_WMonImages.Free;

  g_WEffectImg.Finalize;
  g_WEffectImg.Free;

  g_WDragonImg.Finalize;
  g_WDragonImg.Free;

  g_WMainImages.Finalize;
  g_WMainImages.Free;

  g_WMain2Images.Finalize;
  g_WMain2Images.Free;

  g_WMain3Images.Finalize;
  g_WMain3Images.Free;

  g_WChrSelImages.Finalize;
  g_WChrSelImages.Free;

  g_WMMapImages.Finalize;
  g_WMMapImages.Free;

  g_WTilesImages.Finalize;
  g_WTilesImages.Free;

  g_WSmTilesImages.Finalize;
  g_WSmTilesImages.Free;

  g_WTilesImages16.Finalize;
  g_WTilesImages16.Free;

  g_WSmTilesImages16.Finalize;
  g_WSmTilesImages16.Free;


  g_WHumWingImages.Finalize;
  g_WHumWingImages.Free;

  g_WHum1WingImages.Finalize;
  g_WHum1WingImages.Free;

  g_WHum2WingImages.Finalize;
  g_WHum2WingImages.Free;

  g_WBagItemImages.Finalize;
  g_WBagItemImages.Free;

  g_WStateItemImages.Finalize;
  g_WStateItemImages.Free;

  g_WDnItemImages.Finalize;
  g_WDnItemImages.Free;

  g_WHumImgImages.Finalize;
  g_WHumImgImages.Free;

  g_WHairImgImages.Finalize;
  g_WHairImgImages.Free;

  g_WHair2ImgImages.Finalize;
  g_WHair2ImgImages.Free;

  g_WWeaponImages.Finalize;
  g_WWeaponImages.Free;

  g_WMagIconImages.Finalize;
  g_WMagIconImages.Free;

  g_WNpcImgImages.Finalize;
  g_WNpcImgImages.Free;

  g_WFirNpcImgImages.Finalize;
  g_WFirNpcImgImages.Free;

  g_WMagicImages.Finalize;
  g_WMagicImages.Free;

  g_WMagic2Images.Finalize;
  g_WMagic2Images.Free;

  g_WMagic3Images.Finalize;
  g_WMagic3Images.Free;

  g_WMagic4Images.Finalize;
  g_WMagic4Images.Free;

  g_WMagic5Images.Finalize;
  g_WMagic5Images.Free;

  g_WMagic6Images.Finalize;
  g_WMagic6Images.Free;

  g_WCqFirImages.Finalize;
  g_WCqFirImages.Free;

  g_WHorseImages.Finalize;
  g_WHorseImages.Free;

  g_WHumHorseImages.Finalize;
  g_WHumHorseImages.Free;

  g_WHairHorseImages.Finalize;
  g_WHairHorseImages.Free;

  g_WBookImages.Finalize;
  g_WBookImages.Free;

  g_WUIBImages.Finalize;
  g_WUIBImages.Free;

  g_WMiniMapImages.Finalize;
  g_WMiniMapImages.Free;

  g_WNpcFaceImages.Finalize;
  g_WNpcFaceImages.Free;


//-------------------------------------wis--------------------------------------
  g_WisMainImages.Free;
  g_WisMain2Images.Free;
  g_WisMain3Images.Free;

  g_WisDnItemImages.Free;
  g_WisBagItemImages.Free;
  g_WisStateItemImages.Free;
  g_WisWeapon2Images.Free;

  g_cboEffectImg.Free;
  g_cboHairImgImages.Free;
  g_cboHumImgImages.Free;
  g_cboHumWingImages.Free;
  g_cboWeaponImages.Free;

  for I := 0 to g_CreateEffectImageList.Count - 1 do begin
    TGameImages(g_CreateEffectImageList.Objects[I]).Finalize;
    TGameImages(g_CreateEffectImageList.Objects[I]).Free;
  end;
  g_CreateEffectImageList.Clear;
end;

procedure ClearWMImagesLib();
var
  I: Integer;
  WMImages: TGameImages;
begin
  for I := Low(g_WObjectArr) to High(g_WObjectArr) do begin
    if g_WObjectArr[I] <> nil then begin
      g_WObjectArr[I].ClearCache;
    end;
  end;

  for I := Low(g_WObjectArr16) to High(g_WObjectArr16) do begin
    if g_WObjectArr16[I] <> nil then begin
      g_WObjectArr16[I].ClearCache;
    end;
  end;

  for I := 0 to g_WMonImages.Count - 1 do begin
    WMImages := g_WMonImages.Indexs[I];
    if WMImages <> nil then
      WMImages.ClearCache;
  end;

  g_WEffectImg.ClearCache;
  g_WDragonImg.ClearCache;
  //g_WMainImages.ClearCache;
  //g_WMain2Images.ClearCache;
  //g_WMain3Images.ClearCache;
  g_WChrSelImages.ClearCache;
  g_WMMapImages.ClearCache;
  g_WTilesImages.ClearCache;
  g_WSmTilesImages.ClearCache;
  g_WHumWingImages.ClearCache;
  g_WHum1WingImages.ClearCache;
  g_WHum2WingImages.ClearCache;
  g_WBagItemImages.ClearCache;
  g_WStateItemImages.ClearCache;
  g_WDnItemImages.ClearCache;
  g_WHumImgImages.ClearCache;
  g_WHairImgImages.ClearCache;
  g_WHair2ImgImages.ClearCache;
  g_WWeaponImages.ClearCache;
  g_WMagIconImages.ClearCache;
  g_WNpcImgImages.ClearCache;
  g_WFirNpcImgImages.ClearCache;
  g_WMagicImages.ClearCache;
  g_WMagic2Images.ClearCache;
  g_WMagic3Images.ClearCache;
  g_WMagic4Images.ClearCache;
  g_WMagic5Images.ClearCache;
  g_WMagic6Images.ClearCache;
  //g_WCqFirImages.ClearCache;
  g_WHorseImages.ClearCache;
  g_WHumHorseImages.ClearCache;
  g_WHairHorseImages.ClearCache;
  g_WBookImages.ClearCache;
  g_WUIBImages.ClearCache;
  g_WNpcFaceImages.ClearCache;

//-------------------------------------wis--------------------------------------
  //g_WisMainImages.ClearCache;
  //g_WisMain2Images.ClearCache;
  //g_WisMain3Images.ClearCache;

  g_WisDnItemImages.ClearCache;
  g_WisBagItemImages.ClearCache;
  g_WisStateItemImages.ClearCache;
  g_WisWeapon2Images.ClearCache;

  g_cboEffectImg.ClearCache;
  g_cboHairImgImages.ClearCache;
  g_cboHumImgImages.ClearCache;
  g_cboHumWingImages.ClearCache;
  g_cboWeaponImages.ClearCache;

  for I := 0 to g_CreateEffectImageList.Count - 1 do begin
    TGameImages(g_CreateEffectImageList.Objects[I]).ClearCache;
  end;
end;

procedure FreeOldWMImagesLib();
var
  I: Integer;
  WMImages: TGameImages;
begin
  //if not CanDraw then Exit;
  for I := Low(g_WObjectArr) to High(g_WObjectArr) do begin
    if g_WObjectArr[I] <> nil then begin
      g_WObjectArr[I].FreeOldMemorys;
    end;
  end;

  for I := Low(g_WObjectArr16) to High(g_WObjectArr16) do begin
    if g_WObjectArr16[I] <> nil then begin
      g_WObjectArr16[I].FreeOldMemorys;
    end;
  end;

  for I := 0 to g_WMonImages.Count - 1 do begin
    WMImages := g_WMonImages.Indexs[I];
    if WMImages <> nil then
      WMImages.FreeOldMemorys;
  end;

  g_WEffectImg.FreeOldMemorys;
  g_WDragonImg.FreeOldMemorys;
  g_WMainImages.FreeOldMemorys;
  g_WMain2Images.FreeOldMemorys;
  g_WMain3Images.FreeOldMemorys;
  g_WChrSelImages.FreeOldMemorys;
  g_WMMapImages.FreeOldMemorys;
  g_WTilesImages.FreeOldMemorys;
  g_WSmTilesImages.FreeOldMemorys;
  g_WHumWingImages.FreeOldMemorys;
  g_WHum1WingImages.FreeOldMemorys;
  g_WHum2WingImages.FreeOldMemorys;
  g_WBagItemImages.FreeOldMemorys;
  g_WStateItemImages.FreeOldMemorys;
  g_WDnItemImages.FreeOldMemorys;
  g_WHumImgImages.FreeOldMemorys;
  g_WHairImgImages.FreeOldMemorys;
  g_WHair2ImgImages.FreeOldMemorys;
  g_WWeaponImages.FreeOldMemorys;
  g_WMagIconImages.FreeOldMemorys;
  g_WNpcImgImages.FreeOldMemorys;
  g_WFirNpcImgImages.FreeOldMemorys;
  g_WMagicImages.FreeOldMemorys;
  g_WMagic2Images.FreeOldMemorys;
  g_WMagic3Images.FreeOldMemorys;
  g_WMagic4Images.FreeOldMemorys;
  g_WMagic5Images.FreeOldMemorys;
  g_WMagic6Images.FreeOldMemorys;
  g_WCqFirImages.FreeOldMemorys;
  g_WHorseImages.FreeOldMemorys;
  g_WHumHorseImages.FreeOldMemorys;
  g_WHairHorseImages.FreeOldMemorys;
  g_WBookImages.FreeOldMemorys;
  g_WUIBImages.FreeOldMemorys;
  g_WNpcFaceImages.FreeOldMemorys;

//-------------------------------------wis--------------------------------------
  g_WisMainImages.FreeOldMemorys;
  g_WisMain2Images.FreeOldMemorys;
  g_WisMain3Images.FreeOldMemorys;

  g_WisDnItemImages.FreeOldMemorys;
  g_WisBagItemImages.FreeOldMemorys;
  g_WisStateItemImages.FreeOldMemorys;
  g_WisWeapon2Images.FreeOldMemorys;

  g_cboEffectImg.FreeOldMemorys;
  g_cboHairImgImages.FreeOldMemorys;
  g_cboHumImgImages.FreeOldMemorys;
  g_cboHumWingImages.FreeOldMemorys;
  g_cboWeaponImages.FreeOldMemorys;

  for I := 0 to g_CreateEffectImageList.Count - 1 do begin
    TGameImages(g_CreateEffectImageList.Objects[I]).FreeOldMemorys;
  end;
end;

//取地图图库

function GetObjs(nUnit, nIdx: Integer): TTexture;
var
  sFileName: string;
begin
  Result := nil;
  if not (nUnit in [Low(g_WObjectArr)..High(g_WObjectArr)]) then nUnit := 0;
  if g_WObjectArr[nUnit] = nil then begin
    if nUnit = 0 then sFileName := OBJECTIMAGEFILE
    else sFileName := Format(OBJECTIMAGEFILE1, [nUnit + 1]);
    g_WObjectArr[nUnit] := GetGameImages(lmUseWil, sFileName);
    g_WObjectArr[nUnit].Initialize;
  end;
  Result := g_WObjectArr[nUnit].Images[nIdx];
end;

//取地图图库

function GetObjsEx(nUnit, nIdx: Integer; var px, py: Integer): TTexture;
var
  sFileName: string;
begin
  Result := nil;
  if not (nUnit in [Low(g_WObjectArr)..High(g_WObjectArr)]) then nUnit := 0;
  if g_WObjectArr[nUnit] = nil then begin
    if nUnit = 0 then sFileName := OBJECTIMAGEFILE
    else sFileName := Format(OBJECTIMAGEFILE1, [nUnit + 1]);

    g_WObjectArr[nUnit] := GetGameImages(lmUseWil, sFileName);
    g_WObjectArr[nUnit].Initialize;
  end;
  Result := g_WObjectArr[nUnit].GetCachedImage(nIdx, px, py);
end;


//取地图图库

function GetObjs16(nUnit, nIdx: Integer): TTexture;
var
  sFileName: string;
begin
  Result := nil;
  if not (nUnit in [Low(g_WObjectArr16)..High(g_WObjectArr16)]) then nUnit := 0;
  if g_WObjectArr16[nUnit] = nil then begin
    if nUnit = 0 then sFileName := OBJECTIMAGEFILE
    else sFileName := Format(OBJECTIMAGEFILE1, [nUnit + 1]);

    g_WObjectArr16[nUnit] := GetGameImages(lmUseFir, sFileName);
    g_WObjectArr16[nUnit].Initialize;
  end;
  Result := g_WObjectArr16[nUnit].Images[nIdx];
end;

//取地图图库

function GetObjsEx16(nUnit, nIdx: Integer; var px, py: Integer): TTexture;
var
  sFileName: string;
begin
  Result := nil;
  if not (nUnit in [Low(g_WObjectArr16)..High(g_WObjectArr16)]) then nUnit := 0;
  if g_WObjectArr16[nUnit] = nil then begin
    if nUnit = 0 then sFileName := OBJECTIMAGEFILE
    else sFileName := Format(OBJECTIMAGEFILE1, [nUnit + 1]);

    g_WObjectArr16[nUnit] := GetGameImages(lmUseFir, sFileName);
    g_WObjectArr16[nUnit].Initialize;
  end;
  Result := g_WObjectArr16[nUnit].GetCachedImage(nIdx, px, py);
end;

function GetMonAction(nAppr: Integer): pTMonsterAction;
{var
  FileStream: TFileStream;
  sFileName: string;
  MonsterAction: TMonsterAction;  }
begin
  Result := nil;
  {sFileName := Format(MONPMFILE, [nAppr]);
  if FileExists(sFileName) then begin
    FileStream := TFileStream.Create(sFileName, fmOpenRead or fmShareDenyNone);
    FileStream.Read(MonsterAction, SizeOf(MonsterAction));
    New(Result);
    Result^ := MonsterAction;
    FileStream.Free;
  end;}
end;

//取得职业名称
//0 武士
//1 魔法师
//2 道士

function GetJobName(nJob: Integer): string;
begin
  Result := '';
  case nJob of
    0: Result := g_sWarriorName;
    1: Result := g_sWizardName;
    2: Result := g_sTaoistName;
  else
    begin
      Result := g_sUnKnowName;
    end;
  end;
end;

function GetSexName(nSex: Integer): string;
begin
  case nSex of
    0: Result := '男';
    1: Result := '女';
  end;
end;


function BooleanToStr(boBool: Boolean): string;
begin
  if boBool then Result := '√' else Result := '';
end;

function GetItemTypeName(ItemType: TItemType): string;
begin
  case ItemType of
    i_Other: Result := '其它类';
    i_HPMPDurg: Result := '药品类';
    i_Dress: Result := '服装类';
    i_Weapon: Result := '武器类';
    i_Jewelry: Result := '首饰类';
    i_Decoration: Result := '饰品类';
    i_Decorate: Result := '装饰类';
  end;
end;

function GetItemType(ItemType: string): TItemType;
begin
  if ItemType = '其它类' then Result := i_Other;
  if ItemType = '药品类' then Result := i_HPMPDurg;
  if ItemType = '服装类' then Result := i_Dress;
  if ItemType = '武器类' then Result := i_Weapon;
  if ItemType = '首饰类' then Result := i_Jewelry;
  if ItemType = '饰品类' then Result := i_Decoration;
  if ItemType = '装饰类' then Result := i_Decorate;
end;

function GetHumUseItemByBagItem(nStdMode: Integer): Integer;
begin
  Result := -1;
  case nStdMode of //StdMode
    5, 6: begin
        if g_UseItems[U_WEAPON].s.Name <> '' then
          Result := U_WEAPON; //武器
      end;
    10, 11: begin
        if g_UseItems[U_DRESS].s.Name <> '' then
          Result := U_DRESS;
      end;
    15, 16: begin
        if g_UseItems[U_HELMET].s.Name <> '' then
          Result := U_HELMET;
      end;
    19, 20, 21: begin
        if g_UseItems[U_NECKLACE].s.Name <> '' then
          Result := U_NECKLACE;
      end;
    22, 23: begin
        if g_UseItems[U_RINGL].s.Name <> '' then
          Result := U_RINGL
        else
          if g_UseItems[U_RINGR].s.Name <> '' then
          Result := U_RINGR;
      end;
    24, 26: begin
        if g_UseItems[U_ARMRINGL].s.Name <> '' then
          Result := U_ARMRINGL
        else
          if g_UseItems[U_ARMRINGR].s.Name <> '' then
          Result := U_ARMRINGR;
      end;
    30, 28, 29: begin
        if g_UseItems[U_RIGHTHAND].s.Name <> '' then
          Result := U_RIGHTHAND;
      end;
    25, 51: if g_UseItems[U_BUJUK].s.Name <> '' then Result := U_BUJUK; //符
    52, 62: if g_UseItems[U_BOOTS].s.Name <> '' then Result := U_BOOTS; //鞋
    7, 53, 63: if g_UseItems[U_CHARM].s.Name <> '' then Result := U_CHARM; //宝石
    54, 64: if g_UseItems[U_BELT].s.Name <> '' then Result := U_BELT; //腰带
  end;
end;

function GetHeroUseItemByBagItem(nStdMode: Integer): Integer;
begin
  Result := -1;
  case nStdMode of //StdMode
    5, 6: begin
        if g_HeroUseItems[U_WEAPON].s.Name <> '' then
          Result := U_WEAPON; //武器
      end;
    10, 11: begin
        if g_HeroUseItems[U_DRESS].s.Name <> '' then
          Result := U_DRESS;
      end;
    15, 16: begin
        if g_HeroUseItems[U_HELMET].s.Name <> '' then
          Result := U_HELMET;
      end;
    19, 20, 21: begin
        if g_HeroUseItems[U_NECKLACE].s.Name <> '' then
          Result := U_NECKLACE;
      end;
    22, 23: begin
        if g_HeroUseItems[U_RINGL].s.Name <> '' then
          Result := U_RINGL
        else
          if g_HeroUseItems[U_RINGR].s.Name <> '' then
          Result := U_RINGR;
      end;
    24, 26: begin
        if g_HeroUseItems[U_ARMRINGL].s.Name <> '' then
          Result := U_ARMRINGL
        else
          if g_HeroUseItems[U_ARMRINGR].s.Name <> '' then
          Result := U_ARMRINGR;
      end;
    30, 28, 29: begin
        if g_HeroUseItems[U_RIGHTHAND].s.Name <> '' then
          Result := U_RIGHTHAND;
      end;
    25, 51: if g_HeroUseItems[U_BUJUK].s.Name <> '' then Result := U_BUJUK; //符
    52, 62: if g_HeroUseItems[U_BOOTS].s.Name <> '' then Result := U_BOOTS; //鞋
    7, 53, 63: if g_HeroUseItems[U_CHARM].s.Name <> '' then Result := U_CHARM; //宝石
    54, 64: if g_HeroUseItems[U_BELT].s.Name <> '' then Result := U_BELT; //腰带
  end;
end;

function GetActorDir(nX, nY: Integer): string;
var
  ndir: Integer;
begin
  ndir := GetNextDirection(g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, nX, nY);
  case ndir of
    0: Result := '↑';
    1: Result := '↗';
    2: Result := '→';
    3: Result := '↘';
    4: Result := '↓';
    5: Result := '↙';
    6: Result := '←';
    7: Result := '↖';
  end;
end;



constructor TFileBossDB.Create(sFileName: string);
begin
  m_sDBFileName := sFileName;
  m_Header := 0;
  m_nFileHandle := 0;
  m_ShowBossList := TList.Create;
  m_HintBossList := TList.Create;
  m_DeleteList := TList.Create;
  LoadList();
end;

destructor TFileBossDB.Destroy;
var
  I: Integer;
begin
  for I := 0 to m_ShowBossList.Count - 1 do begin
    if m_ShowBossList.Items[I] <> nil then
      Dispose(m_ShowBossList.Items[I]);
  end;
  for I := 0 to m_HintBossList.Count - 1 do begin
    Dispose(m_HintBossList.Items[I]);
  end;
  m_ShowBossList.Free;
  m_HintBossList.Free;
  m_DeleteList.Free;
  inherited;
end;

function TFileBossDB.Open(): Boolean;
begin
  if FileExists(m_sDBFileName) then begin
    m_nFileHandle := FileOpen(m_sDBFileName, fmOpenReadWrite or fmShareDenyNone);
    if m_nFileHandle > 0 then
      FileRead(m_nFileHandle, m_Header, SizeOf(TDBHeader));
  end else begin
    m_nFileHandle := FileCreate(m_sDBFileName);
    if m_nFileHandle > 0 then begin
      m_Header := 0;
      FileWrite(m_nFileHandle, m_Header, SizeOf(TDBHeader));
    end;
  end;
  if m_nFileHandle > 0 then Result := True
  else Result := False;
end;

function TFileBossDB.OpenEx(): Boolean;
var
  DBHeader: TDBHeader;
begin
  m_nFileHandle := FileOpen(m_sDBFileName, fmOpenReadWrite or fmShareDenyNone);
  if m_nFileHandle > 0 then begin
    Result := True;
    if FileRead(m_nFileHandle, DBHeader, SizeOf(TDBHeader)) = SizeOf(TDBHeader) then
      m_Header := DBHeader;
  end else Result := False;
end;

procedure TFileBossDB.Close();
begin
  FileClose(m_nFileHandle);
end;

procedure TFileBossDB.LoadList();
var
  nIndex: Integer;
  DBHeader: TDBHeader;
  DBRecord: pTShowBoss;
begin
  try
    try
      if OpenEx then begin
        FileSeek(m_nFileHandle, 0, 0);
        if FileRead(m_nFileHandle, DBHeader, SizeOf(TDBHeader)) = SizeOf(TDBHeader) then begin
          for nIndex := 0 to DBHeader - 1 do begin
            New(DBRecord);
            SafeFillChar(DBRecord^, SizeOf(TShowBoss), #0);
            if FileRead(m_nFileHandle, DBRecord^, SizeOf(TShowBoss)) <> SizeOf(TShowBoss) then begin
              Dispose(DBRecord);
              Break;
            end;
            {if DBRecord.sBossName = '' then begin
              m_DeleteList.Add(Pointer(nIndex));
              m_ShowBossList.Add(nil);
              Dispose(DBRecord);
              Break;
            end; }
            m_ShowBossList.Add(DBRecord);
          end;
        end;
      end;
    finally
      Close();
    end;
  except

  end;
end;

function TFileBossDB.AddRecord(ShowBoss: pTShowBoss; var Index: Integer): Boolean;
var
  nIndex: Integer;
  nPosion, n10: Integer;
begin
  Result := False;
  try
    if Open then begin
      if m_DeleteList.Count > 0 then begin
        nIndex := Integer(m_DeleteList.Items[0]);
        m_DeleteList.Delete(0);
        Inc(m_Header);
        nPosion := SizeOf(TDBHeader) + nIndex * SizeOf(TShowBoss);
        if FileSeek(m_nFileHandle, nPosion, 0) = nPosion then begin
          n10 := FileSeek(m_nFileHandle, 0, 1);
          FileSeek(m_nFileHandle, 0, 0);
          FileWrite(m_nFileHandle, m_Header, SizeOf(TDBHeader));
          FileSeek(m_nFileHandle, n10, 0);
          FileWrite(m_nFileHandle, ShowBoss^, SizeOf(TShowBoss));
          FileSeek(m_nFileHandle, -SizeOf(TShowBoss), 1);
          Index := nIndex;
          Result := True;
        end;
      end else begin
        nIndex := m_Header;
        Inc(m_Header);
        FileSeek(m_nFileHandle, 0, 0);
        FileWrite(m_nFileHandle, m_Header, SizeOf(TDBHeader));
        FileSeek(m_nFileHandle, 0, 2);
        FileWrite(m_nFileHandle, ShowBoss^, SizeOf(TShowBoss));
        FileSeek(m_nFileHandle, -SizeOf(TShowBoss), 1);
        Index := nIndex;
        Result := True;
      end;
    end;
  finally
    Close();
  end;
end;

function TFileBossDB.DelRecord(Index: Integer): Boolean;
var
  nIndex: Integer;
  nPosion, n10: Integer;
  ShowBoss: TShowBoss;
begin
  Result := False;
  try
    if Open then begin
      nPosion := SizeOf(TDBHeader) + nIndex * SizeOf(TShowBoss);
      if FileSeek(m_nFileHandle, nPosion, 0) = nPosion then begin
        Dec(m_Header);
        m_DeleteList.Add(Pointer(Index));
        ShowBoss.sBossName := '';
        n10 := FileSeek(m_nFileHandle, 0, 1);
        FileSeek(m_nFileHandle, 0, 0);
        FileWrite(m_nFileHandle, m_Header, SizeOf(TDBHeader));
        FileSeek(m_nFileHandle, n10, 0);
        FileWrite(m_nFileHandle, ShowBoss, SizeOf(TShowBoss));
        FileSeek(m_nFileHandle, -SizeOf(TShowBoss), 1);
        Result := True;
      end;
    end;
  finally
    Close();
  end;
end;

procedure TFileBossDB.SaveToFile();
var
  DBRecord: pTShowBoss;
  ShowBoss: TShowBoss;
  I: Integer;
begin
  if FileExists(m_sDBFileName) then DeleteFile(m_sDBFileName);
  try
    if Open then begin
      m_Header := m_ShowBossList.Count;
      FileSeek(m_nFileHandle, 0, 0);
      FileWrite(m_nFileHandle, m_Header, SizeOf(TDBHeader));
      for I := 0 to m_ShowBossList.Count - 1 do begin
        DBRecord := pTShowBoss(m_ShowBossList.Items[I]);
        {if m_ShowBossList.Items[I] <> nil then
          FileWrite(m_nFileHandle, DBRecord^, SizeOf(TShowBoss))
        else begin
          ShowBoss.sBossName := '';
          FileWrite(m_nFileHandle, ShowBoss, SizeOf(TShowBoss));
        end; }
        FileWrite(m_nFileHandle, DBRecord^, SizeOf(TShowBoss))
      end;
    end;
  finally
    Close();
  end;
end;

procedure TFileBossDB.Delete(sBossName: string);
var
  DBRecord: pTShowBoss;
  I: Integer;
begin
  {for I := 0 to m_ShowBossList.Count - 1 do begin
    if m_ShowBossList.Items[I] <> nil then begin
      DBRecord := pTShowBoss(m_ShowBossList.Items[I]);
      if CompareText(DBRecord.sBossName, sBossName) = 0 then begin
        if DelRecord(I) then begin
          m_ShowBossList.Items[I] := nil;
          Dispose(DBRecord);
          Break;
        end;
      end;
    end;
  end; }
  for I := 0 to m_ShowBossList.Count - 1 do begin
    if m_ShowBossList.Items[I] <> nil then begin
      DBRecord := pTShowBoss(m_ShowBossList.Items[I]);
      if CompareText(DBRecord.sBossName, sBossName) = 0 then begin
        m_ShowBossList.Delete(I);
        Dispose(DBRecord);
        Break;
      end;
    end;
  end;
end;

function TFileBossDB.Add(ShowBoss: pTShowBoss): Boolean;
var
  Index: Integer;
begin
  Result := False;
  if Find(ShowBoss.sBossName) <> nil then Exit;
  m_ShowBossList.Add(ShowBoss);
  Result := True;
  {if AddRecord(ShowBoss, Index) then begin
    if Index = m_ShowBossList.Count - 1 then begin
      m_ShowBossList.Add(ShowBoss);
    end else begin
      m_ShowBossList.Items[Index] := ShowBoss;
    end;
    Result := True;
  end;}
end;

function TFileBossDB.Find(sBossName: string): pTShowBoss;
var
  DBRecord: pTShowBoss;
  I: Integer;
begin
  Result := nil;
  for I := 0 to m_ShowBossList.Count - 1 do begin
    if m_ShowBossList.Items[I] <> nil then begin
      DBRecord := pTShowBoss(m_ShowBossList.Items[I]);
      if CompareText(DBRecord.sBossName, sBossName) = 0 then begin
        Result := DBRecord;
        Break;
      end;
    end;
  end;
end;

procedure TFileBossDB.AddHintActor(Actor: TActor);
var
  I: Integer;
  HintBoss: pTHintBoss;
begin
  for I := 0 to m_HintBossList.Count - 1 do begin
    if Actor = pTHintBoss(m_HintBossList.Items[I]).Actor then Exit;
  end;
  New(HintBoss);
  HintBoss.boHint := False;
  HintBoss.Actor := Actor;
  m_HintBossList.Add(HintBoss);
end;

procedure TFileBossDB.Hint();
  function IsValidActor(Actor: TActor): Boolean;
  var
    I: Integer;
    ActorList: TList;
  begin
    Result := False;
    ActorList := PlayScene.m_ActorList;
    if ActorList <> nil then begin
      for I := 0 to ActorList.Count - 1 do begin
        if TActor(ActorList.Items[I]) = Actor then begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
var
  I: Integer;
  HintBoss: pTHintBoss;
  Actor: TActor;
  nCurrX, nCurrY, nX, nY: Integer;
  sHint, sName, sPosition: string;
  ShowBoss: pTShowBoss;
begin
  for I := m_HintBossList.Count - 1 downto 0 do begin
    HintBoss := pTHintBoss(m_HintBossList.Items[I]);
    if not PlayScene.IsValidActor(HintBoss.Actor) then begin
    //if not IsValidActor(HintBoss.Actor) then begin
      m_HintBossList.Delete(I);
      Dispose(HintBoss);
    end else begin
      if not HintBoss.boHint then begin
        HintBoss.boHint := True;
        sName := HintBoss.Actor.m_sUserName;
        ShowBoss := Find(sName);
        if (ShowBoss <> nil) and ShowBoss.boHintMsg then begin
          nX := HintBoss.Actor.m_nCurrX;
          nY := HintBoss.Actor.m_nCurrY;
          nCurrX := g_MySelf.m_nCurrX;
          nCurrY := g_MySelf.m_nCurrY;
          case GetNextDirection(nCurrX, nCurrY, nX, nY) of
            0: sPosition := '上';
            1: sPosition := '右上';
            2: sPosition := '右';
            3: sPosition := '右下';
            4: sPosition := '下';
            5: sPosition := '左下';
            6: sPosition := '左';
            7: sPosition := '左上';
          end;
          sHint := '[' + sName + ']已经出现，方位:' + sPosition + GetActorDir(nX, nY) + '，坐标:(' + Format('%d,%d', [nX, nY]) + ').';
          DScreen.AddChatBoardString(sHint, clyellow, clRed);
        end;
      end;
    end;
  end;
end;

constructor TFileItemDB.Create();
begin
  m_FileItemList := TList.Create;
  m_ShowItemList := THashTable.Create(10000);
end;

destructor TFileItemDB.Destroy;
var
  I: Integer;
begin
  for I := 0 to m_ShowItemList.Count - 1 do begin
    if m_ShowItemList.Items[I] <> nil then
      Dispose(m_ShowItemList.Items[I]);
  end;
  m_ShowItemList.Free;
  for I := 0 to m_FileItemList.Count - 1 do begin
    Dispose(m_FileItemList.Items[I]);
  end;
  m_FileItemList.Free;
  inherited;
end;

procedure TFileItemDB.LoadFormFile();
var
  nIndex: Integer;
  sDirectory: string;
  sFileName: string;
  sLineText, sItemName, sItemType, sHint, sPickUp, sShowName: string;
  LoadList: TStringList;
  ShowItem: pTShowItem;
begin
  if g_MySelf = nil then Exit;
  sDirectory := 'Config\';
  if not DirectoryExists(sDirectory) then CreateDir(sDirectory);
  sFileName := Format(ITEMFILTER, [g_sServerName, g_MySelf.m_sUserName]);

  LoadList := TStringList.Create;
  if FileExists(sFileName) then begin
    try
      LoadList.LoadFromFile(sFileName);
    except
      LoadList.Clear;
    end;
  end;
  for nIndex := 0 to LoadList.Count - 1 do begin
    sLineText := Trim(LoadList.Strings[nIndex]);
    if sLineText = '' then Continue;
    if (sLineText <> '') and (sLineText[1] = ';') then Continue;
    sLineText := GetValidStr3(sLineText, sItemName, [',', #9]);
    sLineText := GetValidStr3(sLineText, sItemType, [',', #9]);
    sLineText := GetValidStr3(sLineText, sHint, [',', #9]);
    sLineText := GetValidStr3(sLineText, sPickUp, [',', #9]);
    sLineText := GetValidStr3(sLineText, sShowName, [',', #9]);
    if (sItemName <> '') and (sItemType <> '') then begin
      ShowItem := Find(sItemName);
      if ShowItem <> nil then begin
        ShowItem.ItemType := GetItemType(sItemType);
        ShowItem.sItemType := sItemType;
        ShowItem.sItemName := sItemName;
        ShowItem.boHintMsg := sHint = '1';
        ShowItem.boPickup := sPickUp = '1';
        ShowItem.boShowName := sShowName = '1';
      end;
    end;
  end;
  LoadList.Free;
end;

procedure TFileItemDB.LoadFormList(LoadList: TStringList);
var
  nIndex, nItemType: Integer;
  sLineText, sItemName, sItemType, sHint, sPickUp, sShowName: string;
  ShowItem: pTShowItem;
  FileItem: pTShowItem;

begin
  for nIndex := 0 to LoadList.Count - 1 do begin
    sLineText := Trim(LoadList.Strings[nIndex]);
    if sLineText = '' then Continue;
    if (sLineText <> '') and (sLineText[1] = ';') then Continue;
    sLineText := GetValidStr3(sLineText, sItemType, [',', #9]);
    sLineText := GetValidStr3(sLineText, sItemName, [',', #9]);
    sLineText := GetValidStr3(sLineText, sHint, [',', #9]);
    sLineText := GetValidStr3(sLineText, sPickUp, [',', #9]);
    sLineText := GetValidStr3(sLineText, sShowName, [',', #9]);
    nItemType := Str_ToInt(sItemType, -1);
    if (sItemName <> '') and (nItemType in [0..6]) then begin
      New(ShowItem);
      ShowItem.ItemType := TItemType(nItemType);
      ShowItem.sItemType := GetItemTypeName(ShowItem.ItemType);
      ShowItem.sItemName := sItemName;
      ShowItem.boHintMsg := sHint = '1';
      ShowItem.boPickup := sPickUp = '1';
      ShowItem.boShowName := sShowName = '1';
      m_ShowItemList.Add(sItemName, sItemName, ShowItem);
      New(FileItem);
      FileItem^ := ShowItem^;
      m_FileItemList.Add(FileItem);
    end;
  end;
end;

procedure TFileItemDB.BackUp;
var
  I: Integer;
  ShowItem: pTShowItem;
begin
  for I := 0 to m_FileItemList.Count - 1 do begin
    ShowItem := m_ShowItemList.Datas[pTShowItem(m_FileItemList.Items[I]).sItemName];
    if ShowItem <> nil then
      ShowItem^ := pTShowItem(m_FileItemList.Items[I])^;
  end;
end;

procedure TFileItemDB.SaveToFile();
var
  I: Integer;
  sDirectory: string;
  sFileName: string;
  SaveList: TStringList;
  FileItem: pTShowItem;
  ShowItem: pTShowItem;
begin
  if g_MySelf = nil then Exit;
  sDirectory := 'Config\';
  if not DirectoryExists(sDirectory) then CreateDir(sDirectory);
  sFileName := Format(ITEMFILTER, [g_sServerName, g_MySelf.m_sUserName]);

  SaveList := TStringList.Create;
  for I := 0 to m_FileItemList.Count - 1 do begin
    FileItem := m_FileItemList.Items[I];
    ShowItem := Find(FileItem.sItemName);
    if ShowItem <> nil then begin
      if (FileItem.boHintMsg <> ShowItem.boHintMsg) or
        (FileItem.boPickup <> ShowItem.boPickup) or
        (FileItem.boShowName <> ShowItem.boShowName) then begin
        SaveList.Add(Format('%s,%s,%d,%d,%d', [ShowItem.sItemName, ShowItem.sItemType,
          BoolToInt(ShowItem.boHintMsg), BoolToInt(ShowItem.boPickup), BoolToInt(ShowItem.boShowName)]));
      end;
    end;
  end;
  try
    SaveList.SaveToFile(sFileName);
  except

  end;
  SaveList.Free;
end;

procedure TFileItemDB.Get(sItemType: string; var ItemList: TList);
var
  I: Integer;
  ShowItem: pTShowItem;
begin
  if ItemList = nil then Exit;
  for I := 0 to m_ShowItemList.Count - 1 do begin
    ShowItem := pTShowItem(m_ShowItemList.Items[I]);
    if ShowItem <> nil then
      if (sItemType = '(全部分类)') or (ShowItem.sItemType = sItemType) then begin
        ItemList.Add(ShowItem);
      end;
  end;
end;

procedure TFileItemDB.Get(ItemType: TItemType; var ItemList: TList);
var
  I: Integer;
  ShowItem: pTShowItem;
begin
  if ItemList = nil then Exit;
  for I := 0 to m_ShowItemList.Count - 1 do begin
    ShowItem := pTShowItem(m_ShowItemList.Items[I]);
    if ShowItem <> nil then
      if (ItemType = i_All) or (ShowItem.ItemType = ItemType) then begin
        ItemList.Add(ShowItem);
      end;
  end;
end;

function TFileItemDB.Add(ShowItem: pTShowItem): Boolean;
var
  Index: Integer;
begin
  Result := False;
  if Find(ShowItem.sItemName) <> nil then Exit;
  m_ShowItemList.Add(ShowItem.sItemName, ShowItem.sItemName, ShowItem);
  Result := True;
end;

function TFileItemDB.Find(sItemName: string): pTShowItem;
begin
  Result := m_ShowItemList.Datas[sItemName];
end;

procedure TFileItemDB.Hint(DropItem: pTDropItem);
var
  ShowItem: pTShowItem;
  nCurrX, nCurrY, nX, nY: Integer;
  sHint, sName, sPosition: string;
begin
  sName := DropItem.Name;
  ShowItem := Find(sName);
  if (g_MySelf <> nil) and (ShowItem <> nil) and ShowItem.boHintMsg then begin
    nX := DropItem.X;
    nY := DropItem.Y;
    nCurrX := g_MySelf.m_nCurrX;
    nCurrX := g_MySelf.m_nCurrY;
    case GetNextDirection(nCurrX, nCurrY, nX, nY) of
      0: sPosition := '上';
      1: sPosition := '右上';
      2: sPosition := '右';
      3: sPosition := '右下';
      4: sPosition := '下';
      5: sPosition := '左下';
      6: sPosition := '左';
      7: sPosition := '左上';
    end;
    sHint := '发现[' + sName + ']，方位:' + sPosition + GetActorDir(nX, nY) + '，坐标:(' + Format('%d,%d', [nX, nY]) + ').';
    DScreen.AddChatBoardString(sHint, clyellow, clBlue);
  end;
end;
{-------------------------------------------------------------------------------}

constructor TMapDesc.Create;
begin
  FStringList := TStringList.Create;
end;

destructor TMapDesc.Destroy;
var
  I, II: Integer;
  MapDescInfo: pTMapDescInfo;
  MapDescList: pTMapDescList;
begin
  for I := 0 to FStringList.Count - 1 do begin
    MapDescList := pTMapDescList(FStringList.Objects[I]);
    for II := 0 to MapDescList.Large.Count - 1 do begin
      Dispose(pTMapDescInfo(MapDescList.Large.Items[II]));
    end;
    for II := 0 to MapDescList.Small.Count - 1 do begin
      Dispose(pTMapDescInfo(MapDescList.Small.Items[II]));
    end;
    MapDescList.Large.Free;
    MapDescList.Small.Free;
    Dispose(MapDescList);
  end;
  FStringList.Free;
  inherited;
end;

procedure TMapDesc.LoadFromFile(const FileName: string);
var
  nIndex: Integer;
  LoadList: TStringList;
  sLineText, sMapName, sX, sY, sDescName, sColor, sBigMap: string;

  I, II: Integer;
  MapDescInfo: pTMapDescInfo;
  MapDescList: pTMapDescList;
begin
  for I := 0 to FStringList.Count - 1 do begin
    MapDescList := pTMapDescList(FStringList.Objects[I]);
    for II := 0 to MapDescList.Large.Count - 1 do begin
      Dispose(pTMapDescInfo(MapDescList.Large.Items[II]));
    end;
    for II := 0 to MapDescList.Small.Count - 1 do begin
      Dispose(pTMapDescInfo(MapDescList.Small.Items[II]));
    end;
    MapDescList.Large.Free;
    MapDescList.Small.Free;
    Dispose(MapDescList);
  end;
  FStringList.Clear;

  LoadList := TStringList.Create;

  if FileExists(FileName) then begin
    try
      LoadList.LoadFromFile(FileName);
    except
      LoadList.Clear;
    end;
  end;

  for I := 0 to LoadList.Count - 1 do begin
    sLineText := Trim(LoadList.Strings[I]);
    if sLineText = '' then Continue;
    if (sLineText <> '') and (sLineText[1] = ';') then Continue;
    sLineText := GetValidStr3(sLineText, sMapName, [',', #9]);
    sLineText := GetValidStr3(sLineText, sX, [',', #9]);
    sLineText := GetValidStr3(sLineText, sY, [',', #9]);
    sLineText := GetValidStr3(sLineText, sDescName, [',', #9]);
    sLineText := GetValidStr3(sLineText, sColor, [',', #9]);
    sLineText := GetValidStr3(sLineText, sBigMap, [',', #9]);
    if (sMapName <> '') and (sDescName <> '') and (sBigMap <> '') then begin
      nIndex := FStringList.IndexOf(sMapName);
      if nIndex < 0 then begin
        New(MapDescList);
        MapDescList.Large := TList.Create;
        MapDescList.Small := TList.Create;
        FStringList.AddObject(sMapName, TObject(MapDescList));
        nIndex := FStringList.IndexOf(sMapName);
      end;
      if nIndex >= 0 then begin
        New(MapDescInfo);
        MapDescInfo.sMapName := sMapName;
        MapDescInfo.sDescName := sDescName;
        MapDescInfo.nX := Str_ToInt(sX, -1);
        MapDescInfo.nY := Str_ToInt(sY, -1);
        MapDescInfo.FColor := TColor(StrToIntDef(sColor, 0));
        MapDescInfo.boBigMap := sBigMap = '0';
        MapDescList := pTMapDescList(FStringList.Objects[nIndex]);
        if MapDescInfo.boBigMap then begin
          MapDescList.Large.Add(MapDescInfo);
        end else begin
          MapDescList.Small.Add(MapDescInfo);
        end;
      end;
    end;
  end;
  LoadList.Free;
end;

function TMapDesc.Get(const MapName: string; const BigMap: Boolean; var DescList: TList): Boolean;
var
  nIndex: Integer;
begin
  Result := False;
  DescList := nil;
  nIndex := FStringList.IndexOf(MapName);
  if nIndex >= 0 then begin
    if BigMap then begin
      DescList := pTMapDescList(FStringList.Objects[nIndex]).Large;
    end else begin
      DescList := pTMapDescList(FStringList.Objects[nIndex]).Small;
    end;
    Result := True;
  end;
end;
{-------------------------------------------------------------------------------}

function GetDownFileName(sAddr: string): string;
var
  sFileName: string;
  I: Integer;
  nLen: Integer;
begin
  Result := '';
  nLen := 0;
  if sAddr = '' then Exit;
  for I := Length(sAddr) downto 1 do begin
    if sAddr[I] = '/' then begin
      nLen := I;
      Break;
    end;
    Result := sAddr[I] + Result;
  end;
end;

//目录尾加'\'修正

function AddDirSuffix(dir: string): string;
begin
  Result := Trim(dir);
  if Result = '' then Exit;
  if Result[Length(Result)] <> '\' then Result := Result + '\';
end;

function GetWinTempDir: string;
var
  buf: array[0..MAX_PATH] of AnsiChar;
begin
  GetTempPathA(MAX_PATH, buf);
  Result := AddDirSuffix(buf);
  //if Result[Length(Result)] <> '\' then Result := Result + '\';
end;

procedure SaveUserConfig();
var
  I: Integer;
  ini: TIniFile;
  sDirectory, sFileName: string;
begin
  if (g_MySelf = nil) or (not g_boLoadUserConfig) then Exit;

  sDirectory := 'Config\';
  if not DirectoryExists(sDirectory) then CreateDir(sDirectory);
  sFileName := Format(CONFIGFILE, [g_sServerName, g_MySelf.m_sUserName]);
  ini := TIniFile.Create(sFileName);
  if ini <> nil then begin
    ini.WriteBool('Basic', 'ShowActorLable', g_Config.boShowActorLable);
    ini.WriteBool('Basic', 'HideBlueLable', g_Config.boHideBlueLable);
    ini.WriteBool('Basic', 'ShowNumberLable', g_Config.boShowNumberLable);
    ini.WriteBool('Basic', 'ShowJobAndLevel', g_Config.boShowJobAndLevel);
    ini.WriteBool('Basic', 'ShowUserName', g_Config.boShowUserName);
    ini.WriteBool('Basic', 'ShowMonName', g_Config.boShowMonName);
    ini.WriteBool('Basic', 'ShowGreenHint', g_Config.boShowGreenHint);
    ini.WriteBool('Basic', 'ItemHint', g_Config.boItemHint);
    ini.WriteBool('Basic', 'MagicLock', g_Config.boMagicLock);
    ini.WriteBool('Basic', 'OrderItem:', g_Config.boOrderItem);
    ini.WriteBool('Basic', 'OnlyShowCharName', g_Config.boOnlyShowCharName);
    ini.WriteBool('Basic', 'PickUpItemAll', g_Config.boPickUpItemAll);
    ini.WriteBool('Basic', 'CloseGroup', g_Config.boCloseGroup);
    ini.WriteBool('Basic', 'Music', g_Config.boBGSound);
    ini.WriteBool('Basic', 'DuraWarning', g_Config.boDuraWarning);
    ini.WriteBool('Basic', 'NotNeedShift', g_Config.boNotNeedShift);

    ini.WriteBool('Basic', 'AutoHorse', g_Config.boAutoHorse);
    ini.WriteBool('Basic', 'CompareItem', g_Config.boCompareItem);

    ini.WriteBool('Basic', 'Guaji', g_Config.boGuaji);


    ini.WriteBool('Protect', 'RenewHumHPIsAuto1', g_Config.boRenewHumHPIsAuto1);
    ini.WriteBool('Protect', 'RenewHumMPIsAuto1', g_Config.boRenewHumMPIsAuto1);
    ini.WriteBool('Protect', 'RenewHumHPIsAuto2', g_Config.boRenewHumHPIsAuto2);
    ini.WriteBool('Protect', 'RenewHumMPIsAuto2', g_Config.boRenewHumMPIsAuto2);

    ini.WriteBool('Protect', 'RenewHeroHPIsAuto1', g_Config.boRenewHeroHPIsAuto1);
    ini.WriteBool('Protect', 'RenewHeroMPIsAuto1', g_Config.boRenewHeroMPIsAuto1);
    ini.WriteBool('Protect', 'RenewHeroHPIsAuto2', g_Config.boRenewHeroHPIsAuto2);
    ini.WriteBool('Protect', 'RenewHeroMPIsAuto2', g_Config.boRenewHeroMPIsAuto2);


    ini.WriteInteger('Protect', 'RenewHumHPIndex1', g_Config.nRenewHumHPIndex1);
    ini.WriteInteger('Protect', 'RenewHumMPIndex1', g_Config.nRenewHumMPIndex1);
    ini.WriteInteger('Protect', 'RenewHumHPIndex2', g_Config.nRenewHumHPIndex2);
    ini.WriteInteger('Protect', 'RenewHumMPIndex2', g_Config.nRenewHumMPIndex2);

    ini.WriteInteger('Protect', 'RenewHeroHPIndex1', g_Config.nRenewHeroHPIndex1);
    ini.WriteInteger('Protect', 'RenewHeroMPIndex1', g_Config.nRenewHeroMPIndex1);
    ini.WriteInteger('Protect', 'RenewHeroHPIndex2', g_Config.nRenewHeroHPIndex2);
    ini.WriteInteger('Protect', 'RenewHeroMPIndex2', g_Config.nRenewHeroMPIndex2);


    ini.WriteInteger('Protect', 'RenewHumHPTime1', g_Config.nRenewHumHPTime1);
    ini.WriteInteger('Protect', 'RenewHumHPPercent1', g_Config.nRenewHumHPPercent1);
    ini.WriteInteger('Protect', 'RenewHumMPTime1', g_Config.nRenewHumMPTime1);
    ini.WriteInteger('Protect', 'RenewHumMPPercent1', g_Config.nRenewHumMPPercent1);

    ini.WriteInteger('Protect', 'RenewHumHPTime2', g_Config.nRenewHumHPTime2);
    ini.WriteInteger('Protect', 'RenewHumHPPercent2', g_Config.nRenewHumHPPercent2);
    ini.WriteInteger('Protect', 'RenewHumMPTime2', g_Config.nRenewHumMPTime2);
    ini.WriteInteger('Protect', 'RenewHumMPPercent2', g_Config.nRenewHumMPPercent2);


    ini.WriteInteger('Protect', 'RenewHeroHPTime1', g_Config.nRenewHeroHPTime1);
    ini.WriteInteger('Protect', 'RenewHeroHPPercent1', g_Config.nRenewHeroHPPercent1);
    ini.WriteInteger('Protect', 'RenewHeroMPTime1', g_Config.nRenewHeroMPTime1);
    ini.WriteInteger('Protect', 'RenewHeroMPPercent1', g_Config.nRenewHeroMPPercent1);

    ini.WriteInteger('Protect', 'RenewHeroHPTime2', g_Config.nRenewHeroHPTime2);
    ini.WriteInteger('Protect', 'RenewHeroHPPercent2', g_Config.nRenewHeroHPPercent2);
    ini.WriteInteger('Protect', 'RenewHeroMPTime2', g_Config.nRenewHeroMPTime2);
    ini.WriteInteger('Protect', 'RenewHeroMPPercent2', g_Config.nRenewHeroMPPercent2);


    ini.WriteBool('Protect', 'RenewBookIsAuto', g_Config.boRenewBookIsAuto);
    ini.WriteInteger('Protect', 'RenewBookTime', g_Config.nRenewBookTime);
    ini.WriteInteger('Protect', 'RenewBookPercent', g_Config.nRenewBookPercent);
    ini.WriteInteger('Protect', 'RenewBookNowBookIndex', g_Config.nRenewBookNowBookIndex);
    ini.WriteString('Protect', 'RenewBookNowBookItem', g_Config.sRenewBookNowBookItem);


    ini.WriteBool('Tec', 'AutoHideMode', g_Config.boAutoHideMode);
    ini.WriteBool('Tec', 'AutoUseMagic', g_Config.boAutoUseMagic);
    ini.WriteInteger('Tec', 'AutoHideModeTime', g_Config.nAutoHideModeTime);
    ini.WriteInteger('Tec', 'AutoUseMagicTime', g_Config.nAutoUseMagicTime);
    ini.WriteInteger('Tec', 'AutoUseMagicIdx', g_Config.nAutoUseMagicIdx);

    ini.WriteBool('Tec', 'SmartLongHit', g_Config.boSmartLongHit);
    ini.WriteBool('Tec', 'SmartWideHit', g_Config.boSmartWideHit);
    ini.WriteBool('Tec', 'SmartFireHit', g_Config.boSmartFireHit);
    ini.WriteBool('Tec', 'SmartSwordHit', g_Config.boSmartSwordHit);
    ini.WriteBool('Tec', 'SmartCrsHit', g_Config.boSmartCrsHit);

    ini.WriteBool('Tec', 'SmartKaitHit', g_Config.boSmartKaitHit);
    ini.WriteBool('Tec', 'SmartPokHit', g_Config.boSmartPokHit);

    ini.WriteBool('Tec', 'SmartShield', g_Config.boSmartShield);
    ini.WriteBool('Tec', 'SmartWjzq', g_Config.boSmartWjzq);
    ini.WriteBool('Tec', 'StruckShield', g_Config.boStruckShield);


    ini.WriteBool('Tec', 'SmartPosLongHit', g_Config.boSmartPosLongHit);
    ini.WriteBool('Tec', 'SmartWalkLongHit', g_Config.boSmartWalkLongHit);


    ini.WriteBool('Tec', 'RenewCloseIsAuto', g_Config.boRenewCloseIsAuto);
    ini.WriteBool('Tec', 'RenewChangeSignIsAuto', g_Config.boRenewChangeSignIsAuto);
    ini.WriteBool('Tec', 'RenewChangePoisonIsAuto', g_Config.boRenewChangePoisonIsAuto);
    ini.WriteBool('Tec', 'RenewHeroLogOutIsAuto', g_Config.boRenewHeroLogOutIsAuto);


    ini.WriteInteger('Protect', 'RenewCloseTime', g_Config.nRenewCloseTime);
    ini.WriteInteger('Protect', 'RenewClosePercent', g_Config.nRenewClosePercent);
    ini.WriteInteger('Protect', 'RenewPoisonIndex', g_Config.nRenewPoisonIndex);
    ini.WriteInteger('Protect', 'RenewHeroLogOutTime', g_Config.nRenewHeroLogOutTime);
    ini.WriteInteger('Protect', 'RenewHeroLogOutPercent', g_Config.nRenewHeroLogOutPercent);


    ini.WriteBool('Protect', 'ChangeSign', g_Config.boChangeSign);
    ini.WriteBool('Protect', 'ChangePoison', g_Config.boChangePoison);
    ini.WriteInteger('Protect', 'PoisonIndex', g_Config.nPoisonIndex);


    ini.WriteBool('Hotkey', 'UseHotkey', g_Config.boUseHotkey);
    ini.WriteInteger('Hotkey', 'SerieSkill', g_Config.nSerieSkill);
    ini.WriteInteger('Hotkey', 'HeroCallHero', g_Config.nHeroCallHero);
    ini.WriteInteger('Hotkey', 'HeroSetTarget', g_Config.nHeroSetTarget);
    ini.WriteInteger('Hotkey', 'HeroUnionHit', g_Config.nHeroUnionHit);
    ini.WriteInteger('Hotkey', 'HeroSetAttackState', g_Config.nHeroSetAttackState);
    ini.WriteInteger('Hotkey', 'HeroSetGuard', g_Config.nHeroSetGuard);
    ini.WriteInteger('Hotkey', 'SwitchAttackMode', g_Config.nSwitchAttackMode);
    ini.WriteInteger('Hotkey', 'SwitchMiniMap', g_Config.nSwitchMiniMap);

    for I := 0 to 7 do begin
      ini.WriteInteger('SerieSkill', 'MagicID' + IntToStr(I), g_SerieMagic[I].nMagicID);
    end;

    ini.Free;
  end;
end;

procedure LoadUserConfig();
var
  I: Integer;
  ini: TIniFile;
  sDirectory, sFileName: string;
begin
  if g_MySelf = nil then Exit;
  sDirectory := 'Config\';
  if not DirectoryExists(sDirectory) then CreateDir(sDirectory);
  sFileName := Format(CONFIGFILE, [g_sServerName, g_MySelf.m_sUserName]);
  ini := TIniFile.Create(sFileName);
  if ini <> nil then begin
    //DebugOutStr('LoadUserConfig();');
    g_Config.boShowActorLable := ini.ReadBool('Basic', 'ShowActorLable', g_Config.boShowActorLable);
    g_Config.boHideBlueLable := ini.ReadBool('Basic', 'HideBlueLable', g_Config.boHideBlueLable);
    g_Config.boShowNumberLable := ini.ReadBool('Basic', 'ShowNumberLable', g_Config.boShowNumberLable);
    g_Config.boShowJobAndLevel := ini.ReadBool('Basic', 'ShowJobAndLevel', g_Config.boShowJobAndLevel);
    g_Config.boShowUserName := ini.ReadBool('Basic', 'ShowUserName', g_Config.boShowUserName);
    g_Config.boShowMonName := ini.ReadBool('Basic', 'ShowMonName', g_Config.boShowMonName);
    g_Config.boShowGreenHint := ini.ReadBool('Basic', 'ShowGreenHint', g_Config.boShowGreenHint);
    g_Config.boItemHint := ini.ReadBool('Basic', 'ItemHint', g_Config.boItemHint);
    g_Config.boMagicLock := ini.ReadBool('Basic', 'MagicLock', g_Config.boMagicLock);
    g_Config.boOrderItem := ini.ReadBool('Basic', 'OrderItem:', g_Config.boOrderItem);
    g_Config.boOnlyShowCharName := ini.ReadBool('Basic', 'OnlyShowCharName', g_Config.boOnlyShowCharName);
    g_Config.boPickUpItemAll := ini.ReadBool('Basic', 'PickUpItemAll', g_Config.boPickUpItemAll);
    g_Config.boCloseGroup := ini.ReadBool('Basic', 'CloseGroup', g_Config.boCloseGroup);
    g_Config.boBGSound := ini.ReadBool('Basic', 'Music', g_Config.boBGSound);
    g_Config.boDuraWarning := ini.ReadBool('Basic', 'DuraWarning', g_Config.boDuraWarning);
    g_Config.boNotNeedShift := ini.ReadBool('Basic', 'NotNeedShift', g_Config.boNotNeedShift);
    g_Config.boAutoHorse := ini.ReadBool('Basic', 'AutoHorse', g_Config.boAutoHorse);
    g_Config.boCompareItem := ini.ReadBool('Basic', 'CompareItem', g_Config.boCompareItem);
    g_Config.boGuaji := ini.ReadBool('Basic', 'Guaji', g_Config.boGuaji);


    g_boBGSound := g_Config.boBGSound;

//==================================================================================================

    g_Config.boRenewHumHPIsAuto1 := ini.ReadBool('Protect', 'RenewHumHPIsAuto1', g_Config.boRenewHumHPIsAuto1);
    g_Config.boRenewHumMPIsAuto1 := ini.ReadBool('Protect', 'RenewHumMPIsAuto1', g_Config.boRenewHumMPIsAuto1);
    g_Config.boRenewHumHPIsAuto2 := ini.ReadBool('Protect', 'RenewHumHPIsAuto2', g_Config.boRenewHumHPIsAuto2);
    g_Config.boRenewHumMPIsAuto2 := ini.ReadBool('Protect', 'RenewHumMPIsAuto2', g_Config.boRenewHumMPIsAuto2);

    g_Config.boRenewHeroHPIsAuto1 := ini.ReadBool('Protect', 'RenewHeroHPIsAuto1', g_Config.boRenewHeroHPIsAuto1);
    g_Config.boRenewHeroMPIsAuto1 := ini.ReadBool('Protect', 'RenewHeroMPIsAuto1', g_Config.boRenewHeroMPIsAuto1);
    g_Config.boRenewHeroHPIsAuto2 := ini.ReadBool('Protect', 'RenewHeroHPIsAuto2', g_Config.boRenewHeroHPIsAuto2);
    g_Config.boRenewHeroMPIsAuto2 := ini.ReadBool('Protect', 'RenewHeroMPIsAuto2', g_Config.boRenewHeroMPIsAuto2);


    g_Config.nRenewHumHPIndex1 := ini.ReadInteger('Protect', 'RenewHumHPIndex1', g_Config.nRenewHumHPIndex1);
    g_Config.nRenewHumMPIndex1 := ini.ReadInteger('Protect', 'RenewHumMPIndex1', g_Config.nRenewHumMPIndex1);
    g_Config.nRenewHumHPIndex2 := ini.ReadInteger('Protect', 'RenewHumHPIndex2', g_Config.nRenewHumHPIndex2);
    g_Config.nRenewHumMPIndex2 := ini.ReadInteger('Protect', 'RenewHumMPIndex2', g_Config.nRenewHumMPIndex2);

    g_Config.nRenewHeroHPIndex1 := ini.ReadInteger('Protect', 'RenewHeroHPIndex1', g_Config.nRenewHeroHPIndex1);
    g_Config.nRenewHeroMPIndex1 := ini.ReadInteger('Protect', 'RenewHeroMPIndex1', g_Config.nRenewHeroMPIndex1);
    g_Config.nRenewHeroHPIndex2 := ini.ReadInteger('Protect', 'RenewHeroHPIndex2', g_Config.nRenewHeroHPIndex2);
    g_Config.nRenewHeroMPIndex2 := ini.ReadInteger('Protect', 'RenewHeroMPIndex2', g_Config.nRenewHeroMPIndex2);


    g_Config.nRenewHumHPTime1 := ini.ReadInteger('Protect', 'RenewHumHPTime1', g_Config.nRenewHumHPTime1);
    g_Config.nRenewHumHPPercent1 := ini.ReadInteger('Protect', 'RenewHumHPPercent1', g_Config.nRenewHumHPPercent1);
    g_Config.nRenewHumMPTime1 := ini.ReadInteger('Protect', 'RenewHumMPTime1', g_Config.nRenewHumMPTime1);
    g_Config.nRenewHumMPPercent1 := ini.ReadInteger('Protect', 'RenewHumMPPercent1', g_Config.nRenewHumMPPercent1);

    g_Config.nRenewHumHPTime2 := ini.ReadInteger('Protect', 'RenewHumHPTime2', g_Config.nRenewHumHPTime2);
    g_Config.nRenewHumHPPercent2 := ini.ReadInteger('Protect', 'RenewHumHPPercent2', g_Config.nRenewHumHPPercent2);
    g_Config.nRenewHumMPTime2 := ini.ReadInteger('Protect', 'RenewHumMPTime2', g_Config.nRenewHumMPTime2);
    g_Config.nRenewHumMPPercent2 := ini.ReadInteger('Protect', 'RenewHumMPPercent2', g_Config.nRenewHumMPPercent2);


    g_Config.nRenewHeroHPTime1 := ini.ReadInteger('Protect', 'RenewHeroHPTime1', g_Config.nRenewHeroHPTime1);
    g_Config.nRenewHeroHPPercent1 := ini.ReadInteger('Protect', 'RenewHeroHPPercent1', g_Config.nRenewHeroHPPercent1);
    g_Config.nRenewHeroMPTime1 := ini.ReadInteger('Protect', 'RenewHeroMPTime1', g_Config.nRenewHeroMPTime1);
    g_Config.nRenewHeroMPPercent1 := ini.ReadInteger('Protect', 'RenewHeroMPPercent1', g_Config.nRenewHeroMPPercent1);

    g_Config.nRenewHeroHPTime2 := ini.ReadInteger('Protect', 'RenewHeroHPTime2', g_Config.nRenewHeroHPTime2);
    g_Config.nRenewHeroHPPercent2 := ini.ReadInteger('Protect', 'RenewHeroHPPercent2', g_Config.nRenewHeroHPPercent2);
    g_Config.nRenewHeroMPTime2 := ini.ReadInteger('Protect', 'RenewHeroMPTime2', g_Config.nRenewHeroMPTime2);
    g_Config.nRenewHeroMPPercent2 := ini.ReadInteger('Protect', 'RenewHeroMPPercent2', g_Config.nRenewHeroMPPercent2);











    g_Config.boRenewBookIsAuto := ini.ReadBool('Protect', 'RenewBookIsAuto', g_Config.boRenewBookIsAuto);

    g_Config.nRenewBookTime := ini.ReadInteger('Protect', 'RenewBookTime', g_Config.nRenewBookTime);
    g_Config.nRenewBookPercent := ini.ReadInteger('Protect', 'RenewBookPercent', g_Config.nRenewBookPercent);
    g_Config.nRenewBookNowBookIndex := ini.ReadInteger('Protect', 'RenewBookNowBookIndex', g_Config.nRenewBookNowBookIndex);
    g_Config.sRenewBookNowBookItem := ini.ReadString('Protect', 'RenewBookNowBookItem', g_Config.sRenewBookNowBookItem);

    g_Config.boAutoHideMode := ini.ReadBool('Tec', 'AutoHideMode', g_Config.boAutoHideMode);
    g_Config.boAutoUseMagic := ini.ReadBool('Tec', 'AutoUseMagic', g_Config.boAutoUseMagic);
    g_Config.nAutoHideModeTime := ini.ReadInteger('Tec', 'AutoHideModeTime', g_Config.nAutoHideModeTime);
    g_Config.nAutoUseMagicTime := _MAX(ini.ReadInteger('Tec', 'AutoUseMagicTime', g_Config.nAutoUseMagicTime), 1);
    g_Config.nAutoUseMagicIdx := ini.ReadInteger('Tec', 'AutoUseMagicIdx', g_Config.nAutoUseMagicIdx);

    g_Config.boSmartLongHit := ini.ReadBool('Tec', 'SmartLongHit', g_Config.boSmartLongHit);
    g_Config.boSmartWideHit := ini.ReadBool('Tec', 'SmartWideHit', g_Config.boSmartWideHit);
    g_Config.boSmartFireHit := ini.ReadBool('Tec', 'SmartFireHit', g_Config.boSmartFireHit);
    g_Config.boSmartSwordHit := ini.ReadBool('Tec', 'SmartSwordHit', g_Config.boSmartSwordHit);
    g_Config.boSmartCrsHit := ini.ReadBool('Tec', 'SmartCrsHit', g_Config.boSmartCrsHit);

    g_Config.boSmartKaitHit := ini.ReadBool('Tec', 'SmartKaitHit', g_Config.boSmartKaitHit);
    g_Config.boSmartPokHit := ini.ReadBool('Tec', 'SmartPokHit', g_Config.boSmartPokHit);

    g_Config.boSmartShield := ini.ReadBool('Tec', 'SmartShield', g_Config.boSmartShield);
    g_Config.boSmartWjzq := ini.ReadBool('Tec', 'SmartWjzq', g_Config.boSmartWjzq);
    g_Config.boStruckShield := ini.ReadBool('Tec', 'StruckShield', g_Config.boStruckShield);


    g_Config.boSmartPosLongHit := ini.ReadBool('Tec', 'SmartPosLongHit', g_Config.boSmartPosLongHit);
    g_Config.boSmartWalkLongHit := ini.ReadBool('Tec', 'SmartWalkLongHit', g_Config.boSmartWalkLongHit);


    g_Config.boRenewCloseIsAuto := ini.ReadBool('Tec', 'RenewCloseIsAuto', g_Config.boRenewCloseIsAuto);
    g_Config.boRenewChangeSignIsAuto := ini.ReadBool('Tec', 'RenewChangeSignIsAuto', g_Config.boRenewChangeSignIsAuto);
    g_Config.boRenewChangePoisonIsAuto := ini.ReadBool('Tec', 'RenewChangePoisonIsAuto', g_Config.boRenewChangePoisonIsAuto);
    g_Config.boRenewHeroLogOutIsAuto := ini.ReadBool('Tec', 'RenewHeroLogOutIsAuto', g_Config.boRenewHeroLogOutIsAuto);


    g_Config.nRenewCloseTime := ini.ReadInteger('Protect', 'RenewCloseTime', g_Config.nRenewCloseTime);
    g_Config.nRenewClosePercent := ini.ReadInteger('Protect', 'RenewClosePercent', g_Config.nRenewClosePercent);
    g_Config.nRenewPoisonIndex := ini.ReadInteger('Protect', 'RenewPoisonIndex', g_Config.nRenewPoisonIndex);
    g_Config.nRenewHeroLogOutTime := ini.ReadInteger('Protect', 'RenewHeroLogOutTime', g_Config.nRenewHeroLogOutTime);
    g_Config.nRenewHeroLogOutPercent := ini.ReadInteger('Protect', 'RenewHeroLogOutPercent', g_Config.nRenewHeroLogOutPercent);


    g_Config.boChangeSign := ini.ReadBool('Protect', 'ChangeSign', g_Config.boChangeSign);
    g_Config.boChangePoison := ini.ReadBool('Protect', 'ChangePoison', g_Config.boChangePoison);
    g_Config.nPoisonIndex := ini.ReadInteger('Protect', 'PoisonIndex', g_Config.nPoisonIndex);
//==================================================================================================


    g_Config.boUseHotkey := ini.ReadBool('Hotkey', 'UseHotkey', g_Config.boUseHotkey);
    g_Config.nSerieSkill := ini.ReadInteger('Hotkey', 'SerieSkill', g_Config.nSerieSkill);
    g_Config.nHeroCallHero := ini.ReadInteger('Hotkey', 'HeroCallHero', g_Config.nHeroCallHero);
    g_Config.nHeroSetTarget := ini.ReadInteger('Hotkey', 'HeroSetTarget', g_Config.nHeroSetTarget);
    g_Config.nHeroUnionHit := ini.ReadInteger('Hotkey', 'HeroUnionHit', g_Config.nHeroUnionHit);
    g_Config.nHeroSetAttackState := ini.ReadInteger('Hotkey', 'HeroSetAttackState', g_Config.nHeroSetAttackState);
    g_Config.nHeroSetGuard := ini.ReadInteger('Hotkey', 'HeroSetGuard', g_Config.nHeroSetGuard);
    g_Config.nSwitchAttackMode := ini.ReadInteger('Hotkey', 'SwitchAttackMode', g_Config.nSwitchAttackMode);
    g_Config.nSwitchMiniMap := ini.ReadInteger('Hotkey', 'SwitchMiniMap', g_Config.nSwitchMiniMap);

    for I := 0 to 7 do begin
      g_SerieMagic[I].nMagicID := ini.ReadInteger('SerieSkill', 'MagicID' + IntToStr(I), -1);
      g_SerieMagic[I].Magic.Def.wMagicId := 0;
      g_SerieMagic[I].Magic.Def.sMagicName := '';
    end;

    ini.Free;

    if g_boBGSound then begin
      PlayMapMusic(True);
    end else begin
      PlayMapMusic(False);
    end;

    g_ShowItemList.LoadFormFile;
  end;
end;

initialization
  begin
    g_ClientSpeedTime := TSortStringList.Create;
    //InitializeCriticalSection(g_Flib_CS);
  end;
finalization
  begin
    g_ClientSpeedTime.Free;
    //DeleteCriticalSection(g_Flib_CS);
  end;
end.

