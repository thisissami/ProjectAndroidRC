/* @pjs preload="/miniNYC.png,/logosign";*/

// © 2012 Sami Majadla and Rapcities Inc. All Rights Reserved

//the above code is used by processingjs to preload images

PFont font;
HashMap longText; //used for long text
Current current; //used to display current song info and controls
SidePane sidePane; //displays the sidepane
Map nyc;
var mapname = 'Kanye';

var grid,gridLoad; // used to hold grid of images and loading info

//positions of different sections of the screen
int WIDTH,HEIGHT;
int xgrid,ygrid;
int MINIMAXY; 
var curehovertype = 0;
int xlength, ylength, miniRedX,miniRedY;

void setup(){
	WIDTH = max(700,$(window).width());// set width
	HEIGHT = max(770,$(window).height());// set height
	logo = loadImage("/logosign"); //logo displayed in top left corner of site
	$("#parent").css("width",WIDTH).css("height",HEIGHT);
	if(WIDTH == 700 || HEIGHT == 770){
		$("body").css("overflow","visible"); //make site scrollable if at minimum resolution
	}
	SPLdistanceX = 20; //distance of sidepane from right of app
	SPLdistanceY = 30; //distance of sidepane from top of app
	ygrid = 5000; //total size of pixels in map height
	xgrid = 5000;//total size of pixels in map width
	togglePlayer(); //enable youtube player
	recentlyPlayed = new ArrayList(); //recently played videos
	vidsToShow = 10; //how many videos to display by default in a list in a given page
	size(WIDTH, HEIGHT);
	frameRate(30);
	rectMode(CORNERS);
	ellipseMode(CENTER_RADIUS);
	font = createFont("Arial", 13);
	textFont(font);
	colorMode(RGB);
	
	longText = new HashMap();
	sidePane = new SidePane(WIDTH-SPLdistanceX-284,SPLdistanceY); //info about + control for current location
	current = new Current(); //video playback controller (for current video only)
	nyc = new Map(); //object dealing with functions related to the map
	nyc.setUpLocations(); //get all the locations to draw in the map
	grid = new Array(4); //regular 2D array of images to be
	gridLoad = new Array(4);
	for(int i = 0; i < 4; i++){ // prep the 2D arrays holding the map images
		grid[i] = new Array(4);
		gridLoad[i] = new Array(4);
		for(int j = 0; j < 4; j++){
			gridLoad[i][j] = false;
		}
	}
}

/* this function runs every time the browser window is resized. 
it sets different variables related to positioning to their correct new positions so that
everything in the app is still displayed properly without issue.*/
void setUpSize(width,height){
	if(width != WIDTH || height != HEIGHT){
		WIDTH = width;
		HEIGHT = height;
		$("#parent").css("width",width).css("height",height);
		size(WIDTH,HEIGHT); //
		xlength = WIDTH; //width of map dislayed on page with
		ylength = HEIGHT; //height of map displayed on page
		PANEMINX = WIDTH-SPLdistanceX-284;
		PANEMAXX = WIDTH-SPLdistanceX;
		if(HEIGHT < 870){ //if the height of the canvas is less than 870, shorten the video list display
			int x = 870;
			int i = 0;
			while(x>HEIGHT && i < 5){
				x -= 22;
				i++;
			}
			PANEMAXY = PANEMINY + 558 -57- i*22;
			MINIMAXY = PANEMAXY + 270;
			vidsToShow = 10-i;
			yloc = PANEMAXY-18;
			$('#dialogWindow').css('top',353-i*22-57);
		}else{
			PANEMAXY = PANEMINY + 558-57;
			MINIMAXY = PANEMAXY + 270;
			vidsToShow = 10;
			yloc = PANEMAXY-18;
			$('#dialogWindow').css('top',353-57);
		}
		sidePane.resetSize(); 
		miniRedX = map(xlength,0,xgrid,0,284);
		miniRedY = map(ylength,0,ygrid,0,270);
		nyc.setMins();
		volX = PANEMINX+40;
		
	    current.play.newPos(PANEMINX+72, yloc);
	    current.ffwd.newPos(PANEMAXX-20, yloc);
		seekLeft = PANEMINX+95;
		volX = PANEMINX+40;
		seekRight = PANEMAXX - 40 - timeDisplacement;
	
		curLeft = PANEMINX; curRight = PANEMAXX; curTop = PANEMAXY - 230; curBottom = PANEMAXY;
	}
}

//draw all the various things that get displayed in the app
void draw(){
	nyc.draw();
	imageMode(CORNER);
	image(logo,10,0);//,logo.width,logo.height);
	if(curLoc > -1)//draw currently playing location
		nyc.drawCurrentInfo();
	if(hoverLoc > -1)
		nyc.drawHoverInfo();
	sidePane.draw();// draw the sidepane!
//	if(location)  
	current.draw();
	nyc.drawMini();	
}

var curVid = -1; //currently hovered over video in a list of videos in sidePane
var hoverLoc = -1; //currently hovered over loc in the map

//function that runs when mouse is clicked (as in released immediately after being pressed)
void mouseClicked(){
	if(hoverLoc >= 0){
		location = locations.get(hoverLoc);
		playingVideo = 0;
		sidePane.resetSize(); 
		sidePane.resetPage();
		loadVideo();
	}
	else if(curVid >= 0){
		playingVideo = curVid;
		loadVideo();
	}
	else if(forwardPageHover){
		sidePane.nextPage();
	}
	else if(backPageHover){
		sidePane.previousPage();
	}
}	

//function that's called when mouse is pressed (regardless of whether or not it's let go)
void mousePressed(){
  if(mouseY < curBottom && mouseY > curTop && mouseX < curRight && mouseX > curLeft){
    current.mousePressed();
  }
  else if(mouseX > PANEMINX && mouseX < PANEMAXX && mouseY > PANEMINY && mouseY < MINIMAXY){
	if(mouseY < PANEMAXY)
    	sidePane.mousePressed();
 	else
		nyc.miniMousePressed();
  }
  else
	nyc.mousePressed();
}

//function called when mouse is moved while button is clicked
void mouseDragged(){
  current.mouseDragged();
  nyc.mouseDragged();
  nyc.miniMouseDragged();
}
//function that's called when mouse leaves scope of canvas
void mouseOut(){
	nyc.mouseOut();
	current.mouseReleased();
}
//function that's called when a pressed mouse button is released
void mouseReleased(){
  current.mouseReleased();
  nyc.mouseReleased();
  nyc.miniMouseReleased();
}


