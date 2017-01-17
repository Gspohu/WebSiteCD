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

body
{
	font-family: 'Source Sans Pro', sans-serif;
}

@font-face
{
	font-family: "linecons";
	src: url('fonts/linecons.eot');
	src: url('fonts/linecons.eot?#iefix') format('eot'),
	url('fonts/linecons.woff') format('woff'),
	url('fonts/linecons.ttf') format('truetype'),
	url('fonts/linecons.svg#linecons') format('svg');
	font-weight: normal;
	font-style: normal;
}

h3
{
	font-size: 180%;
	font-weight: 300;
	margin: 46px 0 30px 10px;
}

h4
{
	font-size: 120%;
	font-weight: 400;
	color: #fff;
}

a
{
	color: #e66e0d;
}

p a
{
	-webkit-transition: all 0.3s ease-in-out;
	-moz-transition: all 0.3s ease-in-out;
	-o-transition: all 0.3s ease-in-out;
	-ms-transition: all 0.3s ease-in-out;
	transition: all 0.3s ease-in-out;
}

a:hover
{
	color: #000;
}

a.button_light
{
	margin-left: 10px;
	width: 100px;
	border: 5px solid #fff;
	-webkit-background-clip: padding-box;
	background-clip: padding-box;
	box-shadow: 0px 0px 0px 1px #dbdbdb;
}

.moreabout .button_dark
{
	margin: 0;
}

.pxline
{
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

hr.cleanit
{
	visibility: hidden;
	clear: both;
	margin-bottom: 20px;
}

div.cara
{
	clear: both;
	width: 940px;
	height: 1px;
	background-color: #cccccc;
	margin-top: 40px;
	margin-left: 10px;
}
