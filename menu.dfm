object frmMenu: TfrmMenu
  Left = 258
  Top = 171
  BorderStyle = bsNone
  Caption = 'AIChatBar'
  ClientHeight = 597
  ClientWidth = 762
  Color = clSilver
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PopupMenu = pm1
  StyleElements = [seFont]
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnShow = FormShow
  TextHeight = 13
  object imgMenu: TSkSvg
    Left = 16
    Top = 180
    Width = 48
    Height = 48
    Visible = False
    OnClick = imgMenuClick
    Svg.Source = 
      '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'#13#10'<!-- Cre' +
      'ated with Inkscape (http://www.inkscape.org/) -->'#13#10#13#10'<svg'#13#10'   wi' +
      'dth="512"'#13#10'   height="512"'#13#10'   viewBox="0 0 135.46666 135.46667"' +
      #13#10'   version="1.1"'#13#10'   id="svg5"'#13#10'   xml:space="preserve"'#13#10'   so' +
      'dipodi:docname="windows11logo.svg"'#13#10'   inkscape:version="1.2.2 (' +
      '732a01da63, 2022-12-09)"'#13#10'   xmlns:inkscape="http://www.inkscape' +
      '.org/namespaces/inkscape"'#13#10'   xmlns:sodipodi="http://sodipodi.so' +
      'urceforge.net/DTD/sodipodi-0.dtd"'#13#10'   xmlns:xlink="http://www.w3' +
      '.org/1999/xlink"'#13#10'   xmlns="http://www.w3.org/2000/svg"'#13#10'   xmln' +
      's:svg="http://www.w3.org/2000/svg"><sodipodi:namedview'#13#10'     id=' +
      '"namedview7"'#13#10'     pagecolor="#ffffff"'#13#10'     bordercolor="#00000' +
      '0"'#13#10'     borderopacity="0.25"'#13#10'     inkscape:showpageshadow="2"'#13 +
      #10'     inkscape:pageopacity="0.0"'#13#10'     inkscape:pagecheckerboard' +
      '="0"'#13#10'     inkscape:deskcolor="#d1d1d1"'#13#10'     inkscape:document-' +
      'units="mm"'#13#10'     showgrid="false"'#13#10'     inkscape:zoom="1.2938725' +
      '"'#13#10'     inkscape:cx="286.3497"'#13#10'     inkscape:cy="284.03108"'#13#10'  ' +
      '   inkscape:window-width="2560"'#13#10'     inkscape:window-height="13' +
      '51"'#13#10'     inkscape:window-x="-9"'#13#10'     inkscape:window-y="-9"'#13#10' ' +
      '    inkscape:window-maximized="1"'#13#10'     inkscape:current-layer="' +
      'layer1" /><defs'#13#10'     id="defs2"><linearGradient'#13#10'       inkscap' +
      'e:collect="always"'#13#10'       id="linearGradient30042"><stop'#13#10'     ' +
      '    style="stop-color:#7cdefe;stop-opacity:1"'#13#10'         offset="' +
      '0"'#13#10'         id="stop30038" /><stop'#13#10'         style="stop-color:' +
      '#0695f9;stop-opacity:1"'#13#10'         offset="1"'#13#10'         id="stop3' +
      '0040" /></linearGradient><linearGradient'#13#10'       inkscape:collec' +
      't="always"'#13#10'       xlink:href="#linearGradient30042"'#13#10'       id=' +
      '"linearGradient30044"'#13#10'       x1="-85.987831"'#13#10'       y1="32.207' +
      '096"'#13#10'       x2="-44.578709"'#13#10'       y2="74.0252"'#13#10'       gradie' +
      'ntUnits="userSpaceOnUse"'#13#10'       gradientTransform="matrix(1.632' +
      '8351,0,0,1.6328351,176.48092,-17.87388)" /></defs><g'#13#10'     inksc' +
      'ape:label="Layer 1"'#13#10'     inkscape:groupmode="layer"'#13#10'     id="l' +
      'ayer1"><path'#13#10'       id="path29547"'#13#10'       style="fill:url(#lin' +
      'earGradient30044);fill-opacity:1;stroke-width:0.43202"'#13#10'       d' +
      '="m 101.17511,26.124752 c -1.473925,-0.0039 -2.985,0.105808 -4.4' +
      '41717,0.120667 H 85.932875 l -14.44739,0.0085 a 0.21601046,0.220' +
      '33068 0 0 0 -0.216008,0.220228 l -0.0082,14.658336 v 11.664566 c' +
      ' 0.02629,0.0051 0.05143,0.0091 0.07511,0.01094 -0.02368,-0.002 -' +
      '0.04882,-0.0051 -0.07511,-0.01012 l 0.0082,12.930251 a 0.2160104' +
      '6,0.22033068 0 0 0 0.216008,0.22023 l 0.622714,0.0085 h 14.25669' +
      '1 6.912346 l 16.848814,0.01274 a 0.21169026,0.21169026 0 0 0 0.2' +
      '1095,-0.211791 l -0.0127,-16.524827 -0.043,-4.423152 c 0.0994,-4' +
      '.799744 0.80774,-11.976367 -0.89442,-14.801781 -1.90683,-3.31764' +
      '3 -4.96912,-3.874494 -8.21178,-3.883125 z m -63.991408,0.05232 c' +
      ' -1.438936,-3.6e-4 -2.857821,0.09274 -4.009688,0.49615 -5.702676' +
      ',1.987291 -4.9293,7.404308 -4.89906,12.407101 l 0.0082,10.295094' +
      ' -0.0082,6.013697 -0.01306,10.368503 a 0.21169026,0.21169026 0 0' +
      ' 0 0.211795,0.211791 l 9.288448,-0.01274 h 11.016526 l 18.982769' +
      ',-0.0085 a 0.21601046,0.21601046 0 0 0 0.216008,-0.216011 l 0.00' +
      '82,-17.890054 V 34.219952 l 0.01306,-7.776377 a 0.21169026,0.211' +
      '69026 0 0 0 -0.211795,-0.210948 l -9.504455,0.01274 H 50.938088 ' +
      '40.46159 c -1.028212,-0.01127 -2.159816,-0.06807 -3.278978,-0.06' +
      '835 z m 56.393927,5.132782 c -0.07152,0.07095 -0.145486,0.141828' +
      ' -0.222768,0.210947 -0.339744,0.303441 -0.678475,0.610173 -1.015' +
      '084,0.919732 0.336788,-0.309726 0.675161,-0.616975 1.015084,-0.9' +
      '20576 0.07723,-0.06912 0.151201,-0.139167 0.222768,-0.210103 z m' +
      ' 11.109341,0.252292 a 0.24625194,0.47954325 30.3 0 0 -0.10801,0.' +
      '113907 c -0.0955,0.123932 -0.19381,0.245056 -0.29363,0.364519 0.' +
      '0998,-0.119459 0.1972,-0.240582 0.29278,-0.364519 a 0.24625194,0' +
      '.47954325 30.3 0 1 0.10886,-0.113907 z m -61.168929,4.22655 h 8.' +
      '49e-4 c -0.104175,0.103048 -0.206489,0.207412 -0.305455,0.313045' +
      ' 0.09895,-0.105628 0.200513,-0.210004 0.304606,-0.313045 z M 29.' +
      '137303,55.609344 a 0.2721732,0.2764934 27.7 0 1 0.113972,0.01355' +
      ' 0.2721732,0.2764934 27.7 0 0 -0.151037,-0.0016 0.2721732,0.2764' +
      '934 27.7 0 1 0.03706,-0.01176 z m 27.258679,1.056426 a 0.1382467' +
      '1,0.17280837 49.1 0 1 0.0065,0.0067 0.13824671,0.17280837 49.1 0' +
      ' 0 -0.02449,-0.0059 0.13824671,0.17280837 49.1 0 1 0.0178,-8.43e' +
      '-4 z m 16.476694,8.755174 0.855606,0.124879 c 0.03315,0.0051 0.0' +
      '627,0.01094 0.08866,0.01688 -0.02613,-0.006 -0.05519,-0.01094 -0' +
      '.08866,-0.016 z m -44.398582,3.149871 a 0.21169026,0.21169026 0 ' +
      '0 0 -0.211795,0.210948 l 0.01306,10.800524 v 16.525645 c -0.0476' +
      '8,4.220528 -0.725109,8.229778 3.223282,10.925408 1.696401,1.1059' +
      '7 3.568496,1.52644 5.616267,1.26146 h 15.552754 l 15.120738,0.01' +
      '27 a 0.21169026,0.21169026 0 0 0 0.210946,-0.21179 L 67.986286,9' +
      '3.407039 V 84.550602 71.373963 l -0.0082,-2.565968 a 0.21169026,' +
      '0.21601046 0 0 0 -0.211778,-0.216011 l -8.834504,-0.0085 H 42.73' +
      '1027 Z m 81.651956,0 -10.3685,0.01274 H 89.17304 l -17.682494,0.' +
      '0085 a 0.22033068,0.22033068 0 0 0 -0.221069,0.22023 l -0.0082,1' +
      '7.574477 v 11.772571 l 0.336674,-3.326224 a 0.24625194,0.2030498' +
      '5 87.7 0 1 0.04637,-0.119818 0.24625194,0.20304985 87.7 0 0 -0.0' +
      '4556,0.119818 l -0.337523,3.326224 0.0082,9.906947 a 0.21601046,' +
      '0.22033068 0 0 0 0.216008,0.22023 l 1.486762,0.008 7.240578,0.00' +
      '8 13.712435,-0.008 c 3.499361,0.0173 9.115709,0.60486 12.057779,' +
      '-0.61343 3.53392,-1.46887 4.37611,-4.40713 4.36746,-8.187308 -0.' +
      '006,-2.713084 -0.0147,-5.426121 -0.0262,-8.139206 V 78.394412 75' +
      '.802286 l 0.0136,-7.020341 a 0.21169026,0.21169026 0 0 0 -0.2117' +
      '9,-0.210948 z m -17.924656,7.043123 c -0.0049,0.0038 -0.0082,0.0' +
      '08 -0.01306,0.01176 -0.31161,0.245711 -0.610762,0.498227 -0.9011' +
      '78,0.75688 0.290416,-0.258653 0.589568,-0.512011 0.901178,-0.757' +
      '724 0.0049,-0.0036 0.0082,-0.0073 0.01306,-0.01094 z m 17.973596' +
      ',2.068133 8.4e-4,8.42e-4 c 0.0111,0.02755 0.0241,0.07224 0.0388,' +
      '0.13417 -0.0147,-0.06192 -0.0285,-0.107473 -0.0397,-0.135003 z m' +
      ' -80.646998,3.052831 c 0.03151,-4.4e-4 0.06368,-4.72e-4 0.09536,' +
      '0 -0.06319,-9.46e-4 -0.126218,-1.7e-4 -0.189001,0.0026 0.03135,-' +
      '0.0014 0.06221,-0.0021 0.09372,-0.0026 z m 13.202794,0.895262 -0' +
      '.107931,0.0093 c -0.03233,0.0029 -0.05862,0.0026 -0.07756,8.44e-' +
      '4 0.01894,0.0016 0.04523,0.0012 0.07756,-0.0016 z m 65.458764,11' +
      '.455304 a 0.12960628,0.16416796 54.7 0 1 0.0169,8.45e-4 0.129606' +
      '28,0.16416796 54.7 0 0 -0.0262,0.0042 0.12960628,0.16416796 54.7' +
      ' 0 1 0.009,-0.0051 z m -74.073031,7.800002 h 8.49e-4 c -0.09568,' +
      '0.0968 -0.190764,0.19388 -0.284358,0.2928 0.09356,-0.0989 0.1879' +
      '07,-0.19603 0.283509,-0.2928 z m 61.487883,4.65857 c -0.184952,0' +
      '.14441 -0.37005,0.28873 -0.556046,0.4354 -0.0049,0.004 -0.0098,0' +
      '.009 -0.01633,0.0136 0.0049,-0.005 0.0098,-0.01 0.01633,-0.0144 ' +
      '0.18678,-0.14728 0.370311,-0.28955 0.556046,-0.43455 z" /></g></' +
      'svg>'
  end
  object tmrMenu: TTimer
    Interval = 250
    OnTimer = tmrMenuTimer
    Left = 568
    Top = 72
  end
  object pm1: TPopupMenu
    OnClose = pm1Close
    OnPopup = pm1Popup
    Left = 248
    Top = 24
    object About1: TMenuItem
      Caption = 'About...'
      OnClick = About1Click
    end
    object Settings1: TMenuItem
      Caption = '&Settings'
      OnClick = Settings1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Exit1: TMenuItem
      Caption = 'E&xit'
      OnClick = Exit1Click
    end
  end
  object tmrHideMenu: TTimer
    Enabled = False
    Interval = 25
    OnTimer = tmrHideMenuTimer
    Left = 592
    Top = 152
  end
  object tmrShowMenu: TTimer
    Enabled = False
    Interval = 25
    OnTimer = tmrShowMenuTimer
    Left = 592
    Top = 224
  end
  object ImageList1: TImageList
    Left = 304
    Top = 400
  end
  object pmCard: TPopupMenu
    OnClose = pmCardClose
    OnPopup = pmCardPopup
    Left = 256
    Top = 112
    object pmCardCloseSite: TMenuItem
      Caption = 'Close'
      Enabled = False
      OnClick = pmCardCloseSiteClick
    end
    object AlternatURL1: TMenuItem
      Caption = 'Alternat URL'
      Visible = False
      OnClick = AlternatURL1Click
    end
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = pm1
    Visible = True
    Left = 296
    Top = 304
  end
  object JvApplicationHotKey1: TJvApplicationHotKey
    HotKey = 49275
    OnHotKey = JvApplicationHotKey1HotKey
    OnHotKeyRegisterFailed = JvApplicationHotKey1HotKeyRegisterFailed
    Left = 184
    Top = 264
  end
  object JvAppEvents1: TJvAppEvents
    OnActivate = JvAppEvents1Activate
    Left = 440
    Top = 360
  end
  object MadExceptionHandler1: TMadExceptionHandler
    Left = 432
    Top = 248
  end
end
