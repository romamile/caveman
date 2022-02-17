import processing.svg.*;

PImage title;

class ribbon {
  
  int index = -1;
  int prevIndex = -1;
  int indexRez = -1;
  
  float tms;
  int sampling;
  
  toggle tick;
  boolean loop = true, playing = true, moving = false, speed = false;
   
  ArrayList< cell > listCell;
 
  ribbon() {
    tms = 300;
    sampling = 6;
    tick = new toggle();
    tick.setSpanMs(floor(tms));
    tick.reset(false);
    
    listCell = new ArrayList< cell >();
    title = loadImage("./data/caveman-titre.png");
    
  }
  
  void exportPNG(String _baseName) {
    for(int i = 0; i<listCell.size(); ++i)
      listCell.get(i).img.save("./rez/" + _baseName + i + ".png");
  }
  
  void exportGIF(String _baseName, PApplet _parent) {
    
    String rezPath = sketchPath() + "/rez";   
    int tmpId = floor(random(1000000));
    

    println("rm -rf "+rezPath+"/tmp/*.png");
    println(exe("rm -rf "+rezPath+"/tmp/*.png"));
    
    // 1) export all png
   for(int i = 0; i<listCell.size(); ++i)
      listCell.get(i).img.save("./rez/tmp/" + tmpId + "_" + _baseName + i + ".png");
    
    
    // 2) Imagemagik to convert to GIF  
   
      // 2.0) clean all tmp image in case
    
       // 2.1) check for size.... (TODO)

    String mess = exe("convert -size 1080x1080 -delay 34 -loop 0 -dispose 2 "+rezPath+"/tmp/"+tmpId+"*.png "+rezPath+"/output.gif");
    println(mess);
    
    //3) delete the pictures in tmp
    exe("rm -rf "+rezPath+"/tmp/*.png");
    
  }
  
  void exportSVG(String _baseName) {
    
    for(int ii = 0; ii<listCell.size(); ++ii) {
        
      int ref = 0;
      PGraphics svg = createGraphics(wZone, hZone, SVG, "./rez/" + _baseName + ii + ".svg");
      svg.beginDraw();
      svg.noStroke();
      
      for(areaCore refA : listCell.get(ii).listAreaCore) {
        
        if(refA.myArea.listContour.size() == 0)
          return;
          
        svg.fill(refA.c.r*255, refA.c.g*255, refA.c.b*255);
            
             
        svg.beginShape();
  
        // 1) Exterior part of shape, clockwise winding
        for (vec2i itPos : refA.myArea.listContour.get(0)) {
          if(ref%sampling==0)
            svg.vertex(itPos.x, itPos.y);
          ref++;
        }
        svg.vertex(refA.myArea.listContour.get(0).get(0).x, refA.myArea.listContour.get(0).get(0).y);
      
          // 2) Interior part of shape, counter-clockwise winding
          for (int i = 1; i < refA.myArea.listContour.size(); ++i) {
            svg.beginContour();
            
            //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
            //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
            //}
            for (vec2i itPos : refA.myArea.listContour.get(i)) {
              if(ref%sampling==0)
                svg.vertex(itPos.x, itPos.y);
              ref++;
            }
            svg.vertex(refA.myArea.listContour.get(i).get(0).x, refA.myArea.listContour.get(i).get(0).y);
            svg.endContour();
          }
      
        svg.endShape(); 
        
        
      
      }
      
  
      svg.dispose();
      svg.endDraw();
    }

  }
  
  void clear() {
    tick.setSpanMs(floor(tms));
    tick.reset(false);    
    listCell.clear();
    index = -1;
    prevIndex = -1;
    
  }
 
  void addCell( cell _cell) {
    
    prevIndex = index;
    index++;
    listCell.add( index, new cell(_cell) );
  }
  
  void delCurrentCell() {
    if(index != -1)
      listCell.remove(index);

    index--;
    
    if(index > listCell.size() -1 || index < 0)
      index = 0;
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
  }
   
  void stop() {
    playing = false;
/*
if(prevIndex < listCell.size()) {
      index = prevIndex;
    } else {
      index = -1;
      prevIndex = -1;
    }
*/  }
  
  void update() {
    
    if(indexRez == -1  && listCell.size() > 0) {
      indexRez = 0; 
    }
    
    if(indexRez != -1 && playing && listCell.size() > 1)  
      if(tick.getState()) {
        tick.reset(false);        
         // move up
      indexRez = (indexRez + 1) % (listCell.size());
      }
  }

  void draw(float _k) {
    
    if(index > listCell.size()-1)
      index = -1;

    if(index != -1) {
    //  for(areaCore itAreaCore : listCell.get(index).listAreaCore )
    //    itAreaCore.draw(_k);

      myPtxInter.mFbo.tint(255, 64);  // Display at half opacity
      myPtxInter.mFbo.image(listCell.get(index).img, 0, 0);
      myPtxInter.mFbo.tint(255, 255);    
    }
  }
  