var location; //current location
var icons = new HashMap(); //icon images that correspond to the various types
//var media = {}; // what type of media does each type contain? (for now all youtube videos)
var colors = {}; //color of each type (as shown on minimap and as displayed in hovertext)
var locations = new ArrayList(); //list of all the locations

int minX, minY, maxX, maxY; //these are variables that set the boundaries for the currently visible scope
//in the scale used by the 
int miniMidX,miniMidY,midX,midY;
class Map{
	PImage miniNYC; //image in minimap
	int ox, oy, ocx, ocy;//respectively mouseX/Y locations and midX/Y locations when mouse pressed (to move map around)
	var widths, heights;//array of lengths of pixels of each image in the grid
	int ominx, ominy; // minX/Y locations when mouse pressed (to move map around)
	boolean opressed = false; // has the mouse been clicked in the main map to move it around?
	boolean miniPressed = false; // has the mouse been clicked in the minimap to move map around?
	Map(){
		miniNYC = loadImage("/miniNYC.png");
		ox = oy = -1;
		prep();
	}
	
	void draw(){
		drawMap();
		drawLocations();
		fill(0);
		noStroke();
		rectMode(CORNERS);
	}
	
	/*fill locations, colors, icons, etc. with all the appropriate data*/
	void setUpLocations(){ 
		$.getJSON('/loc/browse?city='+mapname+'&hasLoc=8&public=4', function(results){      
	      if(results && results.locs){
	        for(int i = 0; i < results.locs.length; i++){
	            locations.add(results.locs[i]);
			}
			rapReady++;
			if(rapReady == 3 && playerReady) startMusic();
	      }
	    });
		$.getJSON('/loc/getTypes',function(results){
			if(results && results.types){
				for(int i = 0; i < results.types.length; i++){
					icons.put(results.types[i]._id, requestImage('/loc/getTypeIcon?_id='+results.types[i]._id));
					colors[results.types[i]._id] = color(results.types[i].r, results.types[i].g, results.types[i].b);
					//media[results.types[i]._id] = results.types[i].mediaType;
				}
				rapReady++;
				if(rapReady == 3 && playerReady) startMusic();
			}
		});
	}
	
