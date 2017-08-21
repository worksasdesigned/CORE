//bugfixes V1.01
// Worldtime 24:60 min um 21:30 +2 und 5:30 offset
// kkal Tag war week
// added kcal to topline
// added Altitude
// fixed 12 am / pm midnight

// bugfixes version 1.02
//- cyrillic
//- french
//- altitude meter / feet

//bugfixes & version 1.03
//- heart rate graph

//V1.53
//added support for forerunner
//bugfix with ORANGE color

//V1.54 
// bugfix Ft in topline
// fixed battery numbers (centered)
// fixed messages & alarm count
// fixed a bug with gray background color



//plans
// fonts min dicker
//- graph language
//- heartbeat
// heartbeat graph
//- altitude graph
//-  icon hide when inactive ?



using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Activity as Act;
using Toybox.SensorHistory as Sensor;
// V1.03
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;

enum {
	NIGHT_END,
	NAUTICAL_DAWN,
	DAWN,
	BLUE_HOUR_AM,
	SUNRISE,
	SUNRISE_END,
	GOLDEN_HOUR_AM,
	NOON,
	GOLDEN_HOUR_PM,
	SUNSET_START,
	SUNSET,
	BLUE_HOUR_PM,
	DUSK,
	NAUTICAL_DUSK,
	NIGHT,
	NUM_RESULTS
}
enum
{
    LAT,
    LON
}
// Ende V1.03

var fontbig;
var fontcorebig;
var fontnorm;
var fonthalf;
var fontmin;
var fontminbold;
var fonttiny;
var fontxtiny;
var fontmintxt;

var device_settings;
var fast_updates = true;

var watch;
var height;
var width;

var dateStrings;
var dateStringsshort;

var setWF;
var foreground, background;
var fgc, bgc; // foreground and background color code

// V1.03 test
	var heartNow;
	var heartMin;
	var heartMax;
// ende V1.03

var yFRoffdown = 0;  //V1.13 für anpassung an Forerunner 735, 230 235 down line anpassen
var barreduce  = 0; // V1.13 für Forerunner 920 square watch reduce of steps bar



class FenixCoreView extends Ui.WatchFace {
  			
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
	    
