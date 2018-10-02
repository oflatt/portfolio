var mapoldcolors = {};
var buttondarkening = 30;
function rgbtolist(rgbstring) {
    var colorsOnlys = rgbstring.substring(rgbstring.indexOf('(') + 1, rgbstring.lastIndexOf(')'));
    var colorsOnlyStrings = colorsOnlys.split(/,\s*/);
    var colorsOnly = [];
    for (var i = 0; i < colorsOnlyStrings.length; i++) {
        colorsOnly[i] = parseInt(colorsOnlyStrings[i]);
    }
    return colorsOnly;
}
function getrgb(rgb) {
    return "rgb(" + rgb[0].toString() + "," + rgb[1].toString() + "," + rgb[2].toString() + ")";
}
function buttonhover(button) {
    var current = rgbtolist(button.style.backgroundColor);
    mapoldcolors[button.id] = button.style.backgroundColor;
    for (var i = 0; i < current.length; i++) {
        current[i] = current[i] - buttondarkening;
    }
    button.style.backgroundColor = getrgb(current);
}
function buttonoff(button) {
    button.style.backgroundColor = mapoldcolors[button.id];
}
