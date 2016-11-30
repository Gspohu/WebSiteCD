<?php
	header('content-type: text/css');
        ob_start('ob_gzhandler');
        header('Cache-Control: max-age=31536000, must-revalidate');

        include_once('../model/connexion_sql.php');

        include_once('../model/design.php');

        include_once('style.php');

        include_once('nav.php');
?>

#main_part, #main_part_inner {
    width: 100%;
    height: 465px;
    background: url('img/main_img_1.jpg') scroll no-repeat center;
    background-color: #000;
    border-bottom: 7px solid #e5e5e5;
}

#main_part_in, #main_part_inner_in {
    width: 960px;
    margin: auto;
}

#main_part_in h2, #main_part_inner_in h2 {
    padding-top: 120px;
    padding-bottom: 14px;
    font-size: 280%;
    font-weight: 200;
    text-align: center;
    color: #fff;
    text-shadow: 0px 1px #000;
}

#main_part_in p {
    font-size: 150%;
    font-weight: 300;
    color: #bcbcbc;
    text-align: center;
    text-shadow: 0px 1px #000;
}

#main_part .button_main {
    margin-top: 60px;
}

#content {
    width: 960px;
    margin: auto;
    padding-top: 40px;
}

#content_inner {
    width: 960px;
    margin: auto;
    padding-top: 0;
}

.banner1 {
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

.banner1 p {
    font-weight: 200; 
    font-size: 20pt;
    display: block;
    width: 630px;
    text-shadow: 0px 1px #000;
}

.banner1 p b {
    color: #fff;
    font-weight: 300;
}

.banner1 a.button_dark {
    width: 100px;
    position: absolute;
    right: 42px;
    top: 30px;
}

<?php
	include_once('footer.php');
?>

