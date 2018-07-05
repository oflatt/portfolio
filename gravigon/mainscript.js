var keymappingtools = {};
keymappingtools["a"] = "asteroid";
keymappingtools["s"] = "split force";
keymappingtools["m"] = "move force";
keymappingtools["n"] = "new force";
keymappingtools["d"] = "delete force";
keymappingtools["r"] = "select force";
keymappingtools["g"] = "create gravigon";

function randInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function Point(x, y, xvel, yvel){
    this.x = x;
    this.y = y;
    this.xvel = xvel;
    this.yvel = yvel;
}

//magp and attrp are each a Point
//polygonlist is a list of points where the positions are relative to the attrp of the planet
function Planet(magp, attrp){
    this.magp = magp;
    this.attrp = attrp;
    this.polygonlist = [];
}

var tools = ["asteroid", "split force", "move force", "new force", "delete force", "select force", "create gravigon", "edit gravigon"]
var midx;
var midy;
var point;
var planets;
var selectedplanetindex;
var selectedgravigonpoint;
var paused; // clear screen while moving asteroid
var mousedownp; // used to keep track of mouse if a tool is being used
var mousebuttonpressed = null;
var currenttool = "asteroid";
var buttonw;
var menuupp = false;
function reset(){
    var c=document.getElementById("background");
    var ctx=c.getContext("2d");
    buttonw = window.innerHeight/20;
    midx = window.innerWidth/2;
    midy = window.innerHeight/2;
    point = new Point(midx, midy-midy/2, midy/800, midy/800);
    paused = false;
    planets = [];
    makeplanet(midx, midy, 0, 0);
    selectedplanetindex = 0;
    clearBackground();
}

function makeplanet(x, y, xvel, yvel){
    planets.push(new Planet(new Point(x, y, xvel, yvel), new Point(x, y, xvel, yvel)));
}


function resizeBackground(){
    var c=document.getElementById("background");
    c.width = window.innerWidth;
    c.height = window.innerHeight;
    var c2 = document.getElementById("foreground");
    c2.width = window.innerWidth;
    c2.height = window.innerHeight;
    reset();
}



function getrgb(rgb){
    return "rgb("+rgb[0].toString()+","+rgb[1].toString()+","+rgb[2].toString()+")"
}

function onKey(event){
    var str = String.fromCharCode(event.keyCode).toLowerCase();;
    if(str in keymappingtools){
	buttonClicked(keymappingtools[str]);
    }
}

window.onkeydown = onKey;

function dist(x1,y1,x2,y2){
    return Math.sqrt(Math.pow(x1-x2, 2)+ Math.pow(y1-y2, 2));
}

function nearestPlanetIndex(event, magp){
    var lowestmag = -1;
    var lowestindex = 0;
    for(var i = 0; i<planets.length;i+=1){
	var mag = 0;
	var p = planets[i];
	if(magp){
	    mag = dist(p.magp.x, p.magp.y, event.clientX, event.clientY); 
	} else{
	    mag = dist(p.attrp.x, p.attrp.y, event.clientX, event.clientY);
	}
	if(mag<lowestmag || lowestmag == -1){
	    lowestmag = mag;
	    lowestindex = i;
	}
    }
    
    return lowestindex;
}

function onMouseDown(event) {
    var c = document.getElementById("background");
    var ctx = c.getContext("2d");
    var mousex = event.clientX;
    var mousey = event.clientY;

    if(currenttool == "asteroid"){
	// move point for use
	point.x = event.clientX;
	point.y = event.clientY;
	paused = true;
    }else if(currenttool == "move force"){
	selectedplanetindex = nearestPlanetIndex(event, false);
    } else if (currenttool == "split force"){
	// move the attraction point with left, and distance point with right
	selectedplanetindex = nearestPlanetIndex(event, event.button == 2);
    }else if(currenttool == "new force"){
	makeplanet(event.clientX, event.clientY, 0, 0);
	selectedplanetindex = planets.length-1;
    }else if(currenttool == "delete force"){
	var i = nearestPlanetIndex(event, false);
	planets.splice(i, 1);
    } else if(currenttool == "select force"){
	selectedplanetindex = nearestPlanetIndex(event, false);
    } else if(currenttool == "create gravigon"){
	if(event.button == 2){
	    selectedgravigonpoint = nearestGravigonIndex(event);
	}else{
	    addpointtogravigon(planets[selectedplanetindex], event);
	}
    }
    
    mousedownp = true;
    mousebuttonpressed = event.button;
    // also call onmousemove to start using the tool
    onMouseMove(event);
}

