class cell {
  
  ArrayList<areaCore> listAreaCore;
  PGraphics img;
  
  cell() {
     listAreaCore = new ArrayList<areaCore>();
     img = createGraphics(wFbo, hFbo);
  }
  
  cell(ArrayList<areaCore> _listAreaCore, PGraphics _img) {
    listAreaCore = new ArrayList<areaCore>();
    for(areaCore itAreaCore : _listAreaCore)
      listAreaCore.add( new areaCore(itAreaCore) );  

    img = createGraphics(wFbo, hFbo);
    img.beginDraw();
    img.image(_img, 0, 0);
    img.endDraw();
  }
  
  cell(cell _cell) {
    img = createGraphics(wFbo, hFbo);
    img.beginDraw();
    img.image(_cell.img, 0, 0);
    img.endDraw();
    listAreaCore = new ArrayList<areaCore>();
    for(areaCore itAreaCore : _cell.listAreaCore)
      listAreaCore.add( new areaCore(itAreaCore) );  
      
 }
 
 void clear() {
     listAreaCore.clear();
     img = createGraphics(wFbo, hFbo);
 }
 
  void draw() { 
    for(areaCore ref : listAreaCore) {
      ref.draw();
    }
 }

 
}
