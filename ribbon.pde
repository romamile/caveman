

class ribbon {
  
  int index = -1;
  toggle tick;
  boolean loop = true, playing = false;
  
  ArrayList< ArrayList<areaCore> > listCell;
 
  ribbon() {
    tick = new toggle();
    tick.setSpanMs(100);
    tick.reset(false);
    
    listCell = new ArrayList< ArrayList<areaCore> >();
  }
 
  void addCell( ArrayList<areaCore> _cell ) {
    ArrayList<areaCore> tmp = new ArrayList<areaCore>();
    for(areaCore itAreaCore : _cell)
      tmp.add( new areaCore(itAreaCore) );

    listCell.add( tmp );
  }
  
  void delCurrentCell() {
    if(index != -1)
      listCell.remove(index);
      
      if(index > listCell.size() -1)
        index = listCell.size() -1;
  }
  
  void indexUp() {
    
    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + 1) % (listCell.size());
    
  }
  void indexDown() {
    
    if(listCell.size() == 0) {
      index = -1;
      return;
    }
    
    if(listCell.size() == 1) {
      index = 0;
      return;
    }
    
    index = (index + listCell.size() -1) % (listCell.size());
    
  }
 
  void play() {
    if(index != -1)  
      if(tick.getState()) {
        tick.reset(false);
        indexUp();
      }
  }
  
  void draw() {
   
    // All list cells
    for(int i = 0; i < listCell.size(); ++i) {
      for(areaCore itAreaCore : listCell.get(i) )
        itAreaCore.drawMig(i);
    }
    
    // Rez
    if(index != -1)
      for(areaCore itAreaCore : listCell.get(index) )
        itAreaCore.drawRez();
  }
  
  
  void drawUI() {
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