	//draw the map 
	void drawMap(){
		imageMode(CENTER); 
		var totX = 0;//widths[0];
		var totY = 0;//heights[0];
		int i;
		//figure out which image in the grid should be centered
		for(i = 0; i < 4; i++){
			totX+=widths[i];
			if(totX > midX)
					break;
		}
		int j;
		for(j = 0; j < 4; j++){
			totY += heights[j];
			if(totY > midY)
					break;
		}
		//draw said centered image
		grimage(j,i,xlength/2-(widths[i]/2-(totX-midX)),ylength/2-(heights[j]/2-(totY-midY)));
		//depending on where in the grid this image falls, draw the 3-8 images that surround it.
		if(j > 0)
			grimage(j-1,i,xlength/2-(widths[i]/2-(totX-midX)),ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(i > 0)
			grimage(j,i-1,xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,ylength/2-(heights[j]/2-(totY-midY)));
		if(j < 3)
			grimage(j+1,i,xlength/2-(widths[i]/2-(totX-midX)),ylength/2+heights[j+1]/2+(totY-midY)-1);
		if(i < 3)
			grimage(j,i+1,xlength/2+widths[i+1]/2+(totX-midX)-1,ylength/2-(heights[j]/2-(totY-midY)));
		if(j>0 && i>0)
			grimage(j-1,i-1,xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(j>0 && i<3)
			grimage(j-1,i+1,xlength/2+widths[i+1]/2+(totX-midX)-1,ylength/2-heights[j] - (heights[j-1]/2-(totY-midY))+1);
		if(j<3 && i<3)
			grimage(j+1,i+1,xlength/2+widths[i+1]/2+(totX-midX)-1,ylength/2+heights[j+1]/2+(totY-midY)-1);
		if(j<3 && i>0)
			grimage(j+1,i-1,xlength/2-widths[i]-(widths[i-1]/2-(totX-midX))+1,ylength/2+heights[j+1]/2+(totY-midY)-1);
		//println("x: "+midX+"  y: "+midY);
		//println("i: " + i + "j: " + j);*/
	}
	
	//draw the appropriate image in the appropriate location
	void grimage(int j, int i, int one, int two){
		if(grid[j][i]){
			if(grid[j][i].width>0)
				image(grid[j][i],one,two);
			else
				drawLoadingBlock(j,i,one,two);
		}
		else if(!gridLoad[j][i]){
			loadMapPiece(j,i);
			drawLoadingBlock(j,i,one,two);
		}
	}
	
	//load a standard image as part of a map grid
	void loadMapPiece(int i, int j){
		var title;
		if((i == 0) || (i == 1) || (i == 2 && j < 1)){
			title = "0";
			title += String(i*4+j+1)+"."+mapname+'.grid';
		}
		else
			title = String(i*4+j+1)+"."+mapname+'.grid';
		gridLoad[i][j] = true;
		grid[i][j] = requestImage('/'+title);
	}

	//put a placeholder "loading" if image isn't downloaded yet
	void drawLoadingBlock(int j, int i, int one, int two){
		rectMode(CENTER);noStroke();
		fill(0); rect(one, two, widths[j],heights[i]);
		textSize(30);fill(255);
		text('Loading Map Section',one, two);
	}
	//draw the minimap 
	void drawMini(){
		imageMode(CORNERS);
		image(miniNYC,PANEMINX,PANEMAXY,PANEMAXX,MINIMAXY); //daw minimap
		rectMode(CENTER);
		noFill();
		strokeWeight(1);
		stroke(color(255,0,0));
		rect(PANEMINX+miniMidX,PANEMAXY+miniMidY,miniRedX,miniRedY); //draw red square indicating current location
		ellipseMode(CENTER);
		//draw the locations within the minimap
		for(int i = 0; i < locations.size(); i++){
			var cur = locations.get(i);
			fill(colors[cur.type]); stroke(colors[cur.type]);
			if(location && cur._id == location._id)
				ellipse(map(cur.x, 531.749,531.749+853,PANEMINX,PANEMAXX),map(cur.y,231.083,231.083+810,PANEMAXY,MINIMAXY),5,5);
			else
				ellipse(map(cur.x, 531.749,531.749+853,PANEMINX,PANEMAXX),map(cur.y,231.083,231.083+810,PANEMAXY,MINIMAXY),3,3);
		}
	}
	
	void prep(){
		xlength = WIDTH;
		ylength = HEIGHT;
		miniRedX = map(xlength,0,xgrid,0,284);
		miniRedY = map(ylength,0,ygrid,0,270);
		midX = 2000; //starting location in the map
		midY = 2000; //center of map in pixel scale
		miniMidX = map(midX,0,xgrid,0,284);
		miniMidY = map(midY,0,ygrid,0,270);
		widths = new Array(1250,1250,1250,1250);
		heights = new Array(1250,1250,1250,1250);
		setMins();
	}
	//check if mouse is pressed within minimap
	void miniMousePressed(){

                // record the x & y before mouse pressed
		if(mouseX>PANEMINX && mouseY>PANEMAXY && mouseX<PANEMAXX && mouseY<MINIMAXY){
			miniPressed = true;
			miniMidX = min(max(miniRedX/2,mouseX - PANEMINX),284-miniRedX/2);
			miniMidY = min(max(miniRedY/2,mouseY - PANEMAXY),270-miniRedY/2);
			miniToMaxi();
		}
	}
	//see if mminimap is being dragged
	void miniMouseDragged(){
		if(miniPressed){
			miniMidX = min(max(miniRedX/2,mouseX - PANEMINX),284-miniRedX/2);
			miniMidY = min(max(miniRedY/2,mouseY - PANEMAXY),270-miniRedY/2);
			miniToMaxi();
		}
	}
	//convert the minimap location to regular map scale and set map to said position
	void miniToMaxi(){
		midX = map(miniMidX,0,284,0,xgrid);
		midY = map(miniMidY,0,270,0,ygrid);
		setMins();
	}
	
	void miniMouseReleased(){
		miniPressed = false;
	}
	boolean once = false;
	//move map around using arrow keys
	void keyPressed(){
		if(key == CODED){
			switch(keyCode){
				case(UP): miniMidY = max(miniMidY-1,miniRedY/2); miniToMaxi(); break;
				case(DOWN): miniMidY = min(miniMidY+1,270-miniRedY/2); miniToMaxi();break;
				case(LEFT): miniMidX = max(miniMidX-1, miniRedX/2); miniToMaxi();break;
				case(RIGHT): miniMidX = min(miniMidX+1, 284-miniRedX/2); miniToMaxi();break;
			}
		}
	}
	//make sure the location isn't hidden behind anything
	boolean mouseInFront(){
		if(mouseX < PANEMINX || mouseX > PANEMAXX || mouseY < PANEMINY || mouseY > MINIMAXY){
			return true;
		}
		return false;
	}
	//draw locations within the map
	void drawLocations(){
		imageMode(CENTER);
		hoverLoc = curLoc = -1;
		for(int i = 0; i < locations.size(); i++){
			var cur = locations.get(i);
			//if the current location we're looking at is within the currently displayed map area
			if(cur.x < maxX+10 && cur.x > minX-10 && cur.y < maxY+15 && cur.y > minY-15 && icons.get(cur.type).width > 0){
				var x = map(cur.x,minX,maxX,0,WIDTH);
				var y = map(cur.y,minY,maxY,0,HEIGHT);
				var icon = icons.get(cur.type);
				// check if current location is the currently open one
				if(location && cur._id==location._id){
					curLoc = i;
			    }
				//check if mouse is hovering over location
				else if(mouseInFront() && mouseX < x+icon.width/2 && mouseX > x-icon.width/2 && mouseY < y+icon.height/2 && mouseY > y-icon.height/2){
					hoverLoc = i;
				}
				//draw location's icon
				image(icon,x,y);
			}
		}
	}
	//draw info about location while mouse is there
	void drawHoverInfo(){
	    var loc = locations.get(hoverLoc);
	    textSize(18);
	    int xlength = textWidth(loc.title);
	    stroke(colors[loc.type]);
	    fill(0);
		rectMode(CORNERS);
	    rect(mouseX, mouseY-33,mouseX+xlength+12, mouseY-7,10);

	      fill(colors[loc.type]);
	    textAlign(LEFT,TOP);
	    text(loc.title, mouseX+6, mouseY-30);
	}
	//draw info about currently playing location
	void drawCurrentInfo(){
		var cur = locations.get(curLoc);
		textSize(18);
	    int xlength = textWidth(cur.title);
	    stroke(colors[cur.type]);
	    fill(0);
		rectMode(CENTER);
		int x = map(cur.x,minX,maxX,0,WIDTH);
		int y = map(cur.y,minY,maxY,0,HEIGHT)-(icons.get(cur.type).height/2)-20;
		strokeWeight(2);
	    rect(x,y,xlength+12, 26,10);   
		fill(colors[cur.type]);
	    textAlign(LEFT,TOP);
	    text(cur.title, x-xlength/2, y-10);
	}
	
	// if mouse pressed in map
	void mousePressed(){
		ox = mouseX;
		oy = mouseY;
		ocx = midX; //original cur
		ocy = midY;
		ominx = minX;
		ominy = minY;
		opressed = true;
	}
	// if mouse dragged in regular map
	void mouseDragged(){
		if(opressed){
			midX = ocx - (mouseX-ox);
			midY = ocy - (mouseY-oy);
			if(midX > xgrid-xlength/2)
				midX = xgrid-xlength/2;
			if(midX < xlength/2)
				midX = xlength/2;
			if(midY < ylength/2)
				midY = ylength/2;
			if(midY > ygrid - ylength/2)
				midY = ygrid - ylength/2;
			miniMidX = map(midX,0,xgrid,0,284);
			miniMidY = map(midY,0,ygrid,0,270);
			
			setMins();
		}
	}
	//set all the min variables so that everything is displayed properly when converting between various scales
	void setMins(){
		minX = map(midX-xlength/2,0,xgrid,531.749,531.749+853);
		maxX = map(midX+xlength/2,0,xgrid,531.749,531.749+853);
		minY = map(midY-ylength/2,0,ygrid,231.083,231.083+810);
		maxY = map(midY+ylength/2,0,ygrid,231.083,231.083+810);
	}
	
	void mouseReleased(){
		opressed = false;
		//setUpArtists();
	}
	void mouseOut(){
		opressed = false;
	}
}

//abstract class for a general button object
abstract class Button{
  int x, y, hw, hh;//x and y coordinates, followed by half the WIDTH and HEIGHT
  boolean invert;
  boolean pressedHere; // boolean to check whether button was pressed originally vs a different one
  Button(int x, int y, int hw, int hh) {
    this.x = x;
    this.y = y;
    this.hw = hw;
    this.hh = hh;
  }
  
  boolean pressed() {
    return mouseX > x - hw && mouseX < x + hw && mouseY > y - hh && mouseY < y + hh;
  }
  
  void newPos(int x, int y){
	this.x = x;
	this.y = y;
  }
  abstract void mousePressed();
  abstract void mouseReleased();
  abstract void draw();
}
//play button
class Play extends Button{
  boolean play;
    
  Play(int x, int y, int hw, int hh)   { 
    super(x, y, hw, hh); 
    play = true;
  }
  

  boolean paused()  {
    return play;
  }
  
  // code to handle playing and pausing the file
  void mousePressed()  {
    if (super.pressed()){
      invert = true;
      pressedHere = true;
    }
  }
  
  void mouseDragged(){
    if (super.pressed() && pressedHere)
      invert = true;
    else
      invert = false;
  }
  
  void mouseReleased()  {
    if(invert && pressedHere){
      if(playMode == AUDIO && started)
        song.togglePause();
	  else if(playMode == VIDEO){
		if(player.getPlayerState()==2)
			player.playVideo();
		else
			player.pauseVideo();
	  }
      invert = false;
    }
    pressedHere = false;
  }
  
  // play is a boolean value used to determine what to draw on the button
  void update()  {
    if(playMode == AUDIO && started){
      if (song != null && song.playState==1){
        if(song.paused){
          if(!changingPosition)
            play = true;
        }
        else
          play = false;
      }
      else 
        play = true;
    }
	else if(playMode == VIDEO){
      if (player.getPlayerState()==2||player.getPlayerState()==-1){
          if(!changingPosition)
            play = true;
        }
        else
          play = false;
      }
  }
  
  void draw()  {
    if ( invert ){
      fill(255);
      noStroke();
    }
    else{
      noFill();
      if(super.pressed())
        stroke(255);
      else
        noStroke();
    }
    rect(x - hw, y - hh, x+hw, y+hh);
    if ( invert )    {
      fill(0);
      noStroke();
    }
    else    {
      fill(255);
      noStroke();
    }
    if ( play )    {
      triangle(x - hw/2, y - hh/2, x - hw/2, y + hh/2, x + hw/2, y);
    }
    else    {
      rect(x - hw/2, y - hh/2, x-1, y + hh/2);
      rect(x + hw/2, y - hh/2, x +1, y + hh/2);
    }
  }
}

class Forward extends Button{
  boolean invert;
  boolean pressed;
  
  Forward(int x, int y, int hw, int hh){
    super(x, y, hw, hh);
    invert = false;
  }
  
  void mousePressed()  {
    if (super.pressed()){ 
      invert = true;
      pressedHere = true;
    }
  }
  
  void mouseDragged(){
    if (super.pressed() && pressedHere)
      invert = true;
    else
      invert = false;
  }
  
  void mouseReleased()  {
    if(invert && pressedHere){
      //code to skip to next song

      videoEnded();
      invert = false;
    }
    pressedHere = false;
  }

  void draw()  {
    if ( invert ){
      fill(255);
      noStroke();
    }
    else{
      if(super.pressed()){
		textSize(14);
		var twidth = textWidth("Next Video");
		fill(0); stroke(255);
		rect(x-twidth/2-3,y+15,x+twidth/2+3,y+35);
		textAlign(CENTER,TOP);
        fill(255); text("Next Video",x,y+17);
		noFill();
	}
      else{
        noStroke();
		noFill();
		}
    }
    rect(x - hw, y - hh, x + hw, y+hh);
    if ( invert )    {
      fill(0);
      noStroke();
    }
    else    {
      fill(255);
      noStroke();
    }
    rect(x-3, y-hh/2, x-6, y + hh/2); 
    triangle(x, y - hh/2, x, y + hh/2, x + hw/2 +1, y);    
  }  
}

//iterate onto the next video in the list. this should be used if we ever create a "next song" button
void createNext(){
  if(playingVideo < location.list.length-1){//if there are more videos left in the list, play them
  	playingVideo++;
	loadVideo();
  }
  else//otherwise go to the next location
	nextLocation();
}

ArrayList recentlyPlayed;

//go to another location in the map
void nextLocation(){
	boolean alreadyPlayed = false;
	//check if the current location is set as already played 
	for(int i = 0; i < recentlyPlayed.size(); i++){
		if(recentlyPlayed.get(i) == location._id){
			alreadyPlayed = true;
			break;
		}
	}
	//if not, set it as already played
	if(!alreadyPlayed){
		recentlyPlayed.add(location._id);
	}
	//find a location that hasn't been played already and is in the current viewscope of the map
	for(int i = 0; i < locations.size(); i++){
		var cur = locations.get(i);
		if(cur.x > minX && cur.x < maxX && cur.y > minY && cur.y < maxY && !recentlyPlayed.contains(cur._id)){
			location = cur;
			playingVideo = 0;
			loadVideo();
			//showBio();			
		}
	}
}


function textPair(length,index){
  this.length = length;
  this.index = index;
}

/*This function checks to see if the text that is being printed is longer than the
allocated space available for the text. (the fourth paramater, max, is the max length).
If the text length is longer than max, then checkText will have a horizontal scrolling
text in the place of a regular text print. This way, all the writing is visible without 
going past the allocated space.
*/
void checkText(String string, int x, int y,int max,color col, int ybelow,int extra1){
  if(textWidth(string)>max){
	int extra = 0;
	if(extra1)
		extra = extra1;//extra is used to shorten the max length of the text (can fix draw issues with small fonts)
    var cur = longText.get(string + textWidth(string));//long texts are saved in a hashmap
    if(cur == null){ //if this longtext isn't already accounted for, place it in the hashmap
      cur = new textPair(0,0);//a textpair has two variables, the current index that is being first displayed
      longText.put(string+textWidth(string),cur);//and the length (pixels) that that index has scrolled
    }
    int i = cur.index;
    int slength = string.length();//length of the entire string
    if(cur.length >= textWidth(string.charAt(i))){//if current char has scrolled more than it's length
      if(i < slength-1){//go to the next char
        cur.index++;
        i++;
        cur.length = 0;
      }
      else{// or if we've been through all of them, reset to the beginnning
        cur.index = i = 0;
        cur.length = -40;
      }
    }
    int totalLength = textWidth(string.charAt(i))-cur.length; //the total length to be displayed begins with the amount of the car that is being displayed
    i++;
    while(totalLength < max-extra && i < slength){//keep adding chars to the "to be displayed list"
      totalLength += textWidth(string.charAt(i));//as long as we haven't reached the maximum allocated space
      i++;//or gone through the whole string
    }
    text(string.substring(cur.index,i),x-cur.length,y); //draw the text so far
    if(i == slength){//if we've gone through the whole string
      totalLength += 40;//then add a space
      int j = 0;//and restart from the beginning of the string!
      while(totalLength < max-extra){//adding chars until we reach the allocated space
        totalLength += textWidth(string.charAt(j));
        j++;
      }
      text(string.substring(0,j),x+textWidth(string.substring(cur.index,i))-cur.length + 40, y);
    }
    noStroke();
    fill(0);
	rectMode(CORNERS);
    rect(x-textWidth('W'),y+ybelow,x,y);//draw black boxes at the beginning
    rect(x+max,y,x+max+textWidth('W'),y+ybelow);//and end of the string
    fill(col);//so that there appears to be a continuous scroll
    cur.length++;
    longText.put(string+textWidth(string),cur);
  }
  else
    text(string,x,y);
}

final int BASICINFO = 0;
final int SETTINGS = 1;

boolean forwardPageHover, backPageHover;
int curGenre = 0;
int PANEMINY, PANEMINX, PANEMAXY, PANEMAXX, controlLength, INFOMINY;
/*this is the class that deals with all the info displayed on the sidePane*/
class SidePane{  
  int panel = BASICINFO;
  int margin = 10;
  int slant = 2;
  int num;
  //int mouseMainPaneControl = -1;
  //var colorIcon, sortIcon;
  
  String[] names = {" Current Info"," Color Mode","Sorting"};
  color currentColor;

  SidePane(minx, miny){	
    PANEMINX = minx;
    PANEMINY = miny;
    controlLength = 57;
    INFOMINY = PANEMINY;//+controlLength;
	PANEMAXX = WIDTH-SPLdistanceX;
	backPageHover = forwardPageHover = false;
	//this function adjusts the numbers of videos visible in a list at any given moment, depending on the screen resolution
	if(HEIGHT < 870){
		int x = 870;
		int i = 0;
		while(x>HEIGHT && i < 5){
			x -= 22;
			i++;
		}
		PANEMAXY = PANEMINY + 558-controlLength - i*22;
		$('#dialogWindow').css('top',353-i*22-controlLength);
		vidsToShow = 10-i;
		yloc = PANEMAXY-18;
	}else PANEMAXY = PANEMINY + 558-controlLength; 
	MINIMAXY = PANEMAXY + 270;
    num = names.length;
    textSize(16);
  }
  
void mousePressed(){} void mouseClicked(){}
  void draw(){
    drawControl();
	if(!location){printNoVideo();}else{printLocation();}	//if no locations are selected, print default text
	//otherwise show the location's info
  }
  
  /*draw the boundary around the sidePane.

note - there is also code here that deals with having a tabbed menu system, but this is currently 
not in use. if it gets used in the future, the code is already here in commented format.*/
  void drawControl(){
	fill(0);
	//noStroke();
	strokeWeight(2);
    stroke(255);
	rectMode(CORNERS);
	//rect(PANEMINX,PANEMINY,PANEMAXX,PANEMAXY);
	rect(PANEMINX,INFOMINY,PANEMAXX+1,PANEMAXY);
    
    textSize(15);
	//line(PANEMAXX+1,INFOMINY,PANEMAXX+1,PANEMAXY);
    /*line(PANEMINX,PANEMINY,PANEMAXX,PANEMINY);
    line(PANEMINX, INFOMINY, PANEMAXX, INFOMINY);
    line(PANEMINX,PANEMINY,PANEMINX, PANEMAXY-1);
    line(PANEMAXX+1,PANEMINY,PANEMAXX+1,PANEMAXY-1);*/
	rectMode(CORNERS);
	noFill();
	rect(PANEMINX, MINIMAXY, PANEMAXX+1, PANEMAXY);
    /*for(int i = 0; i < 5; i++)
      line(PANEMINX + controlLength*(i+1), PANEMINY, PANEMINX + controlLength*(i+1),INFOMINY-1);
	imageMode(CORNERS);
	image(info, PANEMINX, PANEMINY,PANEMINX+controlLength,INFOMINY);
	image(facebook,PANEMINX+controlLength*2,PANEMINY,PANEMINX+controlLength*3,INFOMINY);
	image(heart,PANEMINX+controlLength,PANEMINY,PANEMINX+controlLength*2,INFOMINY);
	image(youtube,PANEMINX+controlLength*3,PANEMINY,PANEMINX+controlLength*4,INFOMINY);
	image(twitter,PANEMINX+controlLength*4,PANEMINY,PANEMINX+controlLength*5,INFOMINY);
    ellipseMode(CENTER_RADIUS);
    noStroke();*/
    /*for(int i = 0; i < 10; i++){
      fill(colors[(colorIcon.start + i)%10]);
      ellipse(PANEMINX+length+colorIcon.places[i*2],PANEMINY+colorIcon.places[i*2+1],4,4);
    }
    for(int i = 0; i < 10; i++){
      stroke(colors[(sortIcon.start + i)%10]);
      line(PANEMINX+length*2+7,PANEMINY+sortIcon.places[i], PANEMINX+length*3-8,PANEMINY+sortIcon.places[i]);
    }*/
    //checking da mouse
    /*mouseMainPaneControl = -1;
    stroke(255);
    noFill();
    //rect(PANEMINX+length*panel+2,PANEMINY+1,PANEMINX+length*(panel+1)-2,INFOMINY-2);
    if(mouseX > PANEMINX && mouseY > PANEMINY && mouseY < INFOMINY && mouseX < PANEMINX+controlLength*5){
      for(int i = 0; i < 5; i++){
        if(mouseX < PANEMINX + controlLength*(i+1)){
          rect(PANEMINX+controlLength*i+2,PANEMINY+1,PANEMINX+controlLength*(i+1)-2,INFOMINY-2);
          textAlign(LEFT,BASELINE);
          textSize(16);
          fill(255);
		  curMenu = i;
          title(PANEMINX,PANEMINY-7);
          mouseMainPaneControl = i;
          break;
        }
      }
    }
	else curMenu = -1;*/
  }
  
	/*void title(int x, int y){
		switch(curMenu){
			case 0: text("Artist Info",x,y);break;
			case 1: text("Heart Artist",x,y);break;
			case 2: text("Artist's Facebook Page",x,y);break;
			case 3: text("View Current Song Video",x,y);break;
			case 4: text("Tweet About Song",x,y); break;
		}
	}*/

	int pageToShow = 0; // what page (of the list of videos) should we show?
	int totalPagesToShow = 1; // what are the total number of pages possible?
	
	//make sure that we aren't trying to display a page that doesn't exist
	void resetSize(){
		if(location && location.list){
			while(pageToShow*vidsToShow >= location.list.length){
				pageToShow--;
			}
			totalPagesToShow = ceil(location.list.length/vidsToShow);
		}
	}
	//set page to 0 - called when a new location is started
	void resetPage(){
		pageToShow = 0;
	}
	void nextPage(){
		pageToShow++;
	}
	void previousPage(){
		pageToShow--;
	}
	void setToRightPage(){ //make sure the playing video is displayed.
		if(location && location.list){
			while(playingVideo >= (pageToShow+1)*vidsToShow)
				pageToShow++;
		}
	}

	//print location information
	void printLocation(){
		textAlign(LEFT,TOP);
		textSize(22);
		fill(colors[location.type]);
		checkText(location.title,PANEMINX+21,INFOMINY+10, 240, 0,22,8); //print the title
		fill(255);
		textSize(16);
		curVid = -1;
		if(location.list){
			int tot = min(vidsToShow,location.list.length-pageToShow*vidsToShow); //total number of videos to display in current page
			int base = pageToShow*vidsToShow; // first vid to display's position in list
			//print each of the songs
			for(int i = base; i < base+tot; i++){
				if(i == playingVideo){
					//color it if it's currently playing
					fill(colors[location.type]);
					checkText(location.list[i].title, PANEMINX+30, INFOMINY + 35 + (i-base)*22,238,colors[location.type],30,13);
					fill(255);
				}
				else if(mouseX>PANEMINX+28 && mouseY < INFOMINY+35+(i-base+1)*22&& mouseY>INFOMINY+35+(i-base)*22){
					//if it's currently hovered over, color it and make it clickable (setting curVid to the number)
					fill(colors[location.type]);
					checkText(location.list[i].title, PANEMINX+30, INFOMINY + 35 + (i-base)*22,238,colors[location.type],30,13);
					curVid = i;
					fill(255);
				}
				else//otherwise just print it without anything fancy
					checkText(location.list[i].title, PANEMINX+30, INFOMINY + 35 + (i-base)*22,238,color(255),30,13);
			}
			
			//show page navigation control if there are more vids in the list than a page allows for
			if(vidsToShow < location.list.length){
				textSize(14);
				//display of page number
				text(pageToShow+1+"/"+totalPagesToShow, PANEMAXX - 46, INFOMINY+30+vidsToShow*22);
				//control for going back a page (if we're not in the first page)
				if(pageToShow > 0 && mouseX > PANEMAXX-64 && mouseX < PANEMAXX-46 && mouseY < INFOMINY+43+vidsToShow*22 && mouseY > INFOMINY+35+vidsToShow*22){
					fill(color(255,182,0));
					text('<',PANEMAXX-58,INFOMINY+30+vidsToShow*22);
					text('<',PANEMAXX-64,INFOMINY+30+vidsToShow*22);
					fill(255);
					backPageHover = true;
				}
				else{
					backPageHover = false;
					text('<',PANEMAXX-58,INFOMINY+30+vidsToShow*22);
					text('<',PANEMAXX-64,INFOMINY+30+vidsToShow*22);
				}
				//control for going forward a page (if we're not in the last page)
				if(pageToShow < location.list.length/vidsToShow-1 && mouseX > PANEMAXX-23 && mouseX < PANEMAXX-7 && mouseY < INFOMINY+43+vidsToShow*22 && mouseY > INFOMINY+35+vidsToShow*22){
					fill(color(255,182,0));
					text('>',PANEMAXX-22,INFOMINY+30+vidsToShow*22);
					text('>',PANEMAXX-16,INFOMINY+30+vidsToShow*22);
					fill(255);
					forwardPageHover = true;
				}
				else{
					forwardPageHover = false;
					text('>',PANEMAXX-22,INFOMINY+30+vidsToShow*22);
					text('>',PANEMAXX-16,INFOMINY+30+vidsToShow*22);
				}
			}
		}
		else{
			text(location.info,PANEMINX+30, INFOMINY+35,238,PANEMAXX-PANEMINX+20);
		}
	}
  //Basic Information if nothing is playing
  void printNoVideo(){
		textAlign(LEFT);
	fill(255);
    textSize(16);
    text("Welcome to RapCities New York!  Here you can explore how the sights and sounds of hip-hop"
	+" music and culture change from neighborhood to neighborhood.  Click through, check it out, and keep it locked - RapCities content is added daily."
    , PANEMINX+15, INFOMINY+20, PANEMAXX - PANEMINX - 20,HEIGHT-INFOMINY);
  }
}

boolean changingPosition = false; // used to alter where the drawing happens
int volume = 50;
boolean muted = false;
int timeDisplacement, seekLeft, volX;
int curRight, curLeft, curTop, curBottom, yloc;
  
//class used to control the currently playing video/volume.
class Current{
  Play play; //play button
        //Rewind rewind; //rewind button
  Forward ffwd; //ffwd button

  Current(){
	curLeft = PANEMINX; curRight = PANEMAXX; curTop = PANEMAXY - 230; curBottom = PANEMAXY;
    timeDisplacement = textWidth("0:00/0:00");
	seekLeft = PANEMINX+95;
	yloc = PANEMAXY-18;
    play = new Play(PANEMINX+72, yloc, 10, 10);
             //rewind = new Rewind(250, 50, 20, 10);
    ffwd = new Forward(PANEMAXX-20, yloc, 10, 10);
	volX = PANEMINX+40;
	volY = 15; volD = 0.3; //divider (make it twice volY divided by 100)
	volS = 20; // separatedeness of volume setter
	seekRight = PANEMAXX - 40 - timeDisplacement;
    textSize(15);
  }
  
  void draw(){
    if(playMode == VIDEO || (playMode == AUDIO && started)){
	
	rectMode(CORNERS);
      // draw the controls
      play.update();
      play.draw();
              //rewind.draw();
      ffwd.draw();  
      
     // draw the seekbar
      drawSeekBar();
      
     drawVolume();
      if(onVolGen)
        drawVolumeSetter();
      rectMode(CENTER);
      ellipseMode(CENTER_RADIUS);
    }
  }
   
  boolean pressedInSeekBar = false;

  void mousePressed(){
    play.mousePressed();
    ffwd.mousePressed();
    checkSeekBar();
    checkVol();
  }
  
  void mouseDragged(){
    play.mouseDragged();
    ffwd.mouseDragged();
    dragSeekBar();
    dragVol();
  }

  void mouseReleased(){
    play.mouseReleased();
    ffwd.mouseReleased();
    releaseSeekBar();
    releaseVol();
  }
  
// is mouse over regular volume icon?
  boolean onVolume(){
    if(mouseX > volX-10 && mouseX < volX+2 && mouseY > yloc-6 && mouseY < yloc+6)
      return true;
    return false;
  }
// is mouse over regular volume icon or the control that appears after mouse first hovers over volume icon?
  boolean onVolumeSetter(){
    if(mouseX > volX-volS-10 && mouseX < volX+20 && mouseY > yloc-volY && mouseY < yloc+volY)
      return true;
    return false;
  }
  
  boolean onVol = false;
  boolean onVolGen = false;
  boolean volDragged = false;
  
//draw everything related to the volume control icon, and prep the variables used for the volume setter
  void drawVolume(){
    if(onVolume()){
      onVol = true;
      stroke(255);
    }
    else{
      noStroke();
      onVol = false;
    }
    fill(255);
    triangle(volX-10, yloc, volX, yloc-7, volX, yloc+7);
    rect(volX-10,yloc+3,volX-3, yloc-3);
    stroke(255);
    strokeWeight(2);
    noFill();
	ellipseMode(RADIUS);
	//if not mute, draw appropriate number of semicircles
    if(!muted){
      if(volume > 80)
        arc(volX+6, yloc, 12, 12, -(PI/3), PI/3);
      if(volume > 60)
        arc(volX+5, yloc, 9, 9, -(PI/3), PI/3);
      if(volume > 40)
        arc(volX+4, yloc, 6, 6, -(PI/3), PI/3);
      if(volume > 20)
        arc(volX+3, yloc, 3, 3, -(PI/3), PI/3);
    }
    else{
      stroke(color(255,0,0));
      line(volX-9,yloc-8,volX+2,yloc+7);
    }
    if(onVolumeSetter())
      onVolGen = true;
    else if(!volDragged)
      onVolGen = false;
  }  
  
  void checkVol(){
    if(onVol)
      toggleMute();
    else if(onVolGen && mouseX > volX-volS-5 && mouseX < volX-volS+5 && mouseY > yloc -volY && mouseY < yloc+volY){
		volDragged = true;
      volume = (yloc+volY - mouseY)/volD;
		if(playMode == AUDIO)
      		song.setVolume(volume);
		else if(playMode == VIDEO)
  			player.setVolume(volume);			
    }
  }
//if it's being dragged, adjust accordingly
  void dragVol(){
    if(volDragged){
      if(mouseY > yloc+volY)
        volume = 0;
      else if(mouseY < yloc-volY)
        volume = 100;
      else
        volume = (yloc+volY - mouseY)/volD;
	  	if(playMode == AUDIO)
      		song.setVolume(volume);
		else if(playMode == VIDEO)
  			player.setVolume(volume);			
    }
  }
  
  void releaseVol(){
    if(volDragged){
      volDragged = false; 
    }    
  }
  //draw the volume setting bar
  void drawVolumeSetter(){
    stroke(255);
    strokeWeight(2);
    fill(0);
    rect(volX-volS-5, yloc-volY, volX-volS+5, yloc+volY);
    if(volume > 0){
	  if(location) fill(colors[location.type]);
      else fill(color(255,182,0));
      noStroke();
      rect(volX-volS-4, yloc+volY-1, volX-volS+4, yloc+volY+1 - volume*volD);
    }
  }
  //toggle both real mute and our variable
  void toggleMute(){
	if(playMode == AUDIO && started)
    	song.toggleMute();
	else if(playMode == VIDEO){
		if(player.isMuted())
			player.unMute();
		else
			player.mute();
	}	
    muted = !muted;
  }
  
  boolean songPausedToBeginWith = false;
  
  //checks to see if user clicked somewhere in the seek bar
  void checkSeekBar(){
    //if song is loaded
    if((playMode == AUDIO && started)||playMode == VIDEO){
      //if it is within the seekbar range
      if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10){
        changingPosition = true;
        stillWithinSeekBar = true;
        if((playMode == AUDIO && song.paused) || (playMode == VIDEO && player.getPlayerState() == 2)) //save whatever state it was in
          songPausedToBeginWith = true;
        else
          songPausedToBeginWith = false;
		if(playMode == AUDIO)
        	song.pause();
		else
			player.pauseVideo();
      }
    }
  }

  //checks to see if user let go of the mouse will in seekbar land
  void releaseSeekBar(){
    //if song is loaded
    if(playMode == VIDEO || (playMode == AUDIO && started)){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10){
          int total;
		  if(playMode == AUDIO){
          	if(song != null && song.readyState == 1)
	            total = song.durationEstimate;
	          //if song is fully loaded
	          else if(song != null && song.readyState == 3)
	            total = song.duration;
			 int seekPosition = (int)map(mouseX,seekLeft,seekRight, 0, total);
	          if(!songPausedToBeginWith)
	            song.resume();
	          song.setPosition(seekPosition);
		  }
		  else{
			int seekPosition = (int)map(mouseX,seekLeft,seekRight, 0, player.getDuration());
			  player.seekTo(seekPosition, true);
			  if(!songPausedToBeginWith)
	            player.playVideo();
			} 
          
        }
        changingPosition = false;
        stillWithinSeekBar = false;
        //make it play again if it's been paused in the transition process
        if(!songPausedToBeginWith){
			if(playMode == AUDIO)
          		song.resume();
			else
				player.playVideo();
		}
      }
    }
  }
  
  boolean stillWithinSeekBar;
  //makes the line follow where the mouse is while dragging around
  void dragSeekBar(){
    //if song is loaded
    if(playMode == VIDEO || (playMode == AUDIO && started)){
      //if click was initiated in seekbar
      if(changingPosition){
        //if within range still
        if(mouseX>seekLeft && mouseX<seekRight && mouseY>yloc-10 && mouseY<yloc+10)
          stillWithinSeekBar = true;
        else
          stillWithinSeekBar = false;
      }
    }
  }
  
  String totTime;
  int total;
  
  //draws the seekbar, along with the position of the song if it's playing, as well as the time
  void drawSeekBar(){
    stroke(255);
    strokeWeight(3);
	if(playMode == VIDEO && player.getPlayerState() == -1){
		fill(255);
	      textSize(19);
	      textAlign(LEFT,CENTER);
			text("-:--/-:--",curRight-28-timeDisplacement,yloc);
		
	}
    if((playMode == AUDIO && song != null && song.readyState == 1) || playMode == VIDEO && player.getPlayerState() == 3){
		//draw song duration
      strokeWeight(1);
      line(seekLeft, yloc, seekRight, yloc);
      //draw amount loaded
      strokeWeight(3);
	float x;
		if(playMode == AUDIO)
      		 x = map(song.bytesLoaded, 0, song.bytesTotal, seekLeft, seekRight);
		else
			 x = map(player.getVideoBytesLoaded(), 0, player.getVideoBytesTotal(),seekLeft,seekRight);
      if(x>=0)
        line(seekLeft, yloc, x, yloc);
    }
    else
      line(seekLeft, yloc, seekRight, yloc);
    //if song is loaded/loading, draw position
    if((playMode == AUDIO && song != null && (song.readyState == 1 || song.readyState == 3)) || 
		(playMode == VIDEO && player.getPlayerState() > 0)){
      //take seek changes into account
      String curTime;

      if(!changingPosition || !stillWithinSeekBar){
		float x;
		if(playMode == AUDIO){
	        //if song is currently loading
	        if(song.readyState == 1){
	          total = song.durationEstimate;
	          totTime = makeTime(total/1000);
	        }
	        //if song is fully loaded
	        else if(song.readyState == 3){
	          total = song.duration;
	          totTime = makeTime(total/1000);
	        }
			curTime = makeTime(song.position/1000);
	        x = map(song.position, 0, total, seekLeft, seekRight);
		}
		else if(playMode == VIDEO){
			total = player.getDuration();
			totTime = makeTime(total);
			curTime = makeTime(player.getCurrentTime());
	        x = map(player.getCurrentTime(), 0, total, seekLeft, seekRight);
	        
		}
        if(x>=0)
          line(x, yloc-10, x, yloc+10);
      }
      else{
        line(mouseX, yloc-10, mouseX, yloc+10);
		float time = map(mouseX,seekLeft,seekRight,0,total);
		if(playMode == AUDIO)
			time /= 1000;
        curTime = makeTime(time);
      }
      fill(255);
      textSize(15);
      textAlign(LEFT,CENTER);
      //if(total != 0)
        //curTime += "/" + totTime;
      text(curTime+"/"+totTime,curRight-30-timeDisplacement,yloc);
    }
    strokeWeight(1);
  }
}

