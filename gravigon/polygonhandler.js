
function addpointtogravigon(planet, event){
    var relx = event.clientX - planet.attrp.x;
    var rely = event.clientY-planet.attrp.y;
    if(planet.polygonlist.length == 0){
	planet.polygonlist = [new Point(relx, rely, 0,0)];
	selectedgravigonpoint = 0;
    }else{
	var aindex = angleindexfrompoint(planet.polygonlist, event.clientX-planet.attrp.x, event.clientY-planet.attrp.y);
	planet.polygonlist.splice(aindex+1, 0, new Point(relx, rely, 0, 0));
	selectedgravigonpoint = aindex+1;
    }
}

function drawpolygon(planet){
    pl = planet.polygonlist;
    var c=document.getElementById("foreground");
    var ctx=c.getContext("2d");

    if(pl.length == 1){
	ctx.fillStyle = "white";
	ctx.fillRect(pl[0].x, pl[0].y, 5, 5);
    }
    
    for(var i = 0;i<pl.length;i++){
	ctx.strokeStyle = "white";
	ctx.beginPath();
	ctx.moveTo(pl[i].x + planet.attrp.x, pl[i].y+planet.attrp.y);
	ctx.lineTo(pl[(i+1)%pl.length].x+planet.attrp.x, pl[(i+1)%pl.length].y+planet.attrp.y);
	ctx.stroke();
    }

}

function betweenmodular(min, max, num){
    if (max > min) {
	return num <= max && num >= min;
    } else {
	return num > min || num < max;
    }
}

//takes a polygon list and a x and y and returns the index of the point at the angle before the x and y
function angleindexfrompoint(pl, x, y){
    if(pl.length<=1){
	return 0;
    }else{
	var aindex = 0;
	for(var i = 0;i<pl.length;i++){
	    if(betweenmodular(getangle(pl[i].x, pl[i].y), getangle(pl[(i+1)%pl.length].x, pl[(i+1)%pl.length].y), getangle(x, y))){
		aindex = i;
		break;
	    }
	}
	return aindex;
    }
}


function getangle(x, y){
    return Math.atan2(y, x)+Math.PI;
}


function nearestGravigonIndex(xpos, ypos){
    var lowestmag = -1;
    var lowestindex = 0;
    planet = planets[selectedplanetindex];
    pl = planet.polygonlist;
    for(var i = 0; i<pl.length;i+=1){
	var mag = 0;
	var p = pl[i];
	mag = dist(p.x+planet.attrp.x, p.y+planet.attrp.y, xpos, ypos); 
	if(mag<lowestmag || lowestmag == -1){
	    lowestmag = mag;
	    lowestindex = i;
	}
    }
    
    return lowestindex;
}


function insidepolygon(point, pl) {
    // ray-casting algorithm based on
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

    var x = point[0], y = point[1];

    var inside = false;
    for (var i = 0, j = pl.length - 1; i < pl.length; j = i++) {
        var xi = pl[i].x, yi = pl[i].y;
        var xj = pl[j].x, yj = pl[j].y;

        var intersect = ((yi > y) != (yj > y))
            && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }
    
    return inside;
}

// given an angle from the planet, find the magnitude from that planet to the gravigon surrounding it
// If there are not three or more points, it returns a constant of one fourth the screen's height
// x and y are screen positions, not relative positions
function magnitudeat(planet, x, y){
    pl = planet.polygonlist;
    if(pl.length<=2){
	return window.innerHeight/4;
    }else{
	var pointdist = dist(0,0,x-planet.attrp.x,y-planet.attrp.y);
	var ux = (x-planet.attrp.x)/pointdist;
	var uy = (y-planet.attrp.y)/pointdist;
	var pointindex = angleindexfrompoint(pl, ux, uy);

	var px = pl[pointindex].x;
	var py = pl[pointindex].y;
	var sx = pl[(pointindex+1)%pl.length].x-pl[pointindex].x;
	var sy = pl[(pointindex+1)%pl.length].y-pl[pointindex].y;

	var mag = (py*sx-px*sy)/(uy*sx-sy*ux);

	//draw point on line
	var c = document.getElementById("foreground");
	var ctx = c.getContext("2d");
	ctx.fillStyle = "rgb(255, 0, 0)";
	ctx.fillRect(ux*mag+planet.attrp.x, uy*mag+planet.attrp.y, 2, 2);

	return mag;
    }
}