        device_settings = Sys.getDeviceSettings(); 
        dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
        dateStringsshort = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT);
        
        //Read Fonts
        fontbig      =  Ui.loadResource(Rez.Fonts.id_font_big);
        fontcorebig  = Ui.loadResource(Rez.Fonts.id_font_corebig);
        fontnorm     = Ui.loadResource(Rez.Fonts.id_font_norm);
        fonthalf     = Ui.loadResource(Rez.Fonts.id_font_half);
        fontmin      = Ui.loadResource(Rez.Fonts.id_font_min);
        fontminbold  = Ui.loadResource(Rez.Fonts.id_font_minbold);
          
        fonttiny  = Ui.loadResource(Rez.Fonts.id_font_tiny);
        fontxtiny = Ui.loadResource(Rez.Fonts.id_font_xtiny);
        fontmintxt = Ui.loadResource(Rez.Fonts.id_font_min_txt);
        
        // check which watch i am dealing with...
       // Sys.println("height =" + dc.getHeight() + " width =" + dc.getWidth() + " screentyp="+ device_settings.screenShape);
        if (device_settings.screenShape == 1){ // round watch
         //218x218 Fenix 3 series, 5s, Chronos
         //240x240 Fenix 5,5x, Forerunner 935,
          if (width == 240) {watch = 2;}
          else {watch = 1;}  
        } else if (device_settings.screenShape == 2){
        //180x215 Forerunner 735, 230, 235
         watch = 3;
         yFRoffdown = -14;
        } else if (device_settings.screenShape == 3){
        // 148x205 VivoActive HR, square whatch
         watch = 4;
         yFRoffdown = -3;
         barreduce = 4;
         
        } 
         //Sys.print(device_settings.screenShape );
         //Sys.print(dc.getHeight());
         //Sys.print(dc.getWidth());
         
			         
			// ############################## read settings #####################################################
			// watchfont
			//if ( App.getApp().getProperty("watchfont") == 0 ) {set_watchfont = fontbig; } else {set_watchfont = fontcorebig;}

			
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
      // black is beautiful CLEAR the screen.
     // dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
     // dc.clear();
     var fontminvari = fontmin;
     var isbold = App.getApp().getProperty("bold");
       if (isbold) {fontminvari = fontminbold;}
       
      	foreground = App.getApp().getProperty("foreground");
	    background = App.getApp().getProperty("background");
	    //Sys.println(foreground + "x " + background);
	    
	    if       (foreground == 0){  fgc = Gfx.COLOR_WHITE;
	    }else if (foreground == 1){  fgc = Gfx.COLOR_BLACK;
	    }else if (foreground == 2){  fgc = Gfx.COLOR_WHITE;
	    }else if (foreground == 3){  fgc = Gfx.COLOR_LT_GRAY;
	    }else if (foreground == 4){  fgc = Gfx.COLOR_DK_GRAY;
	    }else if (foreground == 5){  fgc = Gfx.COLOR_RED;
	    }else if (foreground == 6){  fgc = Gfx.COLOR_DK_RED;
	    }else if (foreground == 7){  fgc = Gfx.COLOR_BLUE;
	    }else if (foreground == 8){  fgc = Gfx.COLOR_DK_BLUE;
	    }else if (foreground == 9){  fgc = Gfx.COLOR_PINK;
	    }else if (foreground == 10){ fgc = Gfx.COLOR_GREEN;
	    }else if (foreground == 11){ fgc = Gfx.COLOR_DK_GREEN;
	    }
	    if       (background == 0){  bgc = Gfx.COLOR_BLACK;
	    }else if (background == 1){  bgc = Gfx.COLOR_BLACK;
	    }else if (background == 2){  bgc = Gfx.COLOR_WHITE;
	    }else if (background == 3){  bgc = Gfx.COLOR_LT_GRAY;
	    }else if (background == 4){  bgc = Gfx.COLOR_DK_GRAY;
	    }else if (background == 5){  bgc = Gfx.COLOR_RED;
	    }else if (background == 6){  bgc = Gfx.COLOR_DK_RED;
	    }else if (background == 7){  bgc = Gfx.COLOR_BLUE;
	    }else if (background == 8){  bgc = Gfx.COLOR_DK_BLUE;
	    }else if (background == 9){  bgc = Gfx.COLOR_PINK;
	    }else if (background == 10){ bgc = Gfx.COLOR_GREEN;
	    }else if (background == 11){ bgc = Gfx.COLOR_DK_GREEN;
	    }
        //Sys.println ( background + " "+ bgc" f: " + foreground + " " + fgc);
        //dc.setColor(fgc, bgc);
        //dc.fillRectangle(100, 100, 100, 100);
       dc.setColor(bgc, bgc);
       dc.clear();
      
      //
      var secindicator = App.getApp().getProperty("secindicator");
        

        // Update the view
        // Uhrzeit & datum auselsen    
        var clockTime = Sys.getClockTime();
        var hour, min, time, day, sec;
        day = dateStrings.day;
        min  = clockTime.min;
        hour = clockTime.hour;
        sec = 0;
  // Sekundenzeiger zeichnen
        if (fast_updates){
          if         (secindicator == 0) {  drawSec(dc,1,fgc,bgc,watch); // standard 5 dots
          }else if   (secindicator == 1) {
          }else if   (secindicator == 2) {  drawSec(dc,1,fgc,bgc,watch);  // 5 dots stylish
          }else if   (secindicator == 3) {  drawSec(dc,2,fgc,bgc,watch);  // 4 bars CORE
          }else if   (secindicator == 4) {  drawSec(dc,3,fgc,bgc,watch);  // simple 1 bar
          }
        }
        
        //       dc,  x             ,y          ,yoffset,ampm offset,secoffset, mainfont, secfont 
        var watchmainfont = App.getApp().getProperty("watchfont");
        //Sys.println(watch);
        if (watch == 1 || watch == 2){	        
			        if (watchmainfont  == 1) {
			            drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,45,0,11, fontbig, fonthalf,fgc);     
			        }else if (watchmainfont == 2){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,45,-5,20, fontcorebig, fonthalf,fgc);
			        }else if (watchmainfont == 3){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-17,10,0,2, fontnorm, fonthalf,fgc);
			        }else if (watchmainfont == 4){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,17,10,10, fonthalf, fontmintxt,fgc );
			        }else if (watchmainfont == 5){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,10,10,10, fontmintxt, fontmintxt,fgc);
			        }
		}else if (watch == 3){ // Forerunner mit 205 x 180
			        if (watchmainfont == 4){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,23,16,16, fonthalf, fontmintxt,fgc );
			        }else if (watchmainfont == 3){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-17,10,0,2, fontnorm, fonthalf,fgc);
			        }else if (watchmainfont == 2){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-17,10,0,-11, fontnorm, fontmintxt,fgc);       
			        }else if (watchmainfont == 5){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2,10,10,10, fontmintxt, fontmintxt,fgc);
			        }else{
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-17,10,-0,2, fontnorm, fonthalf,fgc);
			        }
		}else if (watch == 4){ // Forerunner mit 148x205 square
			        if (watchmainfont == 4){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-2,23,16,16, fonthalf, fontmintxt,fgc );
			        }else if (watchmainfont == 3){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-2,10,0,2, fontnorm, fonthalf,fgc);
			        }else if (watchmainfont == 2){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-2,10,0,-11, fontnorm, fontmintxt,fgc);       
			        }else if (watchmainfont == 5){
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-2,10,10,10, fontmintxt, fontmintxt,fgc);
			        }else{
			               drawTime(dc,dc.getWidth()/2, dc.getHeight()/2-2,10,0,2, fontnorm, fonthalf,fgc);
			        }
		}	        
        var language = App.getApp().getProperty("language");
        //Sys.println(language);
        
        //  ######################################################################################################     
        //  ##############################  Draw TOPLINE ##########################################################
        //  ######################################################################################################
        var topline = App.getApp().getProperty("topline");
        var toplinecolor = App.getApp().getProperty("toplinecolor");
        //Sys.println("top: " + topline + " " + toplinemode);
        
        if        ((topline == 0) || (topline == 1) ){
        } else if (topline == 2 ){drawbatt(dc,dc.getWidth()/2,8,1,toplinecolor,fontminvari,fgc,bgc); // bat symbol top   
        } else if (topline == 3 ){drawbatt(dc,dc.getWidth()/2,6,3,toplinecolor,fontminvari,fgc,bgc); // bat number top  
        } else if (topline == 4 ){ drawIcons(dc,dc.getWidth()/2,5,true,false,false,toplinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
        } else if (topline == 5 ){ drawIcons(dc,dc.getWidth()/2,5,false,true,false,toplinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color         
        } else if (topline == 6 ){ drawIcons(dc,dc.getWidth()/2,5,false,false,true,toplinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
        } else if (topline == 7 ){ drawIcons(dc,dc.getWidth()/2,5,true,true,false,toplinecolor,fgc,bgc); // icons TOP  BT,  alarm, message color
        } else if (topline == 8 ){ drawIcons(dc,dc.getWidth()/2,5,true,true,true,toplinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
        } else if (topline == 9){ drawSteps(dc,dc.getWidth()/2,8, fontminvari,false,toplinecolor,fgc,bgc); // steps   dc,x,y,logo,color
        } else if (topline == 10 ){ drawDate(dc,dc.getWidth()/2,8,fontminvari,2,language,fgc,bgc);
        } else if (topline == 11 ){ drawMoveBar(dc,dc.getWidth()/2,8,fontxtiny,toplinecolor,fgc,bgc);  // MoveBar
    	} else if (topline == 12) { drawDistance(dc,dc.getWidth()/2,8,fontminvari,1,true,true,fgc,bgc);  // km  x,y,font,unit, recal(shorten), km_txt 
        } else if (topline == 13) { drawDistance(dc,dc.getWidth()/2,8,fontminvari,2,true,false,fgc,bgc);  // m 
     	} else if (topline == 14) { drawDistance(dc,dc.getWidth()/2,8,fontminvari,3,true,true,fgc,bgc);  // mi 
        } else if (topline == 15) { drawDistance(dc,dc.getWidth()/2,8,fontminvari,4,true,false,fgc,bgc);  // ft
		} else if (topline == 16) { drawKkal(dc,dc.getWidth()/2,8, fontminvari,false,false,fgc,bgc);  //Kalorien Tag //dc,x,y,txtfont,logo,week
        } else if (topline == 17) { drawKkal(dc,dc.getWidth()/2,8, fontminvari,false,true,fgc,bgc); // Kalorien Woche
        } else if (topline == 18) { drawAltitude(dc,dc.getWidth()/2,8, fontminvari, 0,fgc,bgc); // altitude m
        } else if (topline == 19) { drawAltitude(dc,dc.getWidth()/2,8, fontminvari, 1,fgc,bgc); // altitude ft
        } else if (topline == 20) { drawSunriseSunset(dc,dc.getWidth()/2,10, fontminvari,false);  //sunset /sunrise

        
        }// ende topline
       
        //  ######################################################################################################     
        //  ##############################  Draw upper line ##########################################################
        //  ######################################################################################################
        var upline = App.getApp().getProperty("upline");
        var uplinecolor = App.getApp().getProperty("uplinecolor");

        if        (upline == 0 ) {drawDate(dc,dc.getWidth()/2,36,fontmintxt,1,language,fgc,bgc); // standard
        } else if (upline == 1 ) {     // nothing
        } else if (upline == 2 ){  drawStepsGraph(dc,dc.getWidth()/2,30,device_settings,8,1,uplinecolor,fgc,bgc);  // graph top line
        } else if (upline == 3 ){  drawStepsGraph(dc,dc.getWidth()/2,42,device_settings,4,2,uplinecolor,fgc,bgc);  // graph top dot
        } else if (upline == 4 ){  drawDate(dc,dc.getWidth()/2,36,fontmintxt,1,language,fgc,bgc); // Date Fri 13.12.         
        } else if (upline == 5 ){  drawDate(dc,dc.getWidth()/2,36,fontmintxt,0,language,fgc,bgc); // Date 13.12.
        } else if (upline == 6 ){  drawSteps(dc,dc.getWidth()/2,36, fontmintxt,1, uplinecolor,fgc,bgc); // font, logo?, color // steps  
        } else if (upline == 7 ){  drawStepsGoal(dc,dc.getWidth()/2,36,0,fontmintxt,uplinecolor,fgc,bgc);
        } else if (upline == 8 ){  drawStepsWeekGoal(dc,dc.getWidth()/2,36,fontmintxt,false,uplinecolor,fgc,bgc); // STepsWeek 
        } else if (upline == 9 ){  drawStepsWeekGoal(dc,dc.getWidth()/2,36, fontmintxt,true,uplinecolor,fgc,bgc); // stepsweek + goal
        } else if (upline == 10 ){ drawWorldTime(dc,dc.getWidth()/2,36,fontmintxt,fgc,bgc); // weltzeit
        } else if (upline == 11 ){ drawKkal(dc,dc.getWidth()/2,36, fontmintxt,true,false,fgc,bgc);  //Kalorien Tag //dc,x,y,txtfont,logo,week
        } else if (upline == 12 ){ drawKkal(dc,dc.getWidth()/2,36, fontmintxt,true,true,fgc,bgc); // Kalorien Woche
        } else if (upline == 13) { drawDistance(dc,dc.getWidth()/2,36,fontmintxt,1,false,true,fgc,bgc);  // km  x,y,font,unit, recal(shorten), km_txt 
        } else if (upline == 14) { drawDistance(dc,dc.getWidth()/2,36,fontmintxt,2,false,true,fgc,bgc);  // m 
        } else if (upline == 15) { drawDistance(dc,dc.getWidth()/2,36,fontmintxt,3,false,true,fgc,bgc);  // mi 
        } else if (upline == 16) { drawDistance(dc,dc.getWidth()/2,36,fontmintxt,4,false,true,fgc,bgc);  // ft 
        } else if (upline == 17) {drawAltitude(dc,dc.getWidth()/2,36,fontmintxt, 0,fgc,bgc);  // Altitude m
        } else if (upline == 18) {drawAltitude(dc,dc.getWidth()/2,36,fontmintxt, 1,fgc,bgc); // Altitude ft
        } else if (upline == 19) {drawHRgraph(dc,dc.getWidth()/2,65,3, 144, 43, fgc, bgc,uplinecolor ); // HR dot x,y,detail(3,2,1),width,height,foregourndcolor
        } else if (upline == 20) {drawHRgraph(dc,dc.getWidth()/2,65,2, 144 ,43 , fgc,bgc,uplinecolor ); // HR dot x,y,detail(3,2,1),width,height, ,foregourndcolor
        } else if (upline == 21) {drawHRgraph(dc,dc.getWidth()/2,65,1, 144,43 ,fgc, bgc,uplinecolor ); // HR dot x,y,detail(3,2,1), width,height,foregourndcolor
        } else if (upline == 22) {drawSunriseSunset(dc,dc.getWidth()/2,36, fontmintxt,true); // sunset / sunrise, showpm
        
       // } else if (upline == 14){ 
        }// ende uppline

        //  ######################################################################################################     
        //  ##############################  Draw low line ##########################################################
        //  ######################################################################################################
        var lowline = App.getApp().getProperty("lowline");
        var lowlinecolor = App.getApp().getProperty("lowlinecolor");

        if        (lowline == 0 ) {drawStepsGraph(dc,dc.getWidth()/2,dc.getHeight()/2+52,device_settings,8,2,lowlinecolor,fgc,bgc); // standard
        } else if (lowline == 1 ) {     // nothing
        } else if (lowline == 2 ){ drawStepsGraph(dc,dc.getWidth()/2,dc.getHeight()/2+38+yFRoffdown,device_settings,15-barreduce,1,lowlinecolor,fgc,bgc);  // graph top line
        } else if (lowline == 3 ){ drawStepsGraph(dc,dc.getWidth()/2,dc.getHeight()/2+52+yFRoffdown,device_settings,8-(barreduce/2),2,lowlinecolor,fgc,bgc); // graph top dot
        } else if (lowline == 4 ){ drawDate(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,1,language,fgc,bgc); // Date Fri 13.12.         
        } else if (lowline == 5 ){ drawDate(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,0,language,fgc,bgc); // Date 13.12.
        } else if (lowline == 6 ){ drawSteps(dc,dc.getWidth()/2,dc.getHeight()/2+35, fontmintxt,1, lowlinecolor,fgc,bgc); // font, logo?, color // steps  
        } else if (lowline == 7 ){  drawStepsGoal(dc,dc.getWidth()/2,dc.getHeight()/2+35,0,fontmintxt,lowlinecolor,fgc,bgc);
        } else if (lowline == 8 ){ drawStepsWeekGoal(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,false,lowlinecolor,fgc,bgc); // stepsWeek  
        } else if (lowline == 9 ){ drawStepsWeekGoal(dc,dc.getWidth()/2,dc.getHeight()/2+35, fontmintxt,true,lowlinecolor,fgc,bgc);
        } else if (lowline == 10 ){ drawWorldTime(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,fgc,bgc); // worldtime low
        } else if (lowline == 11 ){ drawKkal(dc,dc.getWidth()/2,dc.getHeight()/2+35, fontmintxt,false,false,fgc,bgc);  //Kalorien Tag //dc,x,y,txtfont,logo,week
        } else if (lowline == 12 ){ drawKkal(dc,dc.getWidth()/2,dc.getHeight()/2+35, fontmintxt,true,true,fgc,bgc); // Kalorien Woche
        } else if (lowline == 13) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,1,false,true,fgc,bgc);  // km  x,y,font,unit, recal(shorten), km_txt 
        } else if (lowline == 14) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,2,false,true,fgc,bgc);  // m 
        } else if (lowline == 15) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,3,false,true,fgc,bgc);  // mi 
        } else if (lowline == 16) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt,4,false,true,fgc,bgc);  // ft 
        } else if (lowline == 17) {drawAltitude(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt, 0,fgc,bgc);  // Altitude m
        } else if (lowline == 18) {drawAltitude(dc,dc.getWidth()/2,dc.getHeight()/2+35,fontmintxt, 1,fgc,bgc); // Altitude ft
        } else if (lowline == 19) {drawHRgraph(dc,dc.getWidth()/2,dc.getHeight()/2 + 80,3, 155, 55, fgc, bgc,lowlinecolor ); // HR dot x,y,detail(3,2,1),fenix5,width,height,foregourndcolor
        } else if (lowline == 20) {drawHRgraph(dc,dc.getWidth()/2,dc.getHeight()/2 + 80,2,155 ,55 , fgc , bgc,lowlinecolor); // HR dot x,y,detail(3,2,1),fenix,5width,height, ,foregourndcolor
        } else if (lowline == 21) {drawHRgraph(dc,dc.getWidth()/2,dc.getHeight()/2 + 80,1, 155,55 ,fgc, bgc,lowlinecolor ); // HR dot x,y,detail(3,2,1),fenix5, width,height,foregourndcolor
        } else if (lowline == 22) {drawSunriseSunset(dc,dc.getWidth()/2,dc.getHeight()/2+35, fontmintxt,true); // sunset / sunrise /showPM
        }// ende lowerline       


        //  ######################################################################################################     
        //  ##############################  Draw last line ##########################################################
        //  ######################################################################################################
        var lastlineactive = true;
        
        if (App.getApp().getProperty("lastlineactive")) {
          if (fast_updates){ lastlineactive = false;}
        }
        else {lastlineactive = false;}
        
        if (!lastlineactive){   // bei false wird es angezeigt
		        var lastline = App.getApp().getProperty("lastline");
		        var lastlinecolor = App.getApp().getProperty("lastlinecolor");
		    if(watch != 4){ // geht nicht bei square watch (Forerunner XT920)
		        if        (lastline == 0 ){ drawbatt(dc,dc.getWidth()/2,dc.getHeight()-20,1,false,fontminvari,fgc,bgc); // bat low 
		        } else if (lastline == 1 ){ 
		        } else if (lastline == 2 ){ drawbatt(dc,dc.getWidth()/2,dc.getHeight()-20,1,lastlinecolor,fontminvari,fgc,bgc);
		        } else if (lastline == 3 ){ drawbatt(dc,dc.getWidth()/2,dc.getHeight()-20,3,lastlinecolor,fontminvari,fgc,bgc);
		        } else if (lastline == 4 ){ drawIcons(dc,dc.getWidth()/2,dc.getHeight()-20,true,false,false,lastlinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
		        } else if (lastline == 5 ){ drawIcons(dc,dc.getWidth()/2,dc.getHeight()-20,false,true,false,lastlinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color         
		        } else if (lastline == 6 ){ drawIcons(dc,dc.getWidth()/2,dc.getHeight()-20,false,false,true,lastlinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
		        } else if (lastline == 7 ){ drawIcons(dc,dc.getWidth()/2,dc.getHeight()-20,true,true,false,lastlinecolor,fgc,bgc); // icons TOP  BT,  alarm, message color
		        } else if (lastline == 8 ){ drawIcons(dc,dc.getWidth()/2,dc.getHeight()-20,true,true,true,lastlinecolor,fgc,bgc); // icons TOP  BT,  alarm, message; color
		        } else if (lastline == 9 ){ drawSteps(dc,dc.getWidth()/2,dc.getHeight()-20, fontminvari,false,lastlinecolor,fgc,bgc); // steps   dc,x,y,logo,color
		        } else if (lastline == 10 ){ drawDate(dc,dc.getWidth()/2,dc.getHeight()-20,fontminvari,2,language,fgc,bgc);
		        } else if (lastline == 11 ){ drawMoveBar(dc,dc.getWidth()/2,dc.getHeight()-20,fontxtiny,lastlinecolor,fgc,bgc);  // MoveBar
				} else if (lastline == 12) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()-20,fontminvari,1,true,true,fgc,bgc);  // km  x,y,font,unit, recal(shorten), km_txt 
    		    } else if (lastline == 13) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()-20,fontminvari,2,true,false,fgc,bgc);  // m 
     			} else if (lastline == 14) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()-20,fontminvari,3,true,true,fgc,bgc);  // mi 
        		} else if (lastline == 15) { drawDistance(dc,dc.getWidth()/2,dc.getHeight()-20,fontminvari,4,true,false,fgc,bgc);  // ft
        		} else if (lastline == 16) { drawSunriseSunset(dc,dc.getWidth()/2,dc.getHeight()-28, fontminvari,false);  //sunset /sunrise /showpm
		        }// ende lastline
		    } // ende !watch 4
		    else{ // batterie anzeigen oder nichts für Forerunner (watch 4)
		       if         (lastline == 0 ){ drawbatt(dc,dc.getWidth()-30,8,1,false,fontminvari,fgc,bgc); // bat low 
		        } else if (lastline == 1 ){ 
		        } else if (lastline == 2 ){ drawbatt(dc,dc.getWidth()-30,8,1,lastlinecolor,fontminvari,fgc,bgc);
		        } else if (lastline == 3 ){ drawbatt(dc,dc.getWidth()-30,8,3,lastlinecolor,fontminvari,fgc,bgc);
		        }else{
		               drawbatt(dc,dc.getWidth()-30,8,1,false,fontminvari,fgc,bgc);
		        } 
		    }// Ende Sonderlocke für Square watch (batterie oben rechts)
          } // lastline active
        
    }// ENDE On Update

