<?php
	header('content-type: text/css');
        ob_start('ob_gzhandler');
        header('Cache-Control: max-age=31536000, must-revalidate');

        include_once('../model/connexion_sql.php');

        include_once('../model/design.php');

        include_once('style.php');

        include_once('nav.php');
?>

form.formit {
    margin-left: 10px;
}

.formit input[type="text"] {
    padding: 15px 22px;
    height: 20px;
    width: 230px;
    border: 1px solid #bbbbbb;
    margin: 0px 18px 20px 0px;
    font-size: 75%;
    color: #010f5f;
    font-weight: 300;
    letter-spacing: 1px;
}

.formit textarea {
    width: 900px;
    height: 146px;
    margin-bottom: 22px;
    resize: none;
    padding: 20px;
    font-size: 90%;
    border: 1px solid #bbbbbb;
}

form.formit .button_submit {
    cursor:pointer;
    background-color: #e66e0d;
    width: 200px;
    height: 58px;
    color: #fff;
    font-size: 10pt;
    font-weight: 400;
    letter-spacing: 1px;
    border: 5px solid #fff;
    -webkit-background-clip: padding-box;
    background-clip: padding-box;
    box-shadow: 0px 0px 0px 1px #dbdbdb;
    text-shadow: 0px 1px #d72d05;
}


.contactinfo {
    position: relative;
    float: left;
    margin-right: 40px;
}

.contactinfo .ico_mapmark:before, .contactinfo .ico_message:before, .contactinfo .ico_iphone:before {
    font-size: 140%;
    top: 0;
    left: 10px;
}

.contactinfo b {
    font-size: 110%;
    font-weight: 300;
    padding-left: 45px;
}

.mapit {
    width: 940px;
    margin: 30px 0 0 10px;
}


<?php
	include_once('footer.php');
?>