//used to convert millisecond time in ints into a minutes:second string
String makeTime(float time){ 
  int secs = (int) (time % 60);
  String minutes = (int) ((time % 3600) / 60);
  String seconds;
  //take care of sub-10 second cases
  if(secs == 0) 
    seconds = "00";
  else if(secs < 10)
    seconds = "0" + secs;
  else
    seconds = secs;
  return (minutes + ":" + seconds);
}  

//called when a video ends - creates next video
void videoEnded(){
	if(location.list && playingVideo < location.list.length-1){
	  	playingVideo++;
		loadVideo();
		sidePane.setToRightPage();
	} else
		nextLocation();
}

//show the youtube player
void togglePlayer(){
	$("#ytplayer").html('<script type="text/javascript">var params = { allowScriptAccess: "always" };var atts = { id: "YouTubeP" };swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&version=3", "ytplayer", "283", "200", "8", null, null, params, atts);</script>');
}

var player; 
boolean playMode;
int AUDIO = 1;
int VIDEO = 2;

int playerReady = 0;
//prep the player
void prepPlayer(){
	player = document.getElementById('YouTubeP');
	playMode = VIDEO;
	player.setVolume(volume);
	playerReady = 1;
	if(rapReady == 3) startMusic();
}
var startingVideo = 'nL3IpxX2XB'; //starting video - jayZ
var startingRID = 0; //starting sub (if it exists)
int rapReady = 0; //used to tell if site is ready
void startMusic(){
  var pathArray = window.location.pathname.split('/');
  var loadlocID, loadvidID;
  if(pathArray[1] == "l"){
    loadlocID = pathArray[2];
    loadvidID = pathArray[3];
  }
  else{
	loadlocID = startingVideo;
	loadvidID = startingRID;
  }	

    for(int i = 0; i < locations.size(); i++){
	  if(locations.get(i)._id==loadlocID){
		  location = locations.get(i);
		  if(loadvidID && location.list){
		    for(int j = 0; j < location.list.length; j++){
		      if(location.list[j].RID == loadvidID){
				playingVideo = j;
				setNewMapLocation(location.x,location.y);
				loadVideo(); sidePane.resetSize(); sidePane.setToRightPage();
				//showBio();
				break;
		      }
		    }
		  } else{
		    playingVideo = 0;
			setNewMapLocation(location.x,location.y);
		    loadVideo(); sidePane.resetSize(); sidePane.setToRightPage();
			//showBio();
		  }
		break;
	  }
  }
}