function drawTime(dc,x,y,yoffset,ampmoffset,secoffset,textfont,secfont,fgc){
        dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
        
        var clockTime = Sys.getClockTime();
       // var dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
        var sec = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT).sec;
        
        var hour, min, time, day;
        var time_string;
        day = dateStrings.day;
        min  = clockTime.min;
        hour = clockTime.hour;
        if (sec.toNumber()<10) {
         sec = "0" + sec.toString();
        }
        
        var ampm = " ";
        if( !device_settings.is24Hour ) { // AM/PM anzeige
           if (hour >= 12) {
                hour = hour - 12;
                ampm = 1; // pm
			    }
		    else{  
		        ampm = 2;  //am
			}
            if (hour == 0) {hour = 12;}    
            hour  = Lang.format("$1$",[hour.format("%2d")]);
            min   = Lang.format("$1$",[min.format("%02d")]); 
        }
        else {            
            hour  = Lang.format("$1$",[hour.format("%02d")]);
            min   = Lang.format("$1$",[min.format("%02d")]);
        }
      
        // #########################draw TIME ####################################
        var einer = 0; 
        if (hour.toNumber == 1) {einer = 10;}      
        dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
        time_string = hour.toString() + ":" + min.toString();
        dc.drawText(x,y - yoffset, textfont, time_string, Gfx.TEXT_JUSTIFY_CENTER);
        if (ampm == 1){ // PM
           dc.drawText(x - dc.getTextWidthInPixels(time_string, textfont)/2-3, y - ampmoffset , fontmintxt , "pm" , Gfx.TEXT_JUSTIFY_RIGHT);
        }
        else if (ampm == 2){ //AM
		   dc.drawText(x - dc.getTextWidthInPixels(time_string, textfont)/2-3, y - ampmoffset, fontmintxt , "am" , Gfx.TEXT_JUSTIFY_RIGHT );
        }
        //sec
        if (fast_updates){
          dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
          dc.drawText(x + dc.getTextWidthInPixels(time_string, textfont)/2+3,y -secoffset,secfont,sec,Gfx.TEXT_JUSTIFY_LEFT);
        }
        
        
}

// ######################################################################V1.03##############################################

function drawSunriseSunset(dc,x,y,txtfont,yespm)
    {
		var sc = new SunCalc();
		var lat;
		var lon;
		var timeStringRise = "--:--";
		var timeStringSet = "--:--";
        var hour, min, ampm;
		
		var loc = Activity.getActivityInfo().currentLocation;
		if (loc == null)
		{
			lat = App.getApp().getProperty(LAT);
			lon = App.getApp().getProperty(LON);
		} 
		else
		{
			lat = loc.toDegrees()[0] * Math.PI / 180.0;
			App.getApp().setProperty(LAT, lat);
			lon = loc.toDegrees()[1] * Math.PI / 180.0;
			App.getApp().setProperty(LON, lon);
		}
       //Sys.println("rausnehmen!!");
		//lat = 48.77710 * Math.PI / 180.0;
		//lon = 9.18076 * Math.PI / 180.0;

		if(lat != null && lon != null)
		{
			
			var now = new Time.Moment(Time.now().value());			
			var sunrise_moment = sc.calculate(now, lat.toDouble(), lon.toDouble(), SUNRISE);
			var sunset_moment = sc.calculate(now, lat.toDouble(), lon.toDouble(), SUNSET);

			var timeInfoSunrise = Calendar.info(sunrise_moment, Time.FORMAT_SHORT);
			var timeInfoSunset = Calendar.info(sunset_moment, Time.FORMAT_SHORT);

			 //timeStringRise = Lang.format("$1$:$2$", [timeInfoSunrise.hour, timeInfoSunrise.min.format("%02d")]);
             //timeStringSet = Lang.format("$1$:$2$", [timeInfoSunset.hour, timeInfoSunset.min.format("%02d")]);
		     // sunrise
		     var ampm = " ";
		     if( !device_settings.is24Hour ) { // AM/PM anzeige
		           if (timeInfoSunrise.hour >= 12) {
		                timeInfoSunrise.hour = timeInfoSunrise.hour - 12;
		                ampm = 1; // pm
					    }
				    else{  
				        ampm = 2;  //am
					}
		            if (timeInfoSunrise.hour == 0) {timeInfoSunrise.hour = 12;}    
		            timeStringRise  = Lang.format("$1$:$2$",[timeInfoSunrise.hour, timeInfoSunrise.min.format("%02d")]) ;
		        }
		        else {            
		          timeStringRise  = Lang.format("$1$:$2$",[timeInfoSunrise.hour, timeInfoSunrise.min.format("%02d")]) ;
		        } // ende AMPM
		        if(ampm == 1 && yespm){timeStringRise = timeStringRise + "pm";}
		        if(ampm == 2 && yespm){timeStringRise = timeStringRise + "am";}
		     
		     // jetzt noch Sunset
		     ampm = " ";
		     if( !device_settings.is24Hour ) { // AM/PM anzeige
		           if (timeInfoSunset.hour >= 12) {
		                timeInfoSunset.hour = timeInfoSunset.hour - 12;
		                ampm = 1; // pm
					    }
				    else{  
				        ampm = 2;  //am
					}
		            if (timeInfoSunset.hour == 0) {timeInfoSunset.hour = 12;}    
		            timeStringSet  = Lang.format("$1$:$2$",[timeInfoSunset.hour, timeInfoSunset.min.format("%02d")]) ;
		        }
		        else {            
		          timeStringSet  = Lang.format("$1$:$2$",[timeInfoSunset.hour, timeInfoSunset.min.format("%02d")]) ;
		        } // ende AMPM
		        if(ampm == 1 && yespm){timeStringSet = timeStringSet + "pm";}
		        if(ampm == 2 && yespm){timeStringSet = timeStringSet + "am";}		        
		        
		}// ende if lat / long
		var space = " ";
		if (!yespm) {space ="";}
		var sun_totalstring = "Z"+timeStringRise + space +"z"+ timeStringSet;
		dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x,y, txtfont, sun_totalstring, Gfx.TEXT_JUSTIFY_CENTER);
	} 



