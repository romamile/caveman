
class areaCore {
  area myArea;
  ptx_color c;
  PShape s;
  vec2i center;
  
  areaCore(area _area) {

    myArea = new area(_area);
    center = myArea.center;
    createPShape();
 }
 
 
  areaCore(areaCore _areaCore) {

    myArea = new area(_areaCore.myArea);
    center = _areaCore.center;
    createPShape();
 }
 
 void reset() {
   
 }
 
 
 void draw() {
   
    s.setFill(color(c.r*255, c.g*255, c.b*255, 255) );
    myPtxInter.mFbo.pushMatrix();
    myPtxInter.mFbo.translate(center.x, center.y, 0);
    myPtxInter.mFbo.shape(s);
    myPtxInter.mFbo.popMatrix();
      
 }
 
 void drawIn(PGraphics _here) {
   
    _here.beginDraw();
    _here.translate(center.x, center.y);
    s.setFill(color(c.r*255, c.g*255, c.b*255, 255) );
    _here.shape(s);
    _here.endDraw();
    
      
 }
  void drawMig(int i) {
   
    s.setFill(color(c.r*255, c.g*255, c.b*255, 255) );
    myPtxInter.mFbo.pushMatrix();
    myPtxInter.mFbo.translate( (i) * wCell + center.x*rMig/rZone, center.y*rMig/rZone, 0);
    myPtxInter.mFbo.scale(rMig/rZone);
    myPtxInter.mFbo.shape(s);
    myPtxInter.mFbo.popMatrix();
      
 }

  public void createPShape() {
    c = new ptx_color();
    c.fromHSV(myArea.hue, 1, 1);
        
    s = createShape();
    if(myArea.listContour.size() == 0)
      return;
      
    s.beginShape();
    s.noStroke();

    // 1) Exterior part of shape, clockwise winding
    for (vec2i itPos : myArea.listContour.get(0))
      s.vertex(itPos.x - center.x, itPos.y - center.y);
  
      // 2) Interior part of shape, counter-clockwise winding
      for (int i = 1; i < myArea.listContour.size(); ++i) {
        s.beginContour();
        
        //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
        //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
        //}
        for (vec2i itPos : myArea.listContour.get(i))
          s.vertex(itPos.x - center.x, itPos.y - center.y );
        s.endContour();
      }
  
    s.endShape(); 
  }
  
  
}
