class cell {
  
  ArrayList<areaCore> listAreaCore;
  PImage img;
  
  cell() {
     listAreaCore = new ArrayList<areaCore>();
     img = new PImage();
  }
  
  cell(ArrayList<areaCore> _listAreaCore, PImage _img) {
     listAreaCore = new ArrayList<areaCore>();
     img = _img.get();
  }
  
  cell(cell _cell) {
    img = _cell.img.get();
    listAreaCore = new ArrayList<areaCore>();
    for(areaCore itAreaCore : _cell.listAreaCore)
      listAreaCore.add( new areaCore(itAreaCore) );  
      
 }
 
 void clear() {
     listAreaCore.clear();
     img = new PImage();
 }
 
  void draw() { 
    for(areaCore ref : listAreaCore) {
      ref.draw();
    }
 }

 
}
