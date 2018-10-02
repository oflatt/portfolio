

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

