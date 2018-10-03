
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
    alert("ran");
    let texts:HTMLCollectionOf<Element> = document.getElementsByClassName("navtext");
    const n:number = texts.length;
    for(let i=0;i<n;i++){
	let e:HTMLElement =  <HTMLElement>texts[i];
	let closeness:number= Math.abs((parseInt(e.style.top)/window.innerHeight)-(document.body.scrollTop/document.body.offsetHeight))
	let size:number = (closeness*n)+14;
	e.style.fontSize = size.toString() + "px";
    }
}

function setup(){
    setnavtextpositions();
    document.body.addEventListener("scroll", myonscroll);
}

function setnavtextpositions(){
    let texts:HTMLCollectionOf<Element> = document.getElementsByClassName("navtext");
    const n:number = texts.length;
    for(let i=0;i<n;i++){
	let e:HTMLElement =  <HTMLElement>texts[i];
	e.style.top = ((window.innerHeight/(n+1))*(i+1)).toString()+"px";
	e.style.visibility = "visible";
    }
}

window.onload = setup;