void setNewMapLocation(x,y){
	midX = map(x,531.749,531.749+853,0,xgrid);
	midY = map(y,231.083,231.083+810,0,ygrid);
	miniMidX = map(midX,0,xgrid,0,284);
	miniMidY = map(midY,0,ygrid,0,270);
	nyc.setMins();
}

//load new video using global parameters
void loadVideo(pl,pos){
   	if(location.list && location.list.length > 0){
		var startPoint = 0;
		if(location.list[playingVideo].startPoint)
			startPoint = location.list[playingVideo].startPoint;
	    player.loadVideoById(location.list[playingVideo].ytid,startPoint);
		$.ajax({//increase the viewcount on the server
			url: "/loc/view",
			data: {_id:location._id,position:playingVideo,city:mapname}
		});
	  }
	else if(location.ytid){
		var startPoint = 0;
		if(location.startPoint)
			startPoint = location.startPoint;
		player.loadVideoById(location.ytid,startPoint);
		$.ajax({//increase the viewcount on the server
			url: "/loc/view",
			data: {_id:location._id,city:mapname}
		});
	 //$("#ytplayer").html("<p>Couldn't find this song on YouTube</p>");
	}
}

//prep the bio of the current artist -- not currently in use.
void showBio(){
    if(location.bio){   	
		//$("div#biolog").html('<b>'+artist.name+'</b><br /><p>' + results.text + '<br /><br />Source: <a href="' + results.url + '">Wikipedia</a></p>');
        $("div#biolog").html(location.bio);
	  	//$('div#biolog', window.parent.document).scrollTop(0);
    
		if( !$("div#biolog").dialog("isOpen") ) {
			$("div#biolog").dialog("open");
		}
	}
}