function drawHRgraph(dc,x,y,detail, width,height, fgc,bgc,color) {
      //Sys.println(Sys.getDeviceSettings().monkeyVersion[0]);
	if (Sys.getDeviceSettings().monkeyVersion[0] >= 2){
		var sample = Sensor.getHeartRateHistory( {:order=>Sensor.ORDER_NEWEST_FIRST} );
		if (sample != null)
		{		    	
			var heart = sample.next();
			if (heart.data != null)
				{ heartNow = heart.data; }

			if ( 1 == 1)
			{			
		    	if (sample.getMin() != null)
		    		{ heartMin = sample.getMin(); }
		    	
		    	if (sample.getMax() != null)
		    		{ heartMax = sample.getMax(); }
	
				var maxSecs = 14355; //14400 = 4 hours
				var totHeight = height;
				var totWidth = width;
				var binPixels = detail;
	
				var totBins = Math.ceil(totWidth / binPixels).toNumber();
				//Sys.println("Total Bars" + totBins); // awi
				totBins = Math.ceil(totWidth / (binPixels + 1)); // awi
				//Sys.println("Total Bars mit Spalte" + totBins); //awi
				
				var binWidthSecs = Math.floor(binPixels * maxSecs / totWidth).toNumber();	
	            
				var heartSecs;
				var heartValue = 0;
				var secsBin = 0;
				var lastHeartSecs = sample.getNewestSampleTime().value();
				var heartBinMax;
				var heartBinMin;
	 
				var finished = false;
				
				// über Spalten loopen
				for (var i = 0; i < totBins; ++i) {
	
					heartBinMax = 0;
					heartBinMin = 0;
				
					if (!finished)
					{
						//deal with carryover values
						if (secsBin > 0 && heartValue != null)
						{
							heartBinMax = heartValue;
							heartBinMin = heartValue;
						}
	
						//deal with new values in this bin
						while (!finished && secsBin < binWidthSecs)
						{
							heart = sample.next();
							if (heart != null)
							{
								heartValue = heart.data;
								if (heartValue != null)
								{
									if (heartBinMax == 0)
									{
										heartBinMax = heartValue;
										heartBinMin = heartValue;
									}
									else
									{
										if (heartValue > heartBinMax)
											{ heartBinMax = heartValue; }
										
										if (heartValue < heartBinMin)
											{ heartBinMin = heartValue; }
									}
								}
								
								// keep track of time in this bin
								heartSecs = lastHeartSecs - heart.when.value();
								lastHeartSecs = heart.when.value();
								secsBin += heartSecs;
	
							//	Sys.println(i + ":   " + heartValue + " " + heartSecs + " " + secsBin + " " + heartBinMin + " " + heartBinMax);
							}
							else
							{
								finished = true;
							}
							
						} // while secsBin < binWidthSecs
	
						if (secsBin >= binWidthSecs)
							{ secsBin -= binWidthSecs; }
	
						// only plot bar if we have valid values
						if (heartBinMax > 0 && heartBinMax >= heartBinMin)
						{
							var heartBinMid = (heartBinMax+heartBinMin)/2;
							var height = (heartBinMid-heartMin*0.9) / (heartMax-heartMin*0.9) * totHeight;
							//var xVal = (dc.getWidth()-totWidth)/2 + totWidth - i*binPixels -2;
							var xVal = (dc.getWidth()-totWidth)/2 + totWidth - i*(binPixels+1);
							var yVal = dc.getHeight()/2+28 + totHeight - height;
						    yVal = yVal.toNumber();
						   // Sys.println("yVal" + yVal);
							dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
							var yValstrich = y; // awi
							var xValstrich = xVal; // awi
							//xValstrich = xValstrich ;  //awi
							//Sys.println("xpos" + xValstrich);
							for (var k = 0; k < height; k++){
							    yValstrich = yValstrich - binPixels - 1;
						     	dc.fillRectangle(xValstrich, yValstrich , binPixels, binPixels);
							    k = k + binPixels;
							}
							//dc.fillRectangle(xVal, yVal, binPixels, height);
							
//							Sys.println(i + ": " + binWidthSecs + " " + secsBin + " " + heartBinMin + " " + heartBinMax);
						}				
						
					} // if !finished
					
				} // loop over all bins

			   dc.drawText(x-width/2 ,y,fontxtiny , "-4h", Gfx.TEXT_JUSTIFY_LEFT);
			   dc.drawText(x-width/4,y,fontxtiny , "-3h", Gfx.TEXT_JUSTIFY_LEFT);
			   dc.drawText(x+3,y,fontxtiny , "-2h", Gfx.TEXT_JUSTIFY_LEFT);
			   dc.drawText(x+3+width/4,y,fontxtiny , "-1h", Gfx.TEXT_JUSTIFY_LEFT);
			   dc.drawText(x+3+width/2,y-3,fontxtiny , "^", Gfx.TEXT_JUSTIFY_RIGHT);
			   dc.drawText(x+3+width/2,y+3,fontxtiny , "now", Gfx.TEXT_JUSTIFY_RIGHT);
			    
			   dc.drawText(x-width/2,y-height/5*4,fontxtiny , heartMax, Gfx.TEXT_JUSTIFY_RIGHT);
			   dc.drawText(x-width/2,y-height/5,fontxtiny , heartMin, Gfx.TEXT_JUSTIFY_RIGHT);
			   if (color){
			     if(bgc != Gfx.COLOR_DK_RED ){
			           dc.setColor( Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
			     }else{dc.setColor( Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);}
			    }
			   dc.drawText(x-76,y-height/2-5,fontmintxt , "@", Gfx.TEXT_JUSTIFY_RIGHT);
			    
				
			} // if sample != null

		}
    }// ende fenix 5 check
    else{
     dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_TRANSPARENT); 
     dc.drawText(x,y-35, Gfx.FONT_SYSTEM_XTINY, "Sorry Heartrategraph", Gfx.TEXT_JUSTIFY_CENTER);
     dc.drawText(x,y-20, Gfx.FONT_SYSTEM_XTINY, "only works on Fenix5", Gfx.TEXT_JUSTIFY_CENTER);
    }
}


//  ENDE #################################################################V1.03 ############################################



function drawAltitude(dc,x,y,txtfont,unit,fgc,bgc){
	var altitude = Act.getActivityInfo().altitude.toFloat();
	var altitude_txt= "";
 	dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
    if (altitude != null) {
        if (unit == 1) {altitude = altitude * 3.28084;} 
        altitude = altitude.format("%1.0f");
        altitude_txt = altitude.toString();    
    } else {
        altitude_txt = "9999";
    }
    
    if (unit == 0) {
      altitude_txt = altitude_txt + " " + "m";
    }else if (unit == 1) {
      altitude_txt = altitude_txt + " " + "Ft";
    }
    dc.drawText(x ,y ,txtfont,altitude_txt,Gfx.TEXT_JUSTIFY_CENTER);
}




function drawDistance(dc,x,y,txtfont,unit,recalc,show_unit_txt,fgc,bgc){
        var activity = ActivityMonitor.getInfo();
        var m       = activity.distance.toFloat() / 100 ; // distance is saved as cm --> / 100 / 1000 --> km
        var m_txt = "";
        
        //Sys.println(unit);
        // umrechnen wenns zu lange ist und TOP position
        if ((recalc) && (unit == 4) && (m * 3.28 > 9999)) { unit = 3;} // auf meilen umbauen
        if ((recalc) && (unit == 2) && (m > 9999)) { unit = 1;} // auf meter umbauen 
        if ( unit == 3 ){ 
        //if (device_settings.distanceUnits){//is watch set to IMPERIAL-Units?  km--> miles
            m = m.toFloat() / 1000 * 0.62137;
            if (show_unit_txt) { m_txt = " mi";}
         }
         else if (unit == 2){
           if (show_unit_txt) { m_txt = " m"; }
         }
         else if (unit == 1){
           m = m.toFloat() / 1000;
           if (show_unit_txt) { m_txt = " km"; }
         } else if (unit == 4){
           m = m.toFloat() * 3.28084;
           if (show_unit_txt) { m_txt = " ft"; }
         }
         
         m = m.format("%2.1f");     // formatting km/mi to 2numbers + 1 digit
        dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x ,y ,txtfont,m.toString() + m_txt,Gfx.TEXT_JUSTIFY_CENTER);
         
}

function drawStepsWeekGoal(dc,x,y,txtfont, goal, color,fgc,bgc){
         var activity = ActivityMonitor.getInfo();
         var acthis = ActivityMonitor.getHistory();
         var stepsGoal = activity.stepGoal;
         var stepsLive = activity.steps;
         var totalSteps = 0;
         var totalGoal = 0;
         var steps_print;
         var hiscorrect = 0; // 7 days history + today > 1 week
         
         if (acthis.size()== 7){hiscorrect = 1;}  
 
                  
         for( var i = 0; i < ( acthis.size() - hiscorrect); i ++) {
           totalSteps = totalSteps + acthis[i].steps;
           totalGoal  = totalGoal +  acthis[i].stepGoal;
         }
         totalSteps = totalSteps + activity.steps;
         totalGoal = totalGoal + activity.stepGoal;
         
         if ((totalSteps > 100000) || (totalGoal > 100000)){
            if (goal){
              steps_print = "'" + totalSteps + "/" + totalGoal; 
            } else{
              steps_print = "' " + totalSteps; 
            } 
         }
         else {
            if (goal){
            	steps_print = "'" + totalSteps + " / " + totalGoal; 
            } else{
            	steps_print = "' " + totalSteps;   
            }
         }
         dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
         dc.drawText(x, y, txtfont, steps_print, Gfx.TEXT_JUSTIFY_CENTER);           
}

