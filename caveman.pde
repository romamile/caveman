// ==== VERSIONING ====  =====
String nameProject = "Caveman";
int v1 = 1;
int v2 = 0;
int v3 = 13;
// ==== ===============  =====


//import processing.svg.*;
//import gifAnimation.*;
import beads.*;

// ===== 1) ROOT LIBRARY =====
ptx_inter myPtxInter;
// ===== =============== =====


int wFbo, hFbo, hZone, wZone, hCell, wCell;
float rMig, rZone;

cell myCell;
ribbon myRibbon;
int maxNbrCells = 12;
int maxSizeOnion = 3;
int scroll = 0, scrollIncrement = 10;
int nextFrameExport = 0;

AudioContext ac;
HashMap<String, SamplePlayer> soundMap;

toggle togNotif;
String strNotif;
HashMap<String, PImage> notifMap;

void setup() {
  
  // ===== 2) INIT LIBRARY =====  
  myPtxInter = new ptx_inter(this);
	myPtxInter.scanKey = 'a';
  myPtxInter.versionExp = new String[]{""+v1, ""+v2, ""+v3, nameProject};
  // ===== =============== =====

  fullScreen(P3D, 2);
  //size(1300, 900, P3D);
  noCursor();
    
  
  // Geometry of the UI
  wFbo = myPtxInter.wFrameFbo;
  hFbo = myPtxInter.hFrameFbo;
  
  rMig = 0.14;
  
  
  hZone = int((1-rMig) * hFbo);
  wZone = wFbo/2;
  rZone = wZone * (1.0 / hZone);
  
  hCell = int(rMig * hFbo);
  wCell = int(hCell * rZone);

  
  myRibbon = new ribbon(wFbo, hFbo);
  myCell = new cell();


  // Sound
  ac = AudioContext.getDefaultContext();
  Gain g = new Gain(ac, 2, 0.2);
  ac.out.addInput(g);
  ac.start();

  soundMap = new HashMap<String, SamplePlayer>();

  for (String nameSound : new String[]{"vierge", "delete", "export", "left", "right", "scan", "speed", "changeMode", "grab", "drop", "cantadd"}) {
    soundMap.put( nameSound, new SamplePlayer(ac, SampleManager.sample( dataPath("sound/"+nameSound+".wav")) ) );
    soundMap.get(nameSound).setKillOnEnd(false);
    soundMap.get(nameSound).setPosition(99999999);
    g.addInput(soundMap.get(nameSound));
  }
  
	// Notifications

	notifMap = new HashMap<String, PImage>();
	for (String nameImage : new String[]{"loop_0_empty", "loop_1_loop", "loop_2_pingpong", "export", "cantadd"}) {
			notifMap.put( nameImage, loadImage("./data/"+nameImage+".png") );
	}

	togNotif = new toggle();
	togNotif.setSpanS(3);
	strNotif = "";
}

void draw() {

  // TEST to select a specific ROI
  
  myPtxInter.myPtx.specROItl = new vec2i(0, int(rMig * hFbo));
  myPtxInter.myPtx.specROIbr = new vec2i(wFbo/2, hFbo);
  
  // ===== 3.1) PRE DRAW LIBRARY =====  
	boolean ptxInterRez = myPtxInter.preDraw(); 

	if(!ptxInterRez)
		return;
  // ===== ================================= =====  



  // Your drawing start here


  // A] UPDATE

  myRibbon.update();  

  // B] DRAW
  
  // Keep this part of the code to reset drawing
  background(0);
  myPtxInter.mFbo.beginDraw();

  // Draw here with "myPtxInter.mFbo" before call to classic drawing functions 

  myPtxInter.mFbo.background(0);
  myRibbon.draw(0.25);
  myRibbon.drawRez();
  myRibbon.drawUI();


	// Notifications
	if(togNotif.getState()) {
		myPtxInter.mFbo.image(notifMap.get(strNotif), 650, 0);
	} else {
		togNotif.stop(false); 
	} 

  // ===== 3.2) POST DRAW LIBRARY ===== 
  myPtxInter.postDraw();
  // ===== ================================= =====    


  // shouldn't have anything here...

  switch(nextFrameExport) {
    case 1: myRibbon.generateNewOutputName(); myRibbon.exportGIF("test", this); break;
    case 2: myRibbon.generateNewOutputName(); myRibbon.exportPNG("test"); break;
    case 3: myRibbon.generateNewOutputName(); myRibbon.exportSVG("test"); break;
    case 4:
			myRibbon.generateNewOutputName();
			myRibbon.exportPNG("test");
			myRibbon.exportSVG("test");
			myRibbon.exportGIF("test", this);
			break;
  }
	if(nextFrameExport > 0) {
		nextFrameExport = Math.max(0, nextFrameExport-10);
	}
}



