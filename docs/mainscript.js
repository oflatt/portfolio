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
    var texts = document.getElementsByClassName("navtext");
    var posts = document.getElementsByClassName("post");
    var n = texts.length;
    var setbigp = false;
    for (var i = 0; i < n; i++) {
        var e = texts[i];
        if (setbigp) {
            e.style.fontSize = "10px";
        }
        else {
            var postmid = (posts[i].getBoundingClientRect().top + posts[i].getBoundingClientRect().bottom) / 2;
            if (postmid >= 0) {
                e.style.fontSize = "20px";
                setbigp = true;
            }
            else {
                e.style.fontSize = "10px";
            }
        }
    }
    // add a new element if the scrollbar is far enough
    if (document.body.scrollTop > document.body.offsetHeight - window.innerHeight - window.innerHeight / 4.0) {
        loadnew();
    }
}
var loadposition = 0;
function loadnew() {
    var nextpost = document.createElement("div");
    var elem = document.querySelector('.container');
    var filenames = elem.getAttribute("data-postlist").split(",");
    if (loadposition < filenames.length) {
        nextpost.setAttribute("w3IncludeHtml", "./posts/" + filenames[loadposition] + ".html");
        elem.appendChild(nextpost);
        includeHTML();
        loadposition = loadposition + 1;
    }
}
function setup() {
    document.body.onscroll = myonscroll;
    loadnew();
    loadnew();
    loadnew();
    setnavtextpositions();
}
function setnavtextpositions() {
    var texts = document.getElementsByClassName("navtext");
    var n = texts.length;
    var elem = document.querySelector('.container');
    var filenames = elem.getAttribute("data-postlist").split(",");
    var numofposts = filenames.length;
    var spacing = window.innerHeight / (n + 2);
    for (var i = 0; i < n; i++) {
        var e = texts[i];
        var halfheight = e.clientHeight / 2;
        e.style.top = (-halfheight + spacing * i + window.innerHeight / 15).toString();
        e.style.visibility = "visible";
    }
    var loadmore = document.getElementById("load more");
    loadmore.style.visibility = "visible";
    // hide load more button when done loading
    if (loadposition >= numofposts) {
        loadmore.style.visibility = "hidden";
    }
    myonscroll();
    setTimeout(setnavtextpositions, 100);
}
function includeHTML() {
    var i, file, xhttp;
    var elmnt;
    /*loop through a collection of all HTML elements:*/
    var z = document.getElementsByTagName("*");
    for (i = 0; i < z.length; i++) {
        elmnt = z[i];
        /*search for elements with a certain atrribute:*/
        file = elmnt.getAttribute("w3IncludeHtml");
        if (file) {
            /*make an HTTP request using the attribute value as the file name:*/
            xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function () {
                if (this.readyState == 4) {
                    if (this.status == 200) {
                        elmnt.innerHTML = this.responseText;
                    }
                    if (this.status == 404) {
                        elmnt.innerHTML = "Page not found.";
                    }
                    /*remove the attribute, and call this function once more:*/
                    elmnt.removeAttribute("w3IncludeHtml");
                    includeHTML();
                }
            };
            xhttp.open("GET", file, true);
            xhttp.send();
            /*exit the function:*/
            return;
        }
    }
}
window.onload = setup;
