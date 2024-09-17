import processing.svg.*;

PImage title;
PImage UI_BIG;
PImage UI_mig_neutral;
PImage UI_mig_hover;
PImage UI_mig_selected;

class ribbon {
  
  int index = -1;
  int prevIndex = -1;
  int indexRez = -1;
  
  int onionNbr;
  
  float tms;
  int sampling;
  
  toggle tick;
  boolean loop = true, playing = true, moving = false, speed = false;
   
  ArrayList< cell > listCell;
  PGraphics locFbo, locFboGIF;
  int wFbo, hFbo;
  
  int loopType;
  boolean pingpong;

  String outputName = "";


  ribbon(int _wFbo, int _hFbo) {
    tms = 300;
    sampling = 4;
    tick = new toggle();
    tick.setSpanMs(floor(tms));
    tick.reset(false);
    
    listCell = new ArrayList< cell >();
    title = loadImage("./data/caveman-titre.png");
    UI_BIG = loadImage("./data/caveman_ui_big.png");
    UI_mig_neutral = loadImage("./data/caveman_ui_neutral.png");
    UI_mig_hover = loadImage("./data/caveman_ui_hover.png");
    UI_mig_selected = loadImage("./data/caveman_ui_select.png");
    
    wFbo = _wFbo;
    hFbo = _hFbo;
    locFbo = createGraphics(wFbo, hFbo);   
    locFboGIF = createGraphics(wFbo/2 -16, floor(hFbo*(1-rMig)) - 16 );

    loopType = 1;
    pingpong = false;
    onionNbr = 1;
  }

  void generateNewOutputName() {
    outputName = "output_" + nf(month(), 2) + "-" + nf(day(),2) + "_" + nf(hour(),2) + ":" + nf(minute(), 2)+ ":" + nf(second(),2);

  }


  void exportPNG(String _baseName) {
    
    for(int j = 0; j<listCell.size(); ++j) {
      locFbo.beginDraw();
      locFbo.background(0,0,0,0);
      for(areaCore itAreaCore : listCell.get(j).listAreaCore ) {
        
        //itAreaCore.s.setFill(color(itAreaCore.c.r*255, itAreaCore.c.g*255, itAreaCore.c.b*255) );
        locFbo.pushMatrix();
        locFbo.translate(itAreaCore.center.x, itAreaCore.center.y);
        //locFbo.shape(itAreaCore.s);
          int ref = 0;
              
          if(itAreaCore.myArea.listContour.size() == 0)
            return;

          ptx_color c = new ptx_color();
          c.fromHSV(itAreaCore.myArea.hue, 1, 1);

          locFbo.beginShape();
          locFbo.noStroke();
          locFbo.fill(c.r*255, c.g*255, c.b*255);
      
          // 1) Exterior part of shape, clockwise winding
          for (vec2i itPos : itAreaCore.myArea.listContour.get(0)) {
            if(ref%sampling==0)
              locFbo.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
            ref++;
          }
          locFbo.vertex(itAreaCore.myArea.listContour.get(0).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(0).get(0).y - itAreaCore.center.y);
      
          // 2) Interior part of shape, counter-clockwise winding
          for (int ii = 1; ii < itAreaCore.myArea.listContour.size(); ++ii) {
            locFbo.beginContour();
            
            //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
            //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
            //}
             ref = 0;
            for (vec2i itPos : itAreaCore.myArea.listContour.get(ii)) {
              if(ref%sampling==0)
                locFbo.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
              ref++;
            }
            locFbo.vertex(itAreaCore.myArea.listContour.get(ii).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(ii).get(0).y - itAreaCore.center.y);
            
            locFbo.endContour();
          }
      
          locFbo.endShape();
        
        
        locFbo.popMatrix(); 
  
      }
      
      locFbo.endDraw();
      locFbo.save("./rez/" + outputName + "/" + _baseName + j + ".png");

    }
    
  }
  
