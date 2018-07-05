
function addpointtogravigon(planet, event){
    var relx = event.clientX - planet.attrp.x;
    var rely = event.clientY-planet.attrp.y;
    if(planet.polygonlist.length == 0){
	planet.polygonlist = [new Point(relx, rely, 0,0)];
	selectedgravigonpoint = 0;
    }else{
	var aindex = angleindex(planet.polygonlist, event.clientX-planet.attrp.x, event.clientY-planet.attrp.y);
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
function angleindex(pl, x, y){
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


function nearestGravigonIndex(event){
    var lowestmag = -1;
    var lowestindex = 0;
    planet = planets[selectedplanetindex];
    pl = planet.polygonlist;
    for(var i = 0; i<pl.length;i+=1){
	var mag = 0;
	var p = pl[i];
	mag = dist(p.x+planet.attrp.x, p.y+planet.attrp.y, event.clientX, event.clientY); 
	if(mag<lowestmag || lowestmag == -1){
	    lowestmag = mag;
	    lowestindex = i;
	}
    }
    
    return lowestindex;
}
