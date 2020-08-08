
// ===== 1) ROOT LIBRARY =====
boolean isScanning, isInConfig;
ptx_inter myPtxInter;
char scanKey = 'a';
// ===== =============== =====


int wFbo, hFbo, hZone, wZone, hCell, wCell;
float rMig, rZone;

ArrayList<areaCore> listArea;
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

  listArea = new ArrayList<areaCore>();

  myRibbon = new ribbon();
  
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
  
  for(areaCore refAreaCore : listArea) {
    refAreaCore.draw();
  }

  if(myRibbon.playing)
    myRibbon.play();
    
  myRibbon.draw();
  
  // UI
  myPtxInter.mFbo.fill(255);
  myPtxInter.mFbo.stroke(255);


  myPtxInter.mFbo.stroke(255);
  myPtxInter.mFbo.strokeWeight(2);
  myPtxInter.mFbo.beginShape(LINES);

  //Bords
  myPtxInter.mFbo.vertex(0, hFbo-1); 
  myPtxInter.mFbo.vertex(wFbo-1, hFbo-1);

  myPtxInter.mFbo.vertex(0, 0);
  myPtxInter.mFbo.vertex(wFbo-1, 0);

  myPtxInter.mFbo.vertex(0, 0);
  myPtxInter.mFbo.vertex(0, hFbo-1);

  myPtxInter.mFbo.vertex(wFbo-1, 0);
  myPtxInter.mFbo.vertex(wFbo-1, hFbo-1);

  // Separations
  myPtxInter.mFbo.vertex(wFbo/2, hFbo*rMig);
  myPtxInter.mFbo.vertex(wFbo/2, hFbo-1);

  myPtxInter.mFbo.vertex(0, hFbo*rMig);
  myPtxInter.mFbo.vertex(wFbo, hFbo*rMig);
  
  // list of cells
  for(int i = 0; i<maxNbrCells; ++i) {
    
  myPtxInter.mFbo.vertex(i * wCell, hFbo*rMig);
  myPtxInter.mFbo.vertex(i * wCell, 0);
  }

  myPtxInter.mFbo.endShape();


  myRibbon.drawUI();


  // Keep this part of the code to reset drawing
  myPtxInter.mFbo.endDraw();
  myPtxInter.displayFBO();

}



// Function that is triggered at the end of a scan operation
// Use it to update what is meant to be done once you have "new areas"

void atScan() {
  
  // Check if zones are inside the draw area
  
  listArea.clear();
  
  boolean okToAdd = false;
  
  for (area itArea : myPtxInter.myPtx.listArea) {
    okToAdd = true;
    
    for(vec2i itDot : itArea.listContour.get(0)) {
      if( itDot.x > wFbo/2 || itDot.y < hFbo * rMig) {
        okToAdd = false;
        break;
      }
    }
    
    if(okToAdd)
      listArea.add( new areaCore( itArea ) );
  }
  
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
  case ' ':
    myRibbon.addCell(listArea);
    break;
  case 'd':
    myRibbon.delCurrentCell();
    break;
  case 'v':
    myRibbon.indexUp();
    break;
  case 'c':
    myRibbon.indexDown();
    break;
  case 'b':
    myRibbon.index = -1;
    break;
  case 'n':
    myRibbon.playing = !myRibbon.playing;
    if(myRibbon.playing)
      if(myRibbon.listCell.size() > 0)
        myRibbon.index = 0;
    break;
  
    
  }
}

void keyReleased() {

  // ===== 5) KEY HANDlING LIBRARY ===== 

  if (isScanning || isInConfig) {
    return;
  }
  // ===== ======================= =====
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