  void exportGIF(String _baseName, PApplet _parent) {
    
    String rezPath = sketchPath() + "/rez";   
    int idImg = 0;
    int tmpId = floor(random(1000000));

    println(exe("rm -rf ./caveman/rez/tmp"));
    println(exe("mkdir  ./caveman/rez/tmp"));

    //int offsetX = 5, offsetY = -5; 
    int offsetX = 15, offsetY = 1; 

    // 1) export all png
    for(int j = 0; j<listCell.size(); ++j) {
      idImg++;
      locFboGIF.beginDraw();
      locFboGIF.background(0,0,0,0);
      for(areaCore itAreaCore : listCell.get(j).listAreaCore ) {
        
        //itAreaCore.s.setFill(color(itAreaCore.c.r*255, itAreaCore.c.g*255, itAreaCore.c.b*255) );
        locFboGIF.pushMatrix();
        locFboGIF.translate(itAreaCore.center.x, itAreaCore.center.y);

        // offset
        locFboGIF.translate(-offsetX, -hFbo*rMig - offsetY);

        //locFbo.shape(itAreaCore.s);
          int ref = 0;
              
          if(itAreaCore.myArea.listContour.size() == 0)
            return;

          ptx_color c = new ptx_color();
          c.fromHSV(itAreaCore.myArea.hue, 1, 1);

          locFboGIF.beginShape();
          locFboGIF.noStroke();
          locFboGIF.fill(c.r*255, c.g*255, c.b*255);
      
          // 1) Exterior part of shape, clockwise winding
          for (vec2i itPos : itAreaCore.myArea.listContour.get(0)) {
            if(ref%sampling==0)
              locFboGIF.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
            ref++;
          }
          locFboGIF.vertex(itAreaCore.myArea.listContour.get(0).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(0).get(0).y - itAreaCore.center.y);
      
          // 2) Interior part of shape, counter-clockwise winding
          for (int ii = 1; ii < itAreaCore.myArea.listContour.size(); ++ii) {
            locFboGIF.beginContour();
            
            //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
            //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
            //}
             ref = 0;
            for (vec2i itPos : itAreaCore.myArea.listContour.get(ii)) {
              if(ref%sampling==0)
                locFboGIF.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
              ref++;
            }
            locFboGIF.vertex(itAreaCore.myArea.listContour.get(ii).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(ii).get(0).y - itAreaCore.center.y);
            
            locFboGIF.endContour();
          }
      
          locFboGIF.endShape();
        
        
        locFboGIF.popMatrix(); 
  
      }
      
      locFboGIF.endDraw();
      locFboGIF.save("./rez/tmp/" + tmpId + "_" + _baseName + idImg + ".png");
    
    }


    if(loopType == 2) {

      for(int j = listCell.size() - 2; j > 0;  --j) {
        idImg++;
        locFboGIF.beginDraw();
        locFboGIF.background(0,0,0,0);
        for(areaCore itAreaCore : listCell.get(j).listAreaCore ) {
          
          //itAreaCore.s.setFill(color(itAreaCore.c.r*255, itAreaCore.c.g*255, itAreaCore.c.b*255) );
          locFboGIF.pushMatrix();
          locFboGIF.translate(itAreaCore.center.x, itAreaCore.center.y);
          // offset
          locFboGIF.translate( -offsetX, -hFbo*rMig - offsetY);

          //locFbo.shape(itAreaCore.s);
            int ref = 0;
                
            if(itAreaCore.myArea.listContour.size() == 0)
              return;

            ptx_color c = new ptx_color();
            c.fromHSV(itAreaCore.myArea.hue, 1, 1);

            locFboGIF.beginShape();
            locFboGIF.noStroke();
            locFboGIF.fill(c.r*255, c.g*255, c.b*255);
        
            // 1) Exterior part of shape, clockwise winding
            for (vec2i itPos : itAreaCore.myArea.listContour.get(0)) {
              if(ref%sampling==0)
                locFboGIF.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
              ref++;
            }
            locFboGIF.vertex(itAreaCore.myArea.listContour.get(0).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(0).get(0).y - itAreaCore.center.y);
        
            // 2) Interior part of shape, counter-clockwise winding
            for (int ii = 1; ii < itAreaCore.myArea.listContour.size(); ++ii) {
              locFboGIF.beginContour();
              
              //for (int j = myArea.listContour.get(i).size() -1; j >= 0; --j) {
              //  s.vertex(myArea.listContour.get(i).get(j).x, myArea.listContour.get(i).get(j).y);
              //}
               ref = 0;
              for (vec2i itPos : itAreaCore.myArea.listContour.get(ii)) {
                if(ref%sampling==0)
                  locFboGIF.vertex(itPos.x - itAreaCore.center.x, itPos.y - itAreaCore.center.y);
                ref++;
              }
              locFboGIF.vertex(itAreaCore.myArea.listContour.get(ii).get(0).x - itAreaCore.center.x, itAreaCore.myArea.listContour.get(ii).get(0).y - itAreaCore.center.y);
              
              locFboGIF.endContour();
            }
        
            locFboGIF.endShape();
          
          
          locFboGIF.popMatrix(); 
    
        }
        
        locFboGIF.endDraw();
        locFboGIF.save("./rez/tmp/" + tmpId + "_" + _baseName + idImg + ".png");
      
      }

    }

    println( exe("convert -size " + (locFboGIF.width) + "x" + locFboGIF.height + " -delay "+ floor(tms / 10)+"  -loop 0 -dispose 2 "+rezPath+"/tmp/"+tmpId+"*.png "+rezPath+ "/" + outputName + "/output.gif") );

    
    //3) delete the pictures in tmp
    println(exe("rm -rf ./caveman/rez/tmp")); 

  }
  