function onMouseUp(event){
    if(currenttool == "asteroid" && mousedownp){
	point.xvel = (event.clientX - point.x)/100;
	point.yvel = (event.clientY - point.y)/100;
	paused = false;
	clearBackground();
    }

    mousedownp = false;
}

function clearBackground(){
    var c = document.getElementById("background");
    var ctx = c.getContext("2d");
    ctx.beginPath();
    ctx.lineWidth = 0;
    ctx.fillStyle = getrgb([0,0,0]);
    ctx.rect(0,0,window.innerWidth, window.innerHeight);
    ctx.fill();
}


function onMouseMove(event){
    var updateattr = function(){
	planets[selectedplanetindex].attrp.x = event.clientX;
	planets[selectedplanetindex].attrp.y = event.clientY;
    };

    var updatemag = function(){
	planets[selectedplanetindex].magp.x = event.clientX;
	planets[selectedplanetindex].magp.y = event.clientY;
    };
    
    if(mousedownp){
	if(currenttool=="asteroid"){
	    clearBackground();
	    drawArrow(point.x, point.y, event.clientX, event.clientY);
	} else if(mousebuttonpressed == 2 && currenttool == "split force"){
	    updatemag();
	}else if(mousebuttonpressed != 2 && currenttool == "split force"){
	    updateattr();
	} else if(currenttool == "move force"){
	    updateattr();
	    updatemag();
	} else if(currenttool == "new force"){
	    updateattr();
	    updatemag();
	} else if(currenttool == "create gravigon"){
	    var newx = event.clientX-planets[selectedplanetindex].attrp.x;
	    var newy = event.clientY-planets[selectedplanetindex].attrp.y;
	    pl = planets[selectedplanetindex].polygonlist;
	    if(pl.length>2){
		var beforepointi = selectedgravigonpoint-1;
		var afterpointi = (selectedgravigonpoint+1)%pl.length;
		if(beforepointi <0){
		    beforepointi = pl.length-1;
		}
		if(betweenmodular(getangle(pl[beforepointi].x, pl[beforepointi].y), getangle(pl[afterpointi].x, pl[afterpointi].y),
				  getangle(newx, newy))){
		    pl[selectedgravigonpoint].x = newx;
		    pl[selectedgravigonpoint].y = newy;
		}
	    }else{
		pl[selectedgravigonpoint].x = newx;
		pl[selectedgravigonpoint].y = newy;
	    }
	}
    }
    if(menuupp){
	closeNav();
    }
}

function drawmarker(x, y, color, text, highlightedp){
    var markerw = window.innerHeight/100;
    var highlightw = markerw*4/3;
    var c=document.getElementById("foreground");
    var ctx=c.getContext("2d");

    if(highlightedp){
	ctx.fillStyle = "rgb(255,255,0)";
	ctx.fillRect(x-highlightw/2, y-highlightw/2, highlightw, highlightw);
    }
    
    ctx.fillStyle = color;
    ctx.fillRect(x-markerw/2, y-markerw/2,markerw, markerw);
    ctx.font = Math.floor(markerw).toString()+"px Times";
    ctx.fillStyle = "white";
    ctx.fillText(text, x-markerw/3, y+markerw/3);
}

