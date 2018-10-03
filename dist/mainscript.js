"use strict";
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
function texthover(button) {
    var current = rgbtolist(button.style.color);
    mapoldcolors[button.id] = button.style.color;
    for (var i = 0; i < current.length; i++) {
        current[i] = current[i] - buttondarkening;
    }
    button.style.color = getrgb(current);
}
function textoff(button) {
    button.style.color = mapoldcolors[button.id];
}
function myonscroll() {
    alert("ran");
    var texts = document.getElementsByClassName("navtext");
    var n = texts.length;
    for (var i = 0; i < n; i++) {
        var e = texts[i];
        var closeness = Math.abs((parseInt(e.style.top) / window.innerHeight) - (document.body.scrollTop / document.body.offsetHeight));
        var size = (closeness * n) + 14;
        e.style.fontSize = size.toString() + "px";
    }
}
function setup() {
    setnavtextpositions();
    document.body.addEventListener("scroll", myonscroll);
}
function setnavtextpositions() {
    var texts = document.getElementsByClassName("navtext");
    var n = texts.length;
    for (var i = 0; i < n; i++) {
        var e = texts[i];
        e.style.top = ((window.innerHeight / (n + 1)) * (i + 1)).toString() + "px";
        e.style.visibility = "visible";
    }
}
window.onload = setup;
