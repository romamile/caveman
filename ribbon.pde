

class ribbon {
  
  int index = -1;
  int prevIndex = -1;
  float tms;
  
  toggle tick;
  boolean loop = true, playing = false, moving = false, speed = false;
 
  GifMaker gifExport;
  
  ArrayList< cell > listCell;
 
  ribbon(PApplet _parent) {
    tms = 300;
    tick = new toggle();
    tick.setSpanMs(floor(tms));
    tick.reset(false);
    
    listCell = new ArrayList< cell >();
    
  }
  
  void exportPNG(String _baseName) {
    for(int i = 0; i<listCell.size(); ++i)
      listCell.get(i).img.save(_baseName + i + ".png");
  }
  
  void exportGIF(String _baseName, PApplet _parent) {
    
    gifExport = new GifMaker(_parent, _baseName + ".gif");
    gifExport.setRepeat(0);        // make it an "endless" animation
    gifExport.setTransparent(0,0,0);
    
    
    for(cell ref : listCell) {
      gifExport.setDelay(floor(tms));
      gifExport.addFrame(ref.img);
    }
  
    gifExport.finish();  

  }
  
  void clear() {
    tick.setSpanMs(floor(tms));
    tick.reset(false);    
    listCell.clear();
  }
 
  void addCell( cell _cell ) {
    listCell.add( new cell(_cell) );
  }
  
  void delCurrentCell() {
    if(index != -1)
      listCell.remove(index);
      
      if(index > listCell.size() -1)
        index = listCell.size() -1;
  }
  
  void timeUp() {
    tms /= 1.1;
    tick.setSpanMs(floor(tms));
  }
  
  void timeDown() {
    tms *= 1.1;    
    tick.setSpanMs(floor(tms));
  }
    
  void moveUp() {
    if(index != -1 && index + 1 < listCell.size()) {
      Collections.swap(listCell, index, index+1); 
    }
    indexUp();
  }
  
  void moveDown() {
    if(index != -1 && index > 0 && listCell.size() > 1) {
      Collections.swap(listCell, index, index-1); 
    }
    indexDown();
  }
  
  void indexUp() {
    int locPrevIndex = index;
    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + 1) % (listCell.size());
    
    if(index != locPrevIndex)
      prevIndex = locPrevIndex;
  }
  
  
  void indexDown() {
    int locPrevIndex = index;

    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + listCell.size() -1) % (listCell.size());
    if(index != locPrevIndex)
      prevIndex = locPrevIndex;
  }
 
  void play() {
    playing = true;
    if(index != -1)  
      if(tick.getState()) {
        tick.reset(false);
        indexUp();
      }
  }
   
  void stop() {
    playing = false;
    if(prevIndex < listCell.size()) {
      index = prevIndex;
    } else {
      index = -1;
      prevIndex = -1;
    }
  }
  
  void update() {
    
    if(index != -1 && playing && listCell.size() > 1)  
      if(tick.getState()) {
        tick.reset(false);        
         // move up
      index = (index + 1) % (listCell.size());
      }
  }
  
  void draw() {
    
    if(index > listCell.size())
      index = -1;
   
    // All list cells
    for(int i = 0; i < listCell.size(); ++i) {
      for(areaCore itAreaCore : listCell.get(i).listAreaCore )
        itAreaCore.drawMig(i);
    }
    
    // Rez
    if(index != -1)
      for(areaCore itAreaCore : listCell.get(index).listAreaCore )
        itAreaCore.draw();
  }
  
  
  void drawUI() {
    
    myPtxInter.mFbo.fill(255);
    myPtxInter.mFbo.stroke(255);
    myPtxInter.mFbo.strokeWeight(2);
    myPtxInter.mFbo.beginShape(LINES);
  
    myPtxInter.mFbo.vertex(0, hFbo*rMig);
    myPtxInter.mFbo.vertex(wFbo, hFbo*rMig);
    
    // list of cells
    for(int i = 0; i<maxNbrCells; ++i) {
      
    myPtxInter.mFbo.vertex(i * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex(i * wCell, 0);
    }
  
    myPtxInter.mFbo.endShape();
    
    // The stylus
    if(index != -1) {
      myPtxInter.mFbo.stroke(255, 0, 0, 100);
      myPtxInter.mFbo.noFill();
      myPtxInter.mFbo.strokeWeight(2);
      myPtxInter.mFbo.beginShape();
      
      myPtxInter.mFbo.vertex((index+1) * wCell, hFbo*rMig);
      myPtxInter.mFbo.vertex((index+1) * wCell, 0);
      myPtxInter.mFbo.vertex(index * wCell, 0);
      myPtxInter.mFbo.vertex(index * wCell, hFbo*rMig);
    
      myPtxInter.mFbo.endShape(CLOSE);
    }
  }
}
