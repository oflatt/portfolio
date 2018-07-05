
function drawpolygon(planet){
    pl = planet.polygonlist;
    if(pl != null){
	for(var i = 0;i<planet.length-1;i++){
	    var c=document.getElementById("foreground");
	    var ctx=c.getContext("2d");
	    ctx.strokeStyle = "white";
	    ctx.beginPath();
	    ctx.moveTo(pl[i].x, pl[i].y);
	    ctx.lineTo(pl[(i+1)%planet.length].x, pl[(i+1)%planet.length].y);
	    ctx.stroke();
	}
    }
}
