<?php
        header('content-type: text/css');
        header('Cache-Control: max-age=31536000, must-revalidate');
?>

a,
abbr,
acronym,
address,
applet,
article,
aside,
audio,
b,
big,
blockquote,
body,
canvas,
caption,
center,
cite,
code,
dd,
del,
details,
dfn,
dialog,
div,
dl,
dt,
em,
embed,
fieldset,
figcaption,
figure,
font,
footer,
form,
h1,
h2,
h3,
h4,
h5,
h6,
header,
hgroup,
hr,
html,
i,
iframe,
img,
ins,
kbd,
label,
legend,
li,
main,
mark,
menu,
meter,
nav,
object,
ol,
output,
p,
pre,
progress,
q,
rp,
rt,
ruby,
s,
samp,
section,
small,
span,
strike,
strong,
sub,
summary,
sup,
table,
tbody,
td,
tfoot,
th,
thead,
time,
tr,
tt,
u,
ul,
var,
video,
xmp 
{
  border: 0;
  margin: 0;
  padding: 0;
  font-size: 100%;
}

html,
body 
{
  height: 100%;
}

article,
aside,
details,
figcaption,
figure,
footer,
header,
hgroup,
main,
menu,
nav,
section 
{
  display: block;
}

b,
strong 
{
  font-weight: bold;
}

img 
{
  color: transparent;
  font-size: 0;
  vertical-align: middle;
  -ms-interpolation-mode: bicubic;
}

ol,
ul 
{
  list-style: none;
}

li 
{
  display: list-item;
}

table 
{
  border-collapse: collapse;
  border-spacing: 0;
}

th,
td,
caption 
{
  font-weight: normal;
  vertical-align: top;
  text-align: left;
}

q 
{
  quotes: none;
}

q:before,
q:after 
{
  content: "";
  content: none;
}

sub,
sup,
small 
{
  font-size: 75%;
}

sub,
sup 
{
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub 
{
  bottom: -0.25em;
}

sup 
{
  top: -0.5em;
}

svg 
{
  overflow: hidden;
}

body {
    font-family: 'Source Sans Pro', sans-serif;
}

@font-face {
  font-family: "linecons";
  src: url('fonts/linecons.eot');
  src: url('fonts/linecons.eot?#iefix') format('eot'), 
    url('fonts/linecons.woff') format('woff'), 
    url('fonts/linecons.ttf') format('truetype'), 
    url('fonts/linecons.svg#linecons') format('svg');
  font-weight: normal;
  font-style: normal;
}

h3 {
    font-size: 180%;
    font-weight: 300;
    margin: 46px 0 30px 10px;
}

h4 {
    font-size: 120%;
    font-weight: 400;
    color: #fff;
}

a {
    color: #e66e0d;
}

p a {
    -webkit-transition: all 0.3s ease-in-out;
    -moz-transition: all 0.3s ease-in-out;
    -o-transition: all 0.3s ease-in-out;
    -ms-transition: all 0.3s ease-in-out;
    transition: all 0.3s ease-in-out;
}

a:hover {
    color: #000;
}

a.button_dark, a.button_light {
    background-color: #e66e0d;
    display: block;
    width: 90px;
    padding: 15px 30px 0 30px;
    height: 33px;
    text-align: center;
    margin: auto;
    z-index: 2;
    position: relative;
    color: #fff;
    font-size: 11pt;
    font-weight: 400;
    text-decoration: none;
    letter-spacing: 1px;
    text-shadow: 0px 1px #d72d05;
    border: 5px solid rgba(0, 0, 0, .2);
    -webkit-background-clip: padding-box;
    background-clip: padding-box;
    box-shadow: inset 0px 1px #f08715;
    
    -webkit-transition: all 0.2s ease-in-out;
    -moz-transition: all 0.2s ease-in-out;
    -o-transition: all 0.2s ease-in-out;
    -ms-transition: all 0.2s ease-in-out;
    transition: all 0.2s ease-in-out;
}

a.button_light {
    margin-left: 10px;
    width: 100px;
    border: 5px solid #fff;
    -webkit-background-clip: padding-box;
    background-clip: padding-box;
    box-shadow: 0px 0px 0px 1px #dbdbdb;
}

a:hover.button_dark, a:hover._button_light {
    background-color: #d76203;
    text-shadow: 0px -1px #a70d00;
    border: 5px solid rgba(0, 0, 0, .4);
    -webkit-background-clip: padding-box; /* for Safari */
    background-clip: padding-box;
    box-shadow: inset 0px 1px 2px #c14d00;
}

a:hover.button_light {
    background-color: #d76203;
    border: 5px solid #f5f5f5;
    box-shadow: 0px 0px 0px 1px #cbcbcb;
}

.moreabout .button_dark {
    margin: 0;
}

.pxline {
    height: 1px;
    width: 80%;
    background-color: #fff;
    color: #fff;
    opacity: 0.1;
    position: relative;
    top: 30px;
    z-index: 1;
    margin-left: 10%;
}

hr.cleanit {
    visibility: hidden;
    clear: both;
    margin-bottom: 20px;
}

div.cara {
    clear: both;
    width: 940px;
    height: 1px;
    background-color: #cccccc;
    margin-top: 40px;
    margin-left: 10px;
}

