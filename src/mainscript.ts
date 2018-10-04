
var mapoldcolors: { [id: string]: string; } = { };
const buttondarkening = 30;

function rgbtolist(rgbstring:string):number[]{
    let colorsOnlys = rgbstring.substring(rgbstring.indexOf('(') + 1, rgbstring.lastIndexOf(')'));
    let colorsOnlyStrings:string[] = colorsOnlys.split(/,\s*/);
    let colorsOnly:number[] = []
    for(let i:number = 0; i<colorsOnlyStrings.length;i++){
	colorsOnly[i] = parseInt(colorsOnlyStrings[i]);
    }
    return colorsOnly;
}

function getrgb(rgb:number[]):string{
    return "rgb("+rgb[0].toString()+","+rgb[1].toString()+","+rgb[2].toString()+")"
}

function buttonhover(button: HTMLElement){
    let current:number[] = rgbtolist(button.style.backgroundColor);
    mapoldcolors[button.id] = button.style.backgroundColor;
    for(let i:number = 0;i<current.length;i++){
	current[i] = current[i]-buttondarkening;
    }
    button.style.backgroundColor = getrgb(current);
}

function buttonoff(button:HTMLElement){
    button.style.backgroundColor = mapoldcolors[button.id];
}

function texthover(button: HTMLElement){
    let current:number[] = rgbtolist(button.style.color);
    mapoldcolors[button.id] = button.style.color;
    for(let i:number = 0;i<current.length;i++){
	current[i] = current[i]-buttondarkening;
    }
    button.style.color = getrgb(current);
}

function textoff(button:HTMLElement){
    button.style.color = mapoldcolors[button.id];
}

function myonscroll(){
    let texts:HTMLCollectionOf<Element> = document.getElementsByClassName("navtext");
    const n:number = texts.length;
    for(let i=0;i<n;i++){
	let e:HTMLElement =  <HTMLElement>texts[i];
	let closeness:number= Math.abs((parseInt(e.style.top)/window.innerHeight)-(document.body.scrollTop/document.body.offsetHeight))
	let size:number = (10/(closeness*n+1))+10-1;
	e.style.fontSize = size.toString() + "px";
    }

    // add a new element if the scrollbar is far enough
    if(document.body.scrollTop > document.body.offsetHeight-window.innerHeight-5){
	loadnew();
    }
}

var loadposition:number = 0;

function loadnew(){
    var nextpost:HTMLElement = document.createElement("div");
    
    var elem = document.querySelector('.container');
    var filenames:string[] = elem.getAttribute("data-postlist").split(",");
    if(loadposition<filenames.length){
	nextpost.setAttribute("w3IncludeHtml","./posts/" + filenames[loadposition] + ".html");
	
	elem.appendChild(nextpost);
	includeHTML();

	loadposition = loadposition + 1;
    }
}

function setup(){
    document.body.onscroll = myonscroll;
    loadnew();
    loadnew();
    loadnew();
    setnavtextpositions();
}

function setnavtextpositions(){
    let posts:HTMLCollectionOf<Element> = document.getElementsByClassName("post");
    
    let texts:HTMLCollectionOf<Element> = document.getElementsByClassName("navtext");
    const n:number = texts.length;


    var elem = document.querySelector('.container');
    var filenames:string[] = elem.getAttribute("data-postlist").split(",");
    const numofposts = filenames.length;
    
    for(let i=0;i<n;i++){
	let posttop:number = (<HTMLElement>posts[i]).offsetTop
	let e:HTMLElement =  <HTMLElement>texts[i];
	e.style.top = (posttop*window.innerHeight/document.body.scrollHeight).toString();
	e.style.visibility = "visible";
    }
    
    let loadmore:HTMLElement = document.getElementById("load more");
    loadmore.style.visibility = "visible";
    
    // hide load more button when done loading
    if(loadposition>=numofposts){
	loadmore.style.visibility = "hidden";
    }
    myonscroll();
    setTimeout(setnavtextpositions, 100);
}

function includeHTML() {
    var i, file, xhttp;
    var elmnt:Element;
    /*loop through a collection of all HTML elements:*/
    var z:HTMLCollectionOf<Element> = document.getElementsByTagName("*");
    for (i = 0; i < z.length; i++) {
	elmnt = z[i];
	/*search for elements with a certain atrribute:*/
	file = elmnt.getAttribute("w3IncludeHtml");
	if (file) {
	    /*make an HTTP request using the attribute value as the file name:*/
	    xhttp = new XMLHttpRequest();
	    xhttp.onreadystatechange = function() {
		if (this.readyState == 4) {
		    if (this.status == 200) {elmnt.innerHTML = this.responseText;}
		    if (this.status == 404) {elmnt.innerHTML = "Page not found.";}
		    /*remove the attribute, and call this function once more:*/
		    elmnt.removeAttribute("w3IncludeHtml");
		    includeHTML();
		}
	    } 
	    xhttp.open("GET", file, true);
	    xhttp.send();
	    /*exit the function:*/
	    return;
	}
    }
}

window.onload = setup;