  void exportSVG(String _baseName) {
    
    for(int ii = 0; ii<listCell.size(); ++ii) {
        
      int ref = 0;
      PGraphics svg = createGraphics(wFbo, hFbo, SVG, "./rez/" + outputName + "/" + _baseName + ii + ".svg");
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
    
    if(listCell.size() >= maxNbrCells) {
      return; 
    }
    
    prevIndex = index;
    index++;
    listCell.add( index, new cell(_cell) );
  }
  
  void delCurrentCell() {
    if(index != -1) {
      listCell.remove(index);
      soundMap.get("delete").start(0);
    }
    index--;
    
    if(index > listCell.size() -1 || index < 0)
      index = 0;
}
  
  void timeUp() {
    tms /= 1.1;
    tick.setSpanMs(floor(tms));
    soundMap.get("speed").start(0);
  }
  
  void timeDown() {
    tms *= 1.1;    
    tick.setSpanMs(floor(tms));
    soundMap.get("speed").start(0);
  }
    
  void moveUp() {
    if(index != -1 && index + 1 < listCell.size()) {
      Collections.swap(listCell, index, index+1); 
    }
    indexUp();
    if(index != -1)
      soundMap.get("right").start(0);

  }
  
  void moveDown() {
    if(index != -1 && index > 0 && listCell.size() > 1) {
      Collections.swap(listCell, index, index-1); 
    }
    indexDown();
    
    if(index != -1)
      soundMap.get("left").start(0);

  }
  
  void indexUp() {
    
    if(index != -1)
      soundMap.get("right").start(0);
    
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
    if(index != -1)
      soundMap.get("left").start(0);

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
        
        switch(loopType) {
        case 0: return;
        case 1: // forward
          indexRez = (indexRez + 1) % (listCell.size());
          break;
        case 2: // ping-pong
          if( (pingpong && indexRez + 1 >= listCell.size()) || (!pingpong && indexRez - 1 < 0) )
            pingpong = !pingpong;
          indexRez = pingpong ? indexRez + 1 : indexRez - 1;
          break;
        }
      }
  }

  void draw(float _k) {
    
    if(index > listCell.size()-1)
      index = -1;

    if(index != -1) {
    //  for(areaCore itAreaCore : listCell.get(index).listAreaCore )
    //    itAreaCore.draw(_k);


      // RIBBON
      switch(onionNbr) {
      case 1: 
        for(areaCore itAreaCore : listCell.get(index).listAreaCore )
          itAreaCore.draw(128.0/(255));
        break;
      case 2:
        for(areaCore itAreaCore : listCell.get(index).listAreaCore )
          itAreaCore.draw(128.0/255);

        for(areaCore itAreaCore : listCell.get( (index+1)%listCell.size()  ).listAreaCore )
          itAreaCore.draw(64.0/255);

        break;

      }
/*
      for(int oIndex = index - onionNbr + 1; oIndex <= index - 1 + onionNbr ; ++oIndex) {
        if(oIndex > listCell.size()-1 || oIndex < 0)
          continue;
          
        int k = abs(index - oIndex) + 1;
        for(areaCore itAreaCore : listCell.get(oIndex).listAreaCore )
          itAreaCore.draw(64.0/(255*k));

      }
*/
    }
  }
  
  void drawRez() {

    if(loopType == 0) {
      return;
    }
        
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
    
    // A) TITLE
    if(listCell.size() == 0)
      myPtxInter.mFbo.image(title, 10, 0, 0.9*hFbo*rMig *title.width/title.height ,0.9*hFbo*rMig);
    
    /*
    if(listCell.size() > 7) {
// No more scrolling for now
//      scroll =  wCell * (index-7);
    } else {
      scroll = 0; 
    }

    myPtxInter.mFbo.translate(-scroll,0);    
*/

    // C] Big UI window
    int offsetX = 5, offsetY = -0; 
    myPtxInter.mFbo.image(UI_BIG, 0 + offsetX, hFbo*rMig + offsetY, wFbo/2, hFbo*(1-rMig));

    // B) Mignatures
    myPtxInter.mFbo.translate(5, 0);
    for(int i = 0; i < listCell.size(); ++i) {
      for(areaCore itAreaCore : listCell.get(i).listAreaCore ) {
        // B.1) Picture of the drawing
        myPtxInter.mFbo.push();
        if(i == index && moving)
          myPtxInter.mFbo.translate(5, -10);
        itAreaCore.drawMig(i);
        myPtxInter.mFbo.pop();
      }
    
        // B.2) Vignette autour (depending on state)
      if(i == index) {
        if(moving) {
          myPtxInter.mFbo.image(UI_mig_selected, i * wCell, 0, wCell, hCell);      
        } else {
          myPtxInter.mFbo.image(UI_mig_hover, i * wCell, 0, wCell, hCell);
        }
      } else {
        myPtxInter.mFbo.image(UI_mig_neutral, i * wCell, 0, wCell, hCell);
      }
      
        // B.3) Number in the mig
/*
      myPtxInter.mFbo.textSize(15);
      myPtxInter.mFbo.fill(28, 44, 255);
      myPtxInter.mFbo.text(i+1, i * wCell + 10, 20);
*/
    }
    
//    myPtxInter.mFbo.translate(scroll,0);
    
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