function drawIcons(dc,x,y,bt,alarm,message,color,fgc,bgc){
        // bluetooth
           var icon_print;
           device_settings = Sys.getDeviceSettings(); 
           var txt_lenght = 0;
           var offset = 0;
            if (bt == true){ txt_lenght++ ;}
            if (message == true) {txt_lenght++ ;}
            if (alarm == true) {txt_lenght++ ;}
            
               if (bt == true){
	                if( device_settings.phoneConnected == true){ // bluetooth connected?
	                  if (color == true){
	                    if ((bgc == Gfx.COLOR_BLUE) || (bgc == Gfx.COLOR_DK_BLUE)){
	                      dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
	                    }
	                  }
	                  else{
	                    if ((bgc == Gfx.COLOR_WHITE) || (bgc == Gfx.COLOR_LT_GRAY)){
	                      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                    }
	                  }
	                } else {
	                    if (bgc == Gfx.COLOR_DK_GRAY){
	                      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	                    }
	                    
	                }
	                if (txt_lenght == 3) {offset = 14;}
	                if (txt_lenght == 2) {offset = 7;}
	                if (txt_lenght == 1) {offset = 0;}
	                
	                dc.drawText(x-offset , y, fontmintxt, "}", Gfx.TEXT_JUSTIFY_CENTER); 
               }
               
               if (alarm == true){
                 // alarm
                if (device_settings.alarmCount > 0){
                  if (color == true){
                        // BG COLOR Check
						if ((bgc == Gfx.COLOR_GREEN) || (bgc == Gfx.COLOR_DK_GREEN)){
	                      dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                  }
	                  else{
	                    // BG COLOR Check
						if ((bgc == Gfx.COLOR_WHITE) || (bgc == Gfx.COLOR_LT_GRAY)){
	                      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                  }
                     } else {
	                    // BG COLOR Check
						if (bgc == Gfx.COLOR_DK_GRAY){
	                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                }
	                if (txt_lenght == 3) {offset = 0;}
	                if (txt_lenght == 2) {offset = -7;}
	                if (txt_lenght == 1) {offset = 0;}
	                
	                dc.drawText(x-offset , y, fontmintxt, "#", Gfx.TEXT_JUSTIFY_CENTER);
                }
               if (message == true){ // message
                if (device_settings.notificationCount > 0){
                  if (color == true){
	                  // BG COLOR Check
						if (bgc == Gfx.COLOR_YELLOW){
	                      dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                  //dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
	                  }
	                  else{
	                    // BG COLOR Check
						if ((bgc == Gfx.COLOR_WHITE) || (bgc == Gfx.COLOR_LT_GRAY)){
	                      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                    //dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	                  }
					} else {
					// BG COLOR Check
						if (bgc == Gfx.COLOR_DK_GRAY){
	                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
	                    //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
	                }                  
	                if (txt_lenght == 3) {offset = -16;}
	                if (txt_lenght == 2) {offset = 7;}
	                if (txt_lenght == 1) {offset = 0;}
	                
	                dc.drawText(x-offset , y, fontmintxt, "|", Gfx.TEXT_JUSTIFY_CENTER);  
               }
}

function drawStepsGraph(dc,x,y,device_settings,balken, mode, color, fgc, bgc){
        
        var language = App.getApp().getProperty("language");
            if (language == 0){ language = 1;}  // englisch ist in settings 0 aber im array 1 ..muss ich mal korrigieren
	        else if (language == 1){ language = 0;}
	        else { language = 0;}
            
	     dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
       //dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
       x = dc.getWidth()/2 - 118/2;  
       y = y + balken * 2 +6;  
         var activity = ActivityMonitor.getInfo();
         var acthis = ActivityMonitor.getHistory();
         var acthismax = 0;
         var stepsGoal = activity.stepGoal;
         var stepsLive = activity.steps;
         var maxindicator = 7; 
         var maxsteps = 0;
         
         //zuerst mal über die History loopen
           // LOOP at history und max speichern
			 for( var i = 0; i < acthis.size(); i ++) {
				  if ( acthis[i].steps > acthismax ) {
				   acthismax = acthis[i].steps;
				  }	
				  if (acthis[i].stepGoal > acthismax ){
				   acthismax = acthis[i].stepGoal;
				  }
				  // max steps auslesen
				  if (acthis[i].steps >= maxsteps) {
				     maxsteps = acthis[i].steps;
				     maxindicator = 6-i;
				  }
			  }
         // nur sicherheitshalber... heute neuer Rekord? oder neues max Goal?
         if (activity.steps > acthismax){
           acthismax = activity.steps;
         }
         if (activity.stepGoal > acthismax){
           acthismax = activity.stepGoal;
         }
         if (activity.steps >= maxsteps) {
           maxsteps = activity.steps;
           maxindicator = 7;
         }
         
         // jetzt die steps auf max beziehen und in die 17 Balken aufteilen
         // Goal grau / steps weiß
         
       var teiler = acthismax / balken;  
       if (teiler == 0) {teiler = 1;}
       var anzsteps;
       var anzgoal;
       var today = dateStringsshort.day_of_week + 7;
       
       //wochentage sind ja 7 Tage rollieren in der Vergangenheit...daher 14 Tage im array
       //0 = deutsch
       //1 = englisch
       var weekday = [
					    {1 => "So", 2 => "Mo", 3  => "Di", 4=> "Mi", 5 => "Do", 6 =>"Fr", 7=> "Sa", 8 => "So", 9 => "Mo", 10 => "Di", 11 => "Mi", 12 => "Do" ,13 => "Fr", 14 => "Sa", 15 => "So"},
					    {1 => "Sun", 2 => "Mon", 3  => "Tue", 4=> "Wed", 5 => "Thu", 6 =>"Fri", 7=> "Sat", 8 => "Sun", 9 => "Mon", 10 => "Tue", 11 => "Wed", 12 => "Thu" ,13 => "Fri", 14 => "Sat", 15 => "Sun"},
                        {1 => "Di", 2 => "Lu", 3  => "Ma", 4=> "Me", 5 => "Je", 6 =>"Ve", 7=> "Sa", 8 => "Di", 9 => "Lu", 10 => "Ma", 11 => "Me", 12 => "Je" ,13 => "Ve", 14 => "Sa", 15 => "Di"},
					    {1 => "BC", 2 => "N0", 3  => "BT", 4=> "CP", 5 => "qT", 6 =>"NT", 7=> "CQ", 8 => "BC", 9 => "N0", 10 => "BT", 11 => "CP", 12 => "qT" ,13 => "NT", 14 => "CQ", 15 => "BC"}
						 ]; 

       var colorproz;              
       for (var k = 0; k < acthis.size(); k++){
          anzsteps = acthis[acthis.size()-k-1].steps / teiler;
          anzgoal  = acthis[acthis.size()-k-1].stepGoal / teiler;
           
           if (color){
	          if ( anzgoal != 0){
	             colorproz = (anzsteps *100 / anzgoal);
	             if ( colorproz >= 100){ //grün
	                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz  >= 85){ // Dunkelgrün
	                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 70) { // blau
	                dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 50) { // gelb
	                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 35){ // orange
	                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 20){ // pink 
	                dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >=  0){ // rot 
	               dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	             }	          
	          } else { // kein Goal?
	             dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	          }
	          //Sys.print("steps" +anzsteps);
	          //Sys.print("goal" + anzgoal);
	          //Sys.println(" steps/ goal"+(anzsteps / anzgoal)*100);
	        } // Ende Colormode  
          if (anzsteps >= anzgoal) 
              {anzgoal = 0;} 
          else {anzgoal = anzgoal - anzsteps;}
          
          for (var i = 1; i <= (anzgoal + anzsteps); i++){
            if (i <= anzsteps) {
               if (color == 0){ // schwarz/weiss
                 dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
               }
            }
            else { // Inactiver Teil zeichnen
               // BG COLOR Check
			    if (bgc == Gfx.COLOR_DK_GRAY){
	              dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	            }else{
	              dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	            } // Ende bgc check
               //dc.setColor( Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            }
            
            
            if (mode == 1){ //liniendiagramm 
               dc.drawLine(x + k*3 +k*12, y-i*2, x + k*3 +k*12 +12, y-i*2);          
            }
            else if (mode == 2){ //Balkendiagramm
              for (var j = 0; j<=2;j++){ 
                dc.fillRectangle(1 + x + k*3 +k*12 + j*4, y-i*4, 3, 3);
              } 
            }     
           }
           //max gefunden
           if (maxindicator == k){
            dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
            //dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

            if (mode == 1){ // Liniendiagramm
                  dc.drawText(x+k*3+k*12+6, y-balken*2 -11, fontxtiny, maxsteps ,Gfx.TEXT_JUSTIFY_CENTER);
                  dc.drawText(x+k*3+k*12+6, y-balken*2 -5, fontxtiny, "v",Gfx.TEXT_JUSTIFY_CENTER); 
              }
              else if (mode == 2){ //Balkendiagrmm
                  dc.drawText(x+k*3+k*12+6, y-balken*4 -11, fontxtiny, maxsteps ,Gfx.TEXT_JUSTIFY_CENTER);
                  dc.drawText(x+k*3+k*12+6, y-balken*4 -5, fontxtiny, "v",Gfx.TEXT_JUSTIFY_CENTER);
              } 
           }                            
          dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
          dc.drawText(x+k*3+k*12+1, y+1, fontxtiny, weekday[language][today-(7-k)],Gfx.TEXT_JUSTIFY_LEFT);
       } // Ende k
      
       // History gezeichnet --> jetzt noch heute zeichnen
           anzsteps = stepsLive / teiler;
           anzgoal  = stepsGoal / teiler;
           if (color){
	          if ( anzgoal != 0){
	             colorproz = (anzsteps *100 / anzgoal);
	             if ( colorproz >= 100){ //grün
	                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz  >= 85){ // Dunkelgrün
	                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 70) { // blau
	                dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 50) { // gelb
	                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 35){ // orange
	                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >= 20){ // pink 
	                dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_TRANSPARENT);
	             } else if (colorproz >=  0){ // rot 
	               dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	             }	          
	          } else { // kein Goal?
	             dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	          }
	          //Sys.print("steps" +anzsteps);
	          //Sys.print("goal" + anzgoal);
	          //Sys.println(" steps/ goal"+(anzsteps / anzgoal)*100);
	        } // Ende Colormode 
           
           
          if (anzsteps >= anzgoal) 
              {anzgoal = 0;} 
          else {anzgoal = anzgoal - anzsteps;}
          
          for (var i = 1; i <= (anzgoal + anzsteps); i++){
            if (i <= anzsteps) {
                if (color == 0){ // schwarz/weiss
                    dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                 }
            }
            else { // Ziel nicht erreicht - Goal anzeigen
              // BG COLOR Check
			   if (bgc == Gfx.COLOR_DK_GRAY){
	             dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	           }else{
	             dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	           } // Ende bgc check
              //dc.setColor( Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);}
            } // diese Klammer war unsicher - TEST TEST TEST TEST
            if (mode == 1){ //liniendiagramm 
               dc.drawLine(x + 7*3 +7*12, y-i*2, x + 7*3 +7*12 +12, y-i*2);          
            }
            else if (mode == 2){ //Balkendiagramm
              for (var j = 0; j<=2;j++){ 
                dc.fillRectangle(1 + x + 7*3 +7*12 + j*4, y-i*4, 3, 3);
              } 
            }
          }
       dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
           if (maxindicator == 7){
              if (mode == 1){ // Liniendiagramm
                  dc.drawText(x+7*3+7*12+6, y-balken*2 -11, fontxtiny, maxsteps ,Gfx.TEXT_JUSTIFY_CENTER);
                  dc.drawText(x+7*3+7*12+6, y-balken*2 -5, fontxtiny, "v",Gfx.TEXT_JUSTIFY_CENTER); 
              }
              else if (mode == 2){ //Balkendiagrmm
                  dc.drawText(x+7*3+7*12+6, y-balken*4 -11, fontxtiny, maxsteps ,Gfx.TEXT_JUSTIFY_CENTER);
                  dc.drawText(x+7*3+7*12+6, y-balken*4 -5, fontxtiny, "v",Gfx.TEXT_JUSTIFY_CENTER);
              } 
           } 
       
       dc.drawText(x+1+7*3+7*12, y+1, fontxtiny, weekday[language][today],Gfx.TEXT_JUSTIFY_LEFT);
             
       dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
       dc.drawLine(x, y, 118+x, y);
}

function drawDate(dc,x,y,txtfont,mode, language,fgc, bgc){  // Datum #######################################################################################################################
        dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
        dateStringsshort = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT);
 
        dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);                
        var datum_print;
        var weekday = [
						{1 => "So", 2 => "Mo", 3  => "Di", 4=> "Mi", 5 => "Do", 6 =>"Fr", 7=> "Sa", 8 => "So", 9 => "Mo", 10 => "Di", 11 => "Mi", 12 => "Do" ,13 => "Fr", 14 => "Sa", 15 => "So"},
					    {1 => "Sun", 2 => "Mon", 3  => "Tue", 4=> "Wed", 5 => "Thu", 6 =>"Fri", 7=> "Sat", 8 => "Sun", 9 => "Mon", 10 => "Tue", 11 => "Wed", 12 => "Thu" ,13 => "Fri", 14 => "Sat", 15 => "Sun"},
                        {1 => "Di", 2 => "Lu", 3  => "Ma", 4=> "Me", 5 => "Je", 6 =>"Ve", 7=> "Sa", 8 => "Di", 9 => "Lu", 10 => "Ma", 11 => "Me", 12 => "Je" ,13 => "Ve", 14 => "Sa", 15 => "Di"},
					    {1 => "BC", 2 => "N0", 3  => "BT", 4=> "CP", 5 => "qT", 6 =>"NT", 7=> "CQ", 8 => "BC", 9 => "N0", 10 => "BT", 11 => "CP", 12 => "qT" ,13 => "NT", 14 => "CQ", 15 => "BC"}
						 ]; 

        		
		if (mode ==1 ) { // datum nur wenn medium ausgabe
	        if (language == 0){ datum_print = weekday[1][dateStringsshort.day_of_week];}
	        else if (language == 1){ datum_print = weekday[0][dateStringsshort.day_of_week];}
	        else if (language == 2){ datum_print = weekday[2][dateStringsshort.day_of_week];}
	        else if (language == 3){ datum_print = weekday[3][dateStringsshort.day_of_week];}
	        else { datum_print = weekday[1][dateStringsshort.day_of_week];}
        }
        
        
        if( !device_settings.is24Hour ){ //MONAT Tag oder TAG  Monat
          if (mode == 1){
            datum_print =     datum_print + " " + dateStringsshort.month.toString() + "/" + dateStringsshort.day.toString() ;
          } 
          else {
            datum_print =  dateStringsshort.month.toString() + "/" + dateStringsshort.day.toString() ;
          } 
        } else {
           if (mode == 1){
            datum_print =    datum_print + " " + dateStringsshort.day.toString() + "." + dateStringsshort.month.toString() + ".";             
           }
           else{
             datum_print =   dateStringsshort.day.toString() + "." + dateStringsshort.month.toString() + ".";              
           }
        }
        
        dc.drawText(x, y, txtfont, datum_print, Gfx.TEXT_JUSTIFY_CENTER);           
}


function drawSteps(dc,x,y,txtfont,logo,color,fgc,bgc){ // steps ##################################################################################################################
             dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                var activity = ActivityMonitor.getInfo();
                //var moveBarLevel = activity.moveBarLevel;
                var stepsGoal = activity.stepGoal;
                var stepsLive = activity.steps; 
               // var kkal     = activity.calories;
               // var km       = activity.distance.toFloat() / 100 / 1000;
                if (stepsGoal == 0){stepsGoal = 1;} // div 0 Schutz
                var activproz = stepsLive * 100  / stepsGoal.toFloat();
                var steps_txt = "";
                if (logo){
                  steps_txt = "' ";
                }
                steps_txt = steps_txt + stepsLive.toString();
                dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                
                if ( color ){
		             if ( activproz >= 100){ //grün
		                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz  >= 85){ // Dunkelgrün
		                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz >= 70) { // blau
		                dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz >= 50) { // gelb
		                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz >= 35){ // orange
		                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz >= 20){ // pink 
		                dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_TRANSPARENT);
		             } else if (activproz >=  0){ // rot 
		               dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	             }	          
	          } else { // sw mode
		             // BG COLOR Check
						if (bgc == Gfx.COLOR_LT_GRAY){
	                      dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	                    }else{
	                      dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	                    } // Ende bgc check
		             //dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
	          }
                dc.drawText(x,y, txtfont,steps_txt , Gfx.TEXT_JUSTIFY_CENTER);
}

function drawMoveBar(dc,x,y,txtfont,color,fgc,bgc){ // steps ##################################################################################################################
             dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                var activity = ActivityMonitor.getInfo();
                var moveBarLevel = activity.moveBarLevel;
                // movebar == 5 move!
                //moveBarLevel = 5;
                        if ( (bgc == Gfx.COLOR_ORANGE) || (bgc == Gfx.COLOR_RED) || (bgc == Gfx.COLOR_YELLOW) || (bgc == Gfx.COLOR_WHITE) ){
		                    if      (moveBarLevel == 0) { x = x -0; if(color){dc.setColor(fgc, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 1) { x = x -2;if(color){dc.setColor(fgc, Gfx.COLOR_BLACK);} 
			                }else if (moveBarLevel == 2) { x = x -5;if(color){dc.setColor(fgc, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 3) { x = x -7;if(color){dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 4) { x = x -12;if(color){dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 5) { x = x -17;if(color){dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_BLACK);}
			                }
		                }else {
			                if      (moveBarLevel == 0) { x = x -0; if(color){dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 1) { x = x -2;if(color){dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);} 
			                }else if (moveBarLevel == 2) { x = x -5;if(color){dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 3) { x = x -7;if(color){dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 4) { x = x -12;if(color){dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_BLACK);}
			                }else if (moveBarLevel == 5) { x = x -17;if(color){dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);}
		                    }
		                }
                if (moveBarLevel >= 1) {dc.fillRectangle(x, y, 4, 6); } 
                if (moveBarLevel >= 2) {dc.fillRectangle(x + 5, y, 4, 6); }
                if (moveBarLevel >= 3) {dc.fillRectangle(x + 10, y, 4, 6); }
                if (moveBarLevel >= 4) {dc.fillRectangle(x + 15, y, 8, 6); }
                if (moveBarLevel >= 5) {dc.fillRectangle(x + 24, y, 10, 6); 
                                        dc.drawText(dc.getWidth()/2+1,y+6, txtfont,"Moqe now!" , Gfx.TEXT_JUSTIFY_CENTER);
                                        }

}
//function drawStepsBar(dc,x,y){
//                var activity = ActivityMonitor.getInfo();
//                var moveBarLevel = activity.moveBarLevel;
//                var stepsGoal = activity.stepGoal;
//                var stepsLive = activity.steps;
//                var activproz = stepsLive / stepsGoal.toFloat();
                
                
//                dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK); 
        // erstmal Ziel und pfeil zeichnen
//        dc.drawText(170, y-10, fontxtiny, stepsGoal.toString(), Gfx.TEXT_JUSTIFY_RIGHT);
        //dc.drawText(170 - dc.getTextWidthInPixels(stepsGoal.toString()) /2, y-10, fontxtiny, "v", Gfx.TEXT_JUSTIFY_RIGHT);
        
//        for ( var i = 1; i < 44; i++){
//           dc.fillRectangle(45+ i*4, y, 3, 3);
//        }
//}

function drawKkal(dc,x,y,txtfont,logo,week,fgc,bgc){ // kilo Kalorien ##################################################################################################################
             dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                var activity = ActivityMonitor.getInfo();
                //var moveBarLevel = activity.moveBarLevel;
                //var stepsGoal = activity.stepGoal;
                  var kkal     = activity.calories;
               // var km       = activity.distance.toFloat() / 100 / 1000;
                var kkal_txt = "";
       			var acthis = ActivityMonitor.getHistory();
               
         var totalKkal = 0;
         var kkal_print;
	         if (week){ // V1.01 Bug Woche vergessen abzufragen
			         var hiscorrect = 0; // 7 days history + today > 1 week
			         
			         if (acthis.size()== 7){hiscorrect = 1;}  
			 
			                  
			         for( var i = 0; i < ( acthis.size() - hiscorrect); i ++) {
			           totalKkal = totalKkal + acthis[i].calories;
			         }
			  } // ende week V1.01       
         totalKkal = totalKkal + activity.calories;
         
                if (logo){
                   kkal_txt = "{ ";
                }
                kkal_txt = kkal_txt + totalKkal;
                dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x,y  , txtfont,kkal_txt , Gfx.TEXT_JUSTIFY_CENTER);
}


function drawStepsGoal(dc,x,y,tight,txtfont,color,fgc,bgc){// steps and GOAL #########################################################################################################
                var activity = ActivityMonitor.getInfo();
                //var moveBarLevel = activity.moveBarLevel;
                var stepsGoal = activity.stepGoal;
                var stepsLive = activity.steps; 
               // var kkal     = activity.calories;
               // var km       = activity.distance.toFloat() / 100 / 1000;
                if (stepsGoal == 0 ) {stepsGoal = 1;} // div 0! 
                var activproz = stepsLive * 100 / stepsGoal.toFloat();
                
                var steps_txt = "' ";
                var space = " ";
                if ((tight == 1) && ((stepsGoal >= 10000)||(stepsLive >= 10000)) ){
                  steps_txt = "'";
                  space = "";
                }
                 steps_txt = steps_txt + stepsLive.toString() + space + "/"+ space + stepsGoal.toString() ;

			if (color){
	             if ( activproz >= 100){ //grün
	                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (activproz  >= 85){ // Dunkelgrün
	                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
	             } else if (activproz >= 70) { // blau
	                dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
	             } else if (activproz >= 50) { // gelb
	                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	             } else if (activproz >= 35){ // orange
	                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
	             } else if (activproz >= 20){ // pink 
	                dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_TRANSPARENT);
	             } else { // rot 
	               dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	             }	          
	          } else { // SW mode
	             dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
	          }
	          
	    dc.drawText(x,y  , txtfont,steps_txt , Gfx.TEXT_JUSTIFY_CENTER);               
                
}

function drawWorldTime(dc,x,y,txtfont,fgc,bgc){  //Weltzeit ################################################################################################################# 
		       dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
		       var weltzeit = 2;
		       var setweltzeit = App.getApp().getProperty("utc");
				 
				   if       (setweltzeit == 1) { weltzeit = -12;
				   }else if (setweltzeit == 2) { weltzeit = -11;
				   }else if (setweltzeit == 3) {weltzeit = -10;
				   }else if (setweltzeit == 4) {weltzeit = -9.5;
				   }else if (setweltzeit == 5) {weltzeit = -9;
				   }else if (setweltzeit == 6) {weltzeit = -8;
				   }else if (setweltzeit == 7) {weltzeit = -7;
				   }else if (setweltzeit == 8) {weltzeit = -6;
				   }else if (setweltzeit == 9) {weltzeit = -5;
				   }else if (setweltzeit == 10) {weltzeit = -4;
				   }else if (setweltzeit == 11) {weltzeit = -3.5;
				   }else if (setweltzeit == 12) {weltzeit = -3;
				   }else if (setweltzeit == 13) {weltzeit = -2;
				   }else if (setweltzeit == 14) {weltzeit = -1;
				   }else if (setweltzeit == 15) {weltzeit = 0;
				   }else if (setweltzeit == 16) {weltzeit = 1;
				   }else if (setweltzeit == 17) {weltzeit = 2;
				   }else if (setweltzeit == 18) {weltzeit = 3;
				   }else if (setweltzeit == 19) {weltzeit = 3.5;
				   }else if (setweltzeit == 20) {weltzeit = 4;
				   }else if (setweltzeit == 21) {weltzeit = 4.5;
				   }else if (setweltzeit == 22) {weltzeit = 5;
				   }else if (setweltzeit == 23) {weltzeit = 5.5;
				   }else if (setweltzeit == 24) {weltzeit = 5.75;
				   }else if (setweltzeit == 25) {weltzeit = 6;
				   }else if (setweltzeit == 26) {weltzeit = 6.5;
				   }else if (setweltzeit == 27) {weltzeit = 7;
				   }else if (setweltzeit == 28) {weltzeit = 8;
				   }else if (setweltzeit == 29) {weltzeit = 8.5;
				   }else if (setweltzeit == 30) {weltzeit = 8.75;
				   }else if (setweltzeit == 31) {weltzeit = 9;
				   }else if (setweltzeit == 32) {weltzeit = 9.5;
				   }else if (setweltzeit == 33) {weltzeit = 10;
				   }else if (setweltzeit == 34) {weltzeit = 10.5;
				   }else if (setweltzeit == 35) {weltzeit = 11;
				   }else if (setweltzeit == 36) {weltzeit = 12;
				   }else if (setweltzeit == 37) {weltzeit = 12.75;
				   }else if (setweltzeit == 38) {weltzeit = 13;
				   }else if (setweltzeit == 39) {weltzeit = 14;
				   }
		       var clockTime = Sys.getClockTime();
		       var dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
			   var zone = clockTime.timeZoneOffset / 3600f; // +2.0000
				//var offset = zone.format("%+.f");
				 if (zone >= 0){
				   if (weltzeit >= 0){
				     // Sys.print("hier1");
				      // Sys.println(zone + "z" + weltzeit + "w");
				      
				     if (zone.toNumber() == weltzeit.toNumber()) {weltzeit = 0.0;} //Sys.print("hier");}
				     else if (zone.toNumber() > weltzeit.toNumber())  {weltzeit = (zone - weltzeit) *-1;}//Sys.print("hier2");}
				     else if (zone.toNumber() < weltzeit.toNumber())  {weltzeit = weltzeit - zone;} //Sys.print("hier3");}
				     //Sys.println(zone + "z" + weltzeit + "w");
				     
				   }
				   else if (weltzeit < 0){
				     weltzeit = weltzeit - zone;
				   }
				 }
				 else {
				   if (weltzeit >= 0){
				     weltzeit = (zone - weltzeit) * (-1);
				   }
				   else if (weltzeit < 0){
				     if (zone < weltzeit) {weltzeit = (zone - weltzeit) * (-1); } // minus minus zone = + Zone
				     if (zone > weltzeit) {weltzeit = weltzeit - zone;} // minus minus zone = + Zone  
				   }
				 }
			  
			  var welthour = weltzeit.toNumber();
		      var weltmin  = ((weltzeit - welthour) * 60).toNumber() ;
		      // Sys.println("weltzeit: " + weltzeit + "welthour: " +welthour );
		      // Sys.println("weltmin:  "+ weltmin); 
		       var hour, min, time, day;
		       var time_string;
		        min  = clockTime.min;
		        hour = clockTime.hour;
		       var ampm = " ";
		       var diffday = " "; 
		        //Zweite Uhrzeit berechnen
		        hour = hour + welthour;
		        min = min + weltmin;
		        
		        // Minuten korrigieren (danke Indien und Nepal..)
		        if (min >= 60) {
		           min = min -60;
		           hour = hour +1;
		        }
		        else if (min < 0) {
		           min = min + 60;
		           hour= hour -1;
		        }
		        
		        //Sys.println(hour);
		        //Sys.println(min);
		        if( !device_settings.is24Hour ) { // AM/PM anzeige je nach Zeitzone kann es zu 36 Stunden kommen
		            
		                   // positive Tagverschiebung
				           if ( ((hour >= 12) && (hour <24)) ||  (hour >= 36)) {
				                if (hour >= 36){
					                hour = hour - 36;
					                diffday = " [+1]";
					            } 
					            else{
					              hour = hour - 12;
					            }   
					            ampm = "pm "; // pm
					                
							}
						    else{
						        if (hour >=24) {
						            hour = hour -24;
						            diffday = " [+1]";
						        }  
						        ampm = "am ";  //am
							}
							// negative Tagverschiebung
							if ( ((hour < 0) && (hour >=-12)) ||  (hour < -24)) {
				                if (hour <= -24){
					                hour = hour + 24;
					                diffday = " [-2]"; // this should never happen!
					            } 
					            else{
					              hour = hour + 12;
					              diffday = " [-1]";
					            }   
					            ampm = "pm "; // pm
					                
							}
						    else if (hour < 0){
						        diffday = " [-1]";
						        hour = hour + 12; 
						        ampm = "am ";  //am
						       
							}
							
				        if (hour == 0) {hour = 12;}    
				        hour  = Lang.format("$1$",[hour.format("%2d")]);
				        min   = Lang.format("$1$",[min.format("%02d")]); 
				  }
				  else { // 24 Stunden format
				           if (hour >= 24) { 
				              hour = hour - 24;
				              diffday = " [+1]";
				           }
				           else if (hour < 0) {
				              hour = hour + 24;
				              diffday = " [-1]";
				           }              
				          hour  = Lang.format("$1$",[hour.format("%02d")]);
				          min   = Lang.format("$1$",[min.format("%02d")]);
				  }
		        
		        
		        //Sys.print("hourneu: " + hour + " minneu: " + min );
		        dc.setColor( fgc, Gfx.COLOR_TRANSPARENT);
		        
		        // <V1.01 Bugfix> 
		        if (hour == 24) {hour = "0";}
		        // </V1.01>
		        var time_print = hour + ":" + min;
		        dc.drawText(dc.getWidth()/2, y, txtfont, time_print, Gfx.TEXT_JUSTIFY_CENTER);
		        if (!device_settings.is24Hour) {
		           dc.drawText(40,y,fontmintxt,ampm, Gfx.TEXT_JUSTIFY_LEFT);
		        }
		        if ((diffday != " ") && (!App.getApp().getProperty("utchide") )){
		           dc.drawText(dc.getWidth()-30,y,fontmintxt,diffday, Gfx.TEXT_JUSTIFY_RIGHT);
		        } 
		        
      
}

function drawSec(dc,mode,fgc,bgc,watch){
        var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );
        var sec;
         
        sec  = dateInfo.sec;
       if ( mode == 1 && ( watch == 1 || watch == 2)){     
            for (var k = 0; k <=59; k++){
            if ( ( k >= ( sec - 4 ) ) && ( k<=sec)){    
	            var xx, xx2, yy, yy2, winkel, slim;
	            winkel = 180 +k * -6;
	            slim = 2;
	            yy  = dc.getWidth()/2 * (1+Math.cos(Math.PI*(winkel-2)/180));
	            yy2 = dc.getWidth()/2 * (1+Math.cos(Math.PI*(winkel+3)/180));  
	            xx  = dc.getWidth()/2 * (1+Math.sin(Math.PI*(winkel-2)/180));
	            xx2  = dc.getWidth()/2 * (1+Math.sin(Math.PI*(winkel+3)/180));
	            if ( (bgc == Gfx.COLOR_DK_RED) || (bgc == Gfx.COLOR_RED) ){
	              if ( k == sec ){dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN); }
	              if ( k == sec - 1 ){dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);}
	            }else{
	              if ( k == sec ){dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED); }
	              if ( k == sec - 1 ){dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED);}
	            }
	            if ( k == sec - 2 ){dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);}
	            if ( k == sec - 3 ){dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);}
	            if ( k == sec - 4 ){dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);}    
	            dc.fillPolygon([[dc.getWidth()/2, dc.getHeight()/2], [xx, yy] ,[xx2,yy2]]);
            }  
            }
            dc.setColor(bgc,bgc);
            dc.fillCircle(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-4); 
        }// mode 1
        else if (mode == 2 && ( watch == 1 || watch == 2)) {
                dc.setPenWidth(10);
				for (var k = 0; k <=59; k++){
				            if ( ( k >= ( sec - 3 ) ) && ( k<=sec)){    
					            
					            if (bgc == Gfx.COLOR_WHITE){
					               dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
					            }else{
					               dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);    
					            }
					            
					            //var xx, xx2, yy, yy2, slim;
					            var winkel;
					            winkel = 90 +k * -6;    // Winkel im bogenmaß? dann wäre es aber 6,66 verdammt!
					            
					            //yy  = dc.getHeight()/2 * (1+Math.cos(Math.PI*(winkel)/180));
					            //yy2 = dc.getHeight()/2 * (1+Math.cos(Math.PI*(winkel -1)/180));  
					            //xx  = dc.getHeight()/2 * (1+Math.sin(Math.PI*(winkel)/180));
					            //xx2  = dc.getHeight()/2 * (1+Math.sin(Math.PI*(winkel -1)/180));
					            //dc.fillPolygon([[109, 109], [xx, yy] ,[xx2,yy2]]);
					            //dc.drawLine(dc.getWidth()/2, dc.getHeight()/2, xx, yy);
					            //dc.drawLine(dc.getWidth()/2, dc.getHeight()/2, xx2, yy2);
					            
					            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2-2, 0, winkel, winkel+2);
					            
				            }  
				            }
				            dc.setPenWidth(1);
				            dc.setColor(bgc, bgc);
				            dc.fillCircle(dc.getHeight()/2, dc.getHeight()/2, dc.getHeight()/2-9); 
				        
        } // end Mode 3
                else if (mode == 3 && ( watch == 1 || watch == 2)) {
				for (var k = 0; k <=59; k++){
				            if ( ( k >= ( sec  ) ) && ( k<=sec)){    
					            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
					            var xx, xx2, yy, yy2, winkel, slim;
					            winkel = 180 +k * -6;
					            slim = 2;
					            yy  = dc.getHeight()/2 * (1+Math.cos(Math.PI*(winkel-2)/180));
					            yy2 = dc.getHeight()/2 * (1+Math.cos(Math.PI*(winkel +3)/180));  
					            xx  = dc.getHeight()/2 * (1+Math.sin(Math.PI*(winkel-2)/180));
					            xx2 = dc.getHeight()/2 * (1+Math.sin(Math.PI*(winkel +3)/180));
					            if (bgc == Gfx.COLOR_WHITE){
					               dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
					            }else{
					               dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);    
					            }
					            dc.fillPolygon([[dc.getHeight()/2, dc.getHeight()/2], [xx, yy] ,[xx2,yy2]]);
					          }  
				            }
				            dc.setColor(bgc, bgc);
				            dc.fillCircle(dc.getHeight()/2, dc.getHeight()/2, dc.getHeight()/2-9); 
				        
        } // end Mode 3
}

    
function drawbatt(dc,batx,baty,mode, color,fontminvari,fgc,bgc){ // nur noch mode 1 und 3 aktive - 2 wird dynamisch gesetzt
              // Batterie neu
              var batt = Sys.getSystemStats().battery;
              batt = batt.toNumber();
              //var batx, baty;
              //batx = 170;
              //baty = 136;  
              // Rahmen zeichnen  
              // nur zeichnen bei Mode 1 & 2
              // nachträglich auf color umgebaut - pfusch
              if ((mode == 1) && (!color)) {mode = 2;} // wenn color dann mode 2
              if (( mode == 1) or ( mode == 2) ){
                  batx = batx - 16;
	              dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE); 
	              dc.fillRectangle(batx, baty, 31, 12); // weißer Bereich BODY
	              
	              // BG COLOR Check
				   if (bgc == Gfx.COLOR_DK_GRAY){
	                 dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
	               }else{
	                 dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
	               } // Ende bgc check
	              //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY); 
	              dc.fillRectangle(batx + 31, baty +3, 3, 6); //  BOBBL
	              dc.drawRectangle(batx, baty, 31, 12); // Rahmen
              }
              //Jetzt Füllstand zeichnen
               if (mode == 1){
		               if (batt >= 50) { // großen Block zeichnen
		                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
		                dc.fillRectangle(batx +1, baty+1, 14, 10);
		                if (batt >= 60){dc.fillRectangle(batx+16, baty+1, 2, 10);}
		                if (batt >= 70){dc.fillRectangle(batx+19, baty+1, 2, 10);}
		                if (batt >= 80){dc.fillRectangle(batx+22, baty+1, 2, 10);}
		                if (batt >= 90){dc.fillRectangle(batx+25, baty+1, 2, 10);}
		                if (batt >= 100){dc.fillRectangle(batx+1, baty+1, 29, 10);
		                   dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		                   dc.drawText(batx+3 ,  baty+4 , Gfx.FONT_XTINY, "100" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER); 
		                }
		               }else { // kleiner 50% akku
		                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
		                if (batt >= 40){dc.fillRectangle(batx+12, baty+1, 4, 10);} 
		                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_YELLOW);
		                if (batt >= 30){dc.fillRectangle(batx+8, baty+1, 4, 10);} 
		                dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_ORANGE);
		                if (batt >= 20){dc.fillRectangle(batx+5, baty+1, 4, 10);} 
		                dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		                if (batt >= 11){dc.fillRectangle(batx+1, baty+1, 4, 10);} // 10% Rest
		                else{
		                   dc.drawText(batx+3 ,  baty+5 , Gfx.FONT_XTINY, "LOW" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);  
		                }
		                if (batt >=11) { // Batt Text ausgeben zwischen 49% und 11%
		                    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		                    dc.drawText(batx+28 ,  baty, fonttiny, batt.toString() , Gfx.TEXT_JUSTIFY_RIGHT);
		                 }
		            }// ende mode 1
		            }
		            else if (mode == 2){
		            if (batt >= 10) { // großen Block zeichnen
		                //xxx hier xxx
		                  dc.fillRectangle(batx+1+29 - (100-batt)/3.4, baty+1, (100-batt)/3.4+1, 10);
		                  if (batt < 50) { // Batt Text ausgeben zwischen 49% und 11%
		                    dc.setColor(fgc, Gfx.COLOR_TRANSPARENT);
		                    dc.drawText(batx+28 ,  baty , fonttiny, batt.toString() , Gfx.TEXT_JUSTIFY_RIGHT);
		                }
		               }else { // Akku kritisch
		                  // BG COLOR Check
							if ((bgc == Gfx.COLOR_RED) || (bgc == Gfx.COLOR_DK_RED)){
		                      dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		                    }else{
		                      dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		                    } // Ende bgc check
		                  //dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		                  dc.drawText(batx+14 ,  baty -4, Gfx.FONT_XTINY, "LOW" , Gfx.TEXT_JUSTIFY_CENTER);  
		               }
		               
		            } // ende mode 2     
                    else if (mode == 3){// Mode 3 Text only
                     if (batt <=10) {dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);}
                     dc.drawText(batx ,  baty , fontminvari, batt.toString() , Gfx.TEXT_JUSTIFY_CENTER);
                    }
} // Ende drawbattfunction
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
            fast_updates = true;
            Ui.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
            fast_updates = false;
            Ui.requestUpdate();
    }

}