// Function that is triggered at the end of a scan operation
// Use it to update what is meant to be done once you have "new areas"

void atScan() {

  myCell.clear();
  
  // 1) add the areaCore
  for (area itArea : myPtxInter.myPtx.listArea)
      myCell.listAreaCore.add( new areaCore( itArea ) );

  // 2) create and add the transparent PGraphic
  for (areaCore itAreaCore : myCell.listAreaCore)
    itAreaCore.drawIn(myCell.img);
    
  myRibbon.addCell( myCell );

}



void keyPressed() {

  // ===== 4) KEY HANDlING LIBRARY ===== 
	myPtxInter.keyPressedRoot();
  // ===== ================================= =====    

  switch(key) {
  case 'q':
    myRibbon.moving = true;
   	soundMap.get("grab").start(0);
    break;
  case 's':
    myRibbon.speed = true;
    break;

/*    
  case ' ':
    myRibbon.addCell( myCell );
    break;
*/
  case 'd':
    myRibbon.delCurrentCell();
    break;
/*
  case 'f':
    myRibbon.clear();
    break;
*/
  case 'i':
    //myPtxInter.notify("EXPORTING FINISHED!",28, 44, 255);
		triggerNotification("export");
    soundMap.get("export").start(0);
    nextFrameExport = 14;
    break;

/*
  case 'i':
    myPtxInter.notify("EXPORT GIF!",28, 44, 255);
    nextFrameExport = 1;
    break;
  case 'o':
    myPtxInter.notify("EXPORT PNG!",28, 44, 255);
    nextFrameExport = 2;
    break;
  case 'p':
    myPtxInter.notify("EXPORT SVG!",28, 44, 255);
    nextFrameExport = 3;
    break;
*/
  
/*    
  case 'w':
    scroll -= scrollIncrement;
    scroll = max(0, scroll);
    break;
  case 'x':
    scroll += scrollIncrement;
    break;
*/

  case 'v':
    if(myRibbon.speed)
      myRibbon.timeUp();
    else if(myRibbon.moving)
      myRibbon.moveUp();
    else
      myRibbon.indexUp();

    break;
  case 'c':
    if(myRibbon.speed)
      myRibbon.timeDown();
    else if(myRibbon.moving)
      myRibbon.moveDown();
    else
      myRibbon.indexDown();
    break;

  case 'b':
      myRibbon.onionNbr = (myRibbon.onionNbr)%(maxSizeOnion) +1;
/*
    if(myRibbon.index == -1 && myRibbon.prevIndex != -1) {
      if(myRibbon.prevIndex < myRibbon.listCell.size()) {  
        myRibbon.index = myRibbon.prevIndex;
        myRibbon.prevIndex = -1;
      } else {
        if(myRibbon.listCell.size() > 0) { 
          myRibbon.index = 0;
          myRibbon.prevIndex = -1;
        }
      }
      
    } else if(myRibbon.index != -1) {
      myRibbon.prevIndex = myRibbon.index;
      myRibbon.index = -1;
    }
    */
    break;
  case 'n':
      myRibbon.loopType = (myRibbon.loopType+1)%3;
    	soundMap.get("changeMode").start(0);
			switch(myRibbon.loopType) {
			case 0:  triggerNotification("loop_0_empty"); break;
			case 1:  triggerNotification("loop_1_loop"); break;
			case 2:  triggerNotification("loop_2_pingpong"); break;
			}
/*
    if(myRibbon.playing)
      myRibbon.stop();
    else
      myRibbon.play();
  */  
    break;
  
    
  }
}


void keyReleased() {

  // ===== 5) KEY HANDlING LIBRARY ===== 
  myPtxInter.managementKeyReleased();
  // ===== ======================= =====
  
  switch(key) {
  case 'q':
    myRibbon.moving = false;
   	soundMap.get("drop").start(0);
    break;
  case 's':
    myRibbon.speed = false;
    break;

  }
}

void mousePressed() {

  // ===== 6) MOUSE HANDLIND LIBRARY ===== 
	myPtxInter.mousePressed();
  // ===== ========================= =====
}

void mouseDragged() {

  // ===== 7) MOUSE HANDLIND LIBRARY ===== 
	myPtxInter.mouseDragged();
  // ===== ========================= =====
}

void mouseReleased() {
  
  // ===== 8) MOUSE HANDLIND LIBRARY ===== 
	myPtxInter.mouseReleased();
  // ===== ========================= =====
}

void triggerNotification(String _str) {
	strNotif = _str;
	togNotif.reset(true);     
}