function drawplanets(){
    var c=document.getElementById("foreground");
    var ctx=c.getContext("2d");
    ctx.clearRect(0,0,window.innerWidth, window.innerHeight);
    
    for(var i = 0; i< planets.length; i+=1){
	var magx = planets[i].magp.x;
	var magy = planets[i].magp.y;
	var attrx = planets[i].attrp.x;
	var attry = planets[i].attrp.y;

	//attraction point
	if(magx == attrx && attry == magy){
	    // purple for both
	    drawmarker(magx, magy, getrgb([70, 0, 130]), i.toString(), i == selectedplanetindex);
	}else{
	    //distance marker
	    drawmarker(magx, magy, getrgb([255, 0, 0]), i.toString(), i == selectedplanetindex);
	    // attraction marker
	    drawmarker(attrx, attry, getrgb([0,0,255]), i.toString(), i == selectedplanetindex);
	}
	drawpolygon(planets[i]);
    }
}


function step(){
    var c=document.getElementById("background");
    var ctx=c.getContext("2d");
    
    drawplanets();
    
    ctx.lineWidth = 1;
    if(!paused){
	for(var i = 0;i < 30; i++){
	    moveasteroid();
	}
    }
    
    window.requestAnimationFrame(step);
}

function moveasteroid(){
    for(var i = 0; i<planets.length; i += 1){
	moveasteroidwith(planets[i].magp.x,planets[i].magp.y, planets[i].attrp.x, planets[i].attrp.y);
    }
}

function moveasteroidwith(magx, magy, attrx, attry){
    var c=document.getElementById("background");
    var ctx=c.getContext("2d");
    var oldx = point.x;
    var oldy = point.y;
    
    var mag = dist(point.x, point.y, magx, magy);
    var jerk = 0;
    var gravity = midy/4000;
    if(jerk == 1){
	gravity = (midy)/(Math.pow(mag, 2));
    }
    gravity = gravity / 20;
    point.xvel += -(point.x-attrx)*gravity/mag;
    point.yvel += -(point.y-attry)*gravity/mag;
    
    point.x += point.xvel;
    point.y += point.yvel;
    

    ctx.strokeStyle=getrgb([255-(Math.abs(point.x-midx)*255/(midx)),
			    255-(Math.abs(point.y-midy)*255/(midy)),
			    mag*255/(midy)]);
    ctx.beginPath();
    ctx.moveTo(oldx, oldy);
    ctx.lineTo(point.x,point.y);
    ctx.stroke();
}

function drawArrow(fromx, fromy, tox, toy){
    //variables to be used when creating the arrow
    var c = document.getElementById("background");
    var ctx = c.getContext("2d");
    var headlen = 10;

    var angle = Math.atan2(toy-fromy,tox-fromx);

    //starting path of the arrow from the start square to the end square and drawing the stroke
    ctx.beginPath();
    ctx.moveTo(fromx, fromy);
    ctx.lineTo(tox, toy);
    ctx.strokeStyle = getrgb([0, 255, 0]);
    ctx.lineWidth = 10;
    ctx.stroke();

    //starting a new path from the head of the arrow to one of the sides of the point
    ctx.beginPath();
    ctx.moveTo(tox, toy);
    ctx.lineTo(tox-headlen*Math.cos(angle-Math.PI/7),toy-headlen*Math.sin(angle-Math.PI/7));

    //path from the side point of the arrow, to the other side point
    ctx.lineTo(tox-headlen*Math.cos(angle+Math.PI/7),toy-headlen*Math.sin(angle+Math.PI/7));

    //path from the side point back to the tip of the arrow, and then again to the opposite side point
    ctx.lineTo(tox, toy);
    ctx.lineTo(tox-headlen*Math.cos(angle-Math.PI/7),toy-headlen*Math.sin(angle-Math.PI/7));

    //draws the paths created above
    ctx.lineWidth = 10;
    ctx.stroke();
    ctx.fillStyle = getrgb([0,255,0]);;
    ctx.fill();
}

function onLoad(){
    resizeBackground();
    window.requestAnimationFrame(step);
    var c=document.getElementById("background");
    var ctx=c.getContext("2d");
    ctx.translate(0.5, 0.5);
    var c2 = document.getElementById("foreground");
    var ctx2 = c2.getContext("2d");
    ctx2.translate(0.5, 0.5);
    ctx2.clearRect(0,0,window.innerWidth, window.innerHeight);
    buildmenu();
}
