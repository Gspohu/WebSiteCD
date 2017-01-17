<?php
header('content-type: text/css');
header('Cache-Control: max-age=31536000, must-revalidate');
?>


#header
{
	width: 100%;
	height: 75px;
	background-color: #fff;
}

#header_in
{
	width: 960px;
	height: 75px;
	margin: auto;
	position: relative;
}

.titleLogoName
{
	display: flex;
	justify-content: center;
	align-items: center;
	font-size: 15pt;
	letter-spacing: 1px;
	float: left;
}

.titleLogoName img
{
	width: auto;
	height: 65px;
	margin-top: 5px;
	float: left;
}

.titleLogoName a
{
	text-decoration: none;
	color: #111;
	font-weight: 100;
	margin-left: 5px;
}

/* ----- Menu ----- */
/* TODO Adapt the size of the menu with percent */
#menu
{
	position: absolute;
	right: 00px;
	font-size: 95%;
	background: url('img/menu_cut.jpg') no-repeat scroll right;
	margin-right: 0px;
}

#menu ul li
{
	float: left;
	display: inline;
}

#menu ul li a
{
	text-decoration: none;
	color: #101115;
	text-transform: uppercase;
	font-weight: 300;
	letter-spacing: 1px;
	display: block;
	padding: 29px 30px 0 30px;
	height: 46px;
	background-color: #fff;
}

#menu ul li a:hover
{
	background-color: #f3f3f3;
}

#menu ul li a.active
{
	background: none;
	color: #101115;
}