  void drawRez() {
        
    if(indexRez > listCell.size()-1)
      indexRez = -1;

    myPtxInter.mFbo.pushMatrix();
    myPtxInter.mFbo.translate(wFbo/2, 0);
    if(indexRez != -1)
      for(areaCore itAreaCore : listCell.get(indexRez).listAreaCore )
        itAreaCore.draw();
    myPtxInter.mFbo.popMatrix();
  }
  
  
  void drawUI() {
    
    // 1) TITLE
    if(listCell.size() == 0)
      myPtxInter.mFbo.image(title, 10, 0, 0.9*hFbo*rMig *title.width/title.height ,0.9*hFbo*rMig);
    
    
    if(listCell.size() > 7) {
      scroll =  wCell * (index-7);
    } else {
      scroll = 0; 
    }

    myPtxInter.mFbo.translate(-scroll,0);    

    // 2) Mignatures
    for(int i = 0; i < listCell.size(); ++i) {
      for(areaCore itAreaCore : listCell.get(i).listAreaCore )
        itAreaCore.drawMig(i);
    }
    
    myPtxInter.mFbo.noFill();
    myPtxInter.mFbo.stroke(14, 22, 128);
    
    
    myPtxInter.mFbo.strokeWeight(2);
    myPtxInter.mFbo.beginShape(LINES);
  
    myPtxInter.mFbo.vertex(0 * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex(0 * wCell, 0);
      
    for(int i = 0; i < listCell.size(); ++i) {
      myPtxInter.mFbo.vertex((i+1) * wCell, hFbo*rMig);
      myPtxInter.mFbo.vertex((i+1) * wCell, 0);
    }
   
    myPtxInter.mFbo.noFill();
    myPtxInter.mFbo.stroke(14, 22, 128);
    
      // TOP LINE
    myPtxInter.mFbo.vertex(0 * wCell, 0);
    myPtxInter.mFbo.vertex(listCell.size() * wCell, 0);

      // BOTTOM LINE
    myPtxInter.mFbo.vertex(0 * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex(listCell.size() * wCell, hFbo*rMig);
           
    myPtxInter.mFbo.stroke(28, 44, 255);


   // The stylus
    myPtxInter.mFbo.vertex((index  ) * wCell, 0);
    myPtxInter.mFbo.vertex((index+1) * wCell, 0);
    
    myPtxInter.mFbo.vertex((index  ) * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex((index+1) * wCell, hFbo*rMig);
    
    myPtxInter.mFbo.vertex((index  ) * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex((index  ) * wCell, 0);
    
    myPtxInter.mFbo.strokeWeight(4);
    myPtxInter.mFbo.vertex((index+1) * wCell, hFbo*rMig);
    myPtxInter.mFbo.vertex((index+1) * wCell, 0);
       
    myPtxInter.mFbo.endShape();

      // Numbers
    for(int i = 0; i < listCell.size(); ++i) {      
      if(listCell.size() > 7) {
        myPtxInter.mFbo.textSize(15);
        myPtxInter.mFbo.fill(28, 44, 255);
        myPtxInter.mFbo.text(i, i * wCell + 4, 18);
      }
    }

    
    myPtxInter.mFbo.translate(scroll,0);
    
    myPtxInter.mFbo.stroke(14, 22, 128);
    myPtxInter.mFbo.strokeWeight(2);    
 
    myPtxInter.mFbo.beginShape(LINES);
  
      myPtxInter.mFbo.vertex(0, hFbo*rMig);
      myPtxInter.mFbo.vertex(wFbo*0.5, hFbo*rMig);
      myPtxInter.mFbo.vertex(wFbo*0.5, hFbo*rMig);
      myPtxInter.mFbo.vertex(wFbo*0.5, hFbo);
      myPtxInter.mFbo.vertex(wFbo*0.5, hFbo);
      myPtxInter.mFbo.vertex(0, hFbo);
      myPtxInter.mFbo.vertex(0, hFbo);
      myPtxInter.mFbo.vertex(0, hFbo*rMig);
      
    myPtxInter.mFbo.endShape();
    
  }
  
  
  String exe(String cmd) {
    String returnedValues = "";
    String rezStr = "";

    try {
      File workingDir = new File("./");  
      Process p = Runtime.getRuntime().exec(cmd, null, workingDir);

      // variable to check if we've received confirmation of the command
      int i = p.waitFor();

      // if we have an output, print to screen
      if (i == 0) {

        // BufferedReader used to get values back from the command
        BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));

        // read the output from the command
        while ( (returnedValues = stdInput.readLine ()) != null) {
          if (rezStr.equals(""))
            rezStr=returnedValues;
          //println("out/ "+ returnedValues);
        }
      }

      // if there are any error messages but we can still get an output, they print here
      else {
        BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));

        // if something is returned (ie: not null) print the result
        while ( (returnedValues = stdErr.readLine ()) != null) {
          if (rezStr.equals(""))
            rezStr=returnedValues;            
          //println("err/ "+returnedValues);
        }
      }
    }

    // if there is an error, let us know
    catch (Exception e) {
      println("Error running command!");  
      println(e);
    } 

    return rezStr;
  }
  
}
