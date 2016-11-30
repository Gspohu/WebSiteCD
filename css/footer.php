<?php
	header('content-type: text/css');
	header('Cache-Control: max-age=31536000, must-revalidate');
?>


#footer {
    width: 100%;
    height: 182px;
    background: url('img/bg_footer.jpg') scroll no-repeat center;
    background-color: #000;
    color: #a5a5a5;
    font-weight: 300;
    font-size: 90%;
    margin-top: 80px;
}

#footer_in {
    width: 960px;
    margin: auto;
    position: relative;
    padding-top: 50px;
}

#footer_in p {
    float: left;
}

#footer_in a {
    color: #fff;
    text-decoration: none;
}

#footer_in a:hover {
    color: #fff;
    text-decoration: underline;
}

#footer_in span {
    position: absolute;
    right: 10px;
}
