import gifAnimation.*;


// ===== 1) ROOT LIBRARY =====
boolean isScanning, isInConfig;
ptx_inter myPtxInter;
char scanKey = 'a';
// ===== =============== =====


int wFbo, hFbo, hZone, wZone, hCell, wCell;
float rMig, rZone;

cell myCell;
ribbon myRibbon;
int maxNbrCells = 12;
  
  
  
void setup() {

  // ===== 2) INIT LIBRARY =====  
  isScanning = false;
  isInConfig = false;
  myPtxInter = new ptx_inter(this);
  // ===== =============== =====


  fullScreen(P3D, 2);
  //size(1300, 900, P3D);
  noCursor();

  myCell = new cell();
  myRibbon = new ribbon(this);
    
  
  // Geometry of the UI
  wFbo = myPtxInter.wFrameFbo;
  hFbo = myPtxInter.hFrameFbo;
  
  rMig = 0.15;
  
  hZone = int((1-rMig) * hFbo);
  wZone = wFbo / 2;
  rZone = wZone * (1.0 / hZone);
  
  hCell = int(rMig * hFbo);
  wCell = int(hCell * rZone);
  
}

void draw() {

  // ===== 3) SCANNING & CONFIG DRAW LIBRARY =====  
  if (isScanning) {
    background(0);
    myPtxInter.generalRender(); 

    if(!myPtxInter.withFlash) {
      myPtxInter.myCam.update();
      myPtxInter.scanCam();
      if (myPtxInter.myGlobState != globState.CAMERA) {
        myPtxInter.scanClr();
        atScan();
      }
      myPtxInter.whiteCtp = 0;
      isScanning = false;
    
    } else { // WITH FLASH

      if (myPtxInter.whiteCtp > 15 && myPtxInter.whiteCtp < 30)
        myPtxInter.myCam.update();

      if (myPtxInter.whiteCtp > 35) {
        myPtxInter.myCam.update();
        myPtxInter.scanCam();
        
        if (myPtxInter.myGlobState != globState.CAMERA) {
          myPtxInter.scanClr();
          atScan();
        }

        myPtxInter.whiteCtp = 0;
        isScanning = false;
      }
    }
    
    return;
  }

  if (isInConfig) {
    background(0);
    myPtxInter.generalRender();
    return;
  }
  // ===== ================================= =====  



  // Your drawing start here


  // Keep this part of the code to reset drawing
  background(0);
  myPtxInter.mFbo.beginDraw();

  // Draw here with "myPtxInter.mFbo" before call to classic drawing functions 

  myPtxInter.mFbo.background(0);
  
  myCell.draw();

  myRibbon.update();  
  myRibbon.draw();
  
  // UI
  myRibbon.drawUI();


  // Keep this part of the code to reset drawing
  myPtxInter.mFbo.endDraw();
  myPtxInter.displayFBO();

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

  // Forbid any change it you're in the middle of scanning
  if (isScanning) {
    return;
  }

  myPtxInter.managementKeyPressed();

  if (isInConfig) {
    myPtxInter.keyPressed();
    return;
  }

   
  // Master key #2 / 2, that launch the scanning process
  if (key == scanKey && !isScanning) {
    myPtxInter.whiteCtp = 0;
    isScanning = true;
    return;
  }

  // ===== ================================= =====    


  switch(key) {
  case 'q':
    myRibbon.moving = true;
    break;
  case 's':
    myRibbon.speed = true;
    break;
    
    
  case ' ':
    myRibbon.addCell( myCell );
    break;
  case 'd':
    myRibbon.delCurrentCell();
    break;
  case 'f':
    myRibbon.clear();
    break;
  case 'g':
    myRibbon.exportGIF("test", this);
  case 'h':
    myRibbon.exportPNG("test");
    break;
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
    }
    
    if(myRibbon.index != -1) {
      myRibbon.prevIndex = myRibbon.index;
      myRibbon.index = -1;
    }
    break;
  case 'n':
    if(myRibbon.playing)
      myRibbon.stop();
    else
      myRibbon.play();
    break;
  
    
  }
}

void keyReleased() {

  // ===== 5) KEY HANDlING LIBRARY ===== 

  if (isScanning || isInConfig) {
    return;
  }
  // ===== ======================= =====
  
  switch(key) {
  case 'q':
    myRibbon.moving = false;
    break;
  case 's':
    myRibbon.speed = false;
    break;

  }
}


void mousePressed() {

  // ===== 6) MOUSE HANDLIND LIBRARY ===== 

  if (isInConfig && myPtxInter.myGlobState == globState.CAMERA  && myPtxInter.myCamState == cameraState.CAMERA_WHOLE && mouseButton == LEFT) {

    // Select one "dot" of ROI if close enough
    myPtxInter.myCam.dotIndex = -1;
    for(int i = 0; i < 4; ++i) {
      if( (myPtxInter.myCam.ROI[i].subTo( new vec2f(mouseX, mouseY) ).length()) < 50 ) {
        myPtxInter.myCam.dotIndex = i;
      }
      
    }
  }

  // ===== ========================= =====
}

void mouseDragged() {

  // ===== 7) MOUSE HANDLIND LIBRARY ===== 
  
    if (isInConfig && myPtxInter.myGlobState == globState.CAMERA) {
       if (myPtxInter.myCam.dotIndex != -1) {
         myPtxInter.myCam.ROI[myPtxInter.myCam.dotIndex].addMe( new vec2f(mouseX-pmouseX, mouseY - pmouseY) ); 
       }
    }

  // ===== ========================= =====
}

void mouseReleased() {
  
  if (isInConfig && myPtxInter.myGlobState == globState.CAMERA  && myPtxInter.myCamState == cameraState.CAMERA_WHOLE)
       if (myPtxInter.myCam.dotIndex != -1) {
         myPtxInter.calculateHomographyMatrice(myPtxInter.wFrameFbo, myPtxInter.hFrameFbo, myPtxInter.myCam.ROI);
         myPtxInter.scanCam();
       }
       
}
