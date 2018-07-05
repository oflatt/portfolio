function openNav() {
    menuupp = true;
    document.getElementById("myNav").style.width = "25%";
}

function closeNav() {
    menuupp = false;
    document.getElementById("myNav").style.width = "0%";
}

function toolbuttonClicked(event){
    buttonClicked(event.target.textContent || event.target.innerText);
}

function buttonClicked(name){
    buttons = document.getElementsByClassName("mybtn");
    for(i = 0; i < buttons.length;i+=1){
	if((buttons[i].textContent || buttons[i].innerText) == name){
	    buttons[i].style.border = "2px solid rgb(255,255,0)";
	    currenttool = buttons[i].textContent || buttons[i].innerText;
	}else{
	    buttons[i].style.border = "2px solid black";
	}
    }
}

function defaultonclick(){
}

function rgbtolist(rgbstring){
    colorsOnly = rgbstring.substring(rgbstring.indexOf('(') + 1, rgbstring.lastIndexOf(')')).split(/,\s*/);
    return colorsOnly;
}

var buttondarkening = 50;

function buttonhover(button){
    var current = rgbtolist(button.style.backgroundColor);
    button.oldcolor = button.style.backgroundColor;
    for(var i = 0;i<current.length;i++){
	current[i] = current[i]-buttondarkening;
    }
    button.style.backgroundColor = getrgb(current);
}

function buttonoff(button){
    button.style.backgroundColor = button.oldcolor;
}

function addbutton(name, color, onp, onclickfunction, helptext){
    onp = onp || false;
    onclickfunction = onclickfunction || defaultonclick;

    var div = document.createElement("div");
    div.className = "btncontainer";
    
    var b = document.createElement("BUTTON");
    b.className = "mybtn";
    b.style.backgroundColor = color;
    var t = document.createTextNode(name);
    b.appendChild(t);
    if(onp){
	b.style.border = "2px solid rgb(255,255,0)";
    }else{
	b.style.border = "2px solid black";
    }
    b.onclick = onclickfunction;
    b.onmouseover = function(){buttonhover(this)};
    b.onmouseleave = function(){buttonoff(this)};


    var tip = document.createElement("span");
    tip.className = "tooltip";
    var tipt = document.createTextNode(helptext);
    tip.appendChild(tipt);

    div.appendChild(b);
    div.appendChild(tip);
    
    var content = document.getElementById("overlay-content");
    content.appendChild(div);
}

function addsection(name){
    var s = document.createElement("section");
    var t = document.createTextNode(name);
    s.appendChild(t);
    document.getElementById("overlay-content").appendChild(s);
}

function buildmenu(){
    addsection("tools");
    addbutton("asteroid", "rgb(0,255,0)", true, toolbuttonClicked, "(a) Change the position and velocity of the asteroid being affected by the forces.");
    addbutton("split force", "rgb(255,0,0)", false, toolbuttonClicked, "(s) Move the attraction point (blue) and the distance point (red) using the left and right mouse buttons separately. The distance point is used in calculating strength of gravity while it is applied towards the attraction point.");
    addbutton("move force", "rgb(75, 0, 130)", false, toolbuttonClicked, "(m) Move the nearest force, joining attraction and distance.");
    addbutton("new force", "rgb(147, 112, 219)", false, toolbuttonClicked, "(n) Create a new force, placing it.");
    addbutton("delete force", "rgb(100, 100, 100)", false, toolbuttonClicked, "(d or DEL) Delete the nearest force.");
    addbutton("select force", "rgb(200, 200, 0)", false, toolbuttonClicked, "(r) Select the nearest force. A polygon drawn around it will then apply to it.");

    addsection("settings");
    addbutton("clear all", "rgb(200,200,200)", false, reset, "Reset everything, just like loading again.");
}
