<?php
header('content-type: text/css');
ob_start('ob_gzhandler');
header('Cache-Control: max-age=31536000, must-revalidate');

include_once('../model/connexion_sql.php');

include_once('../model/design.php');

include_once('style.php');

include_once('nav.php');
?>

#main_part, #main_part_inner
{
	width: 100%;
	height: 465px;
	background-color: rgba(0, 0, 0, 0.1);
}

.imgBackground
{
	position: absolute;
	z-index: -1;
	top: 0;
	width: 100%;
	height: 540px;
	background: url('/images/main_img_1.jpg') scroll no-repeat center;
	background-color: rgb(20, 20, 20);
}

#main_part_in, #main_part_inner_in
{
	width: 960px;
	margin: auto;
}

#main_part_in h2, #main_part_inner_in h2
{
	padding-top: 120px;
	padding-bottom: 14px;
	font-size: 280%;
	font-weight: 200;
	text-align: center;
	color: #fff;
	text-shadow: 1px 1px 3px rgb(0, 0, 0);
}

#main_part_in p
{
	font-size: 150%;
	font-weight: 300;
	color: #bcbcbc;
	text-align: center;
	text-shadow: 0px 1px #000;
}

#main_part .button_main
{
	margin-top: 60px;
}

#content
{
	width: 960px;
	margin: auto;
	padding-top: 40px;
}

#content_inner
{
	width: 960px;
	margin: auto;
	padding-top: 0;
}

.banner1
{
	width: 890px;
	height: 76px;
	padding: 42px 0 0 50px;
	margin: auto;
	margin-bottom: 0px;
	margin-top: 45px;
	background: url('img/banner1.jpg') no-repeat scroll;
	background-color: #000;
	color: #c3ccd5;
	position: relative;
}

.banner1 p
{
	font-weight: 200;
	font-size: 20pt;
	display: block;
	width: 630px;
	text-shadow: 0px 1px #000;
}

.banner1 p b
{
	color: #fff;
	font-weight: 300;
}

.banner1 a.button_dark
{
	width: 100px;
	position: absolute;
	right: 42px;
	top: 30px;
}

a.button_dark
{
	background-color: #0d6ae6;
	display: block;
	width: 90px;
	padding: 20px 30px 20px 30px;
	text-align: center;
	margin: auto;
	z-index: 2;
	position: relative;
	color: #fff;
	font-size: 18px;
	font-weight: 400;
	text-decoration: none;
	text-shadow: 0px 1px #0553d7;
	background-clip: padding-box;
}

a:hover.button_dark
{
	background-color: #036bd7;
}

@media all and (max-width: 1000px)
{
	#main_part, #main_part_inner
	{
		width: 100%;
		height: 400px;
		background-color: rgba(0, 0, 0, 0.1);
	}
}

<?php
include_once('footer.php');
?>