// ab hier v1.03################################################SUNSET SUNRAISE###################################################################
class SunCalc {

	hidden const PI   = Math.PI,
		RAD  = Math.PI / 180.0,
		PI2  = Math.PI * 2.0,
		DAYS = Time.Gregorian.SECONDS_PER_DAY,
		J1970 = 2440588,
		J2000 = 2451545,
		J0 = 0.0009;

	hidden const TIMES = [
		-18 * RAD,
		-12 * RAD,
		-6 * RAD,
		-4 * RAD,
		-0.833 * RAD,
		-0.3 * RAD,
		6 * RAD,
		null,
		6 * RAD,
		-0.3 * RAD,
		-0.833 * RAD,
		-4 * RAD,
		-6 * RAD,
		-12 * RAD,
		-18 * RAD
		];

	var lastD, lastLng;
	var	n, ds, M, sinM, C, L, sin2L, dec, Jnoon;

	function initialize() {
		lastD = null;
		lastLng = null;
	}

	function fromJulian(j) {
		return new Time.Moment((j + 0.5 - J1970) * DAYS);
	}

	function round(a) {
		if (a > 0) {
			return (a + 0.5).toNumber().toFloat();
		} else {
			return (a - 0.5).toNumber().toFloat();
		}
	}

	// lat and lng in radians
	function calculate(moment, lat, lng, what) {
		var d = moment.value().toDouble() / DAYS - 0.5 + J1970 - J2000;
		if (lastD != d || lastLng != lng) {
			n = round(d - J0 + lng / PI2);
//			ds = J0 - lng / PI2 + n;
			ds = J0 - lng / PI2 + n - 1.1574e-5 * 68;
			M = 6.240059967 + 0.0172019715 * ds;
			sinM = Math.sin(M);
			C = (1.9148 * sinM + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) * RAD;
			L = M + C + 1.796593063 + PI;
			sin2L = Math.sin(2 * L);
			dec = Math.asin( 0.397783703 * Math.sin(L) );
			Jnoon = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
			lastD = d;
			lastLng = lng;
		}

		if (what == NOON) {
			return fromJulian(Jnoon);
		}

		var x = (Math.sin(TIMES[what]) - Math.sin(lat) * Math.sin(dec)) / (Math.cos(lat) * Math.cos(dec));

		if (x > 1.0 || x < -1.0) {
			return null;
		}

		var ds = J0 + (Math.acos(x) - lng) / PI2 + n - 1.1574e-5 * 68;

		var Jset = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
		if (what > NOON) {
			return fromJulian(Jset);
		}

		var Jrise = Jnoon - (Jset - Jnoon);

		return fromJulian(Jrise);
	}
}
// bis hier SUNSET / SUNRAISE#######################################################################################################################
