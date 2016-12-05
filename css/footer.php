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

footer
{
	position: relative;
	display: block;
	background-color: <?php echo $color['background_element']; ?>;
	box-shadow: 5px 0px 5px 1px rgba(0, 0, 0, 0.7);
	margin-top: 100px;
	padding-top: 10px;
	padding-bottom: 10px;
}

.footer_logo
{
	position: relative;
	display: block;
	width: 150px;
	margin-left: 20px;
}

.copyright
{
	position: relative;
	display: block;
	width: 220px;
	height: 20px;
	color: <?php echo $color['text_color']; ?>;
	margin-left: 0px;
	margin-bottom: 10px;
	background-color: <?php echo $color['background_1']; ?>;
	border-radius: 0px 2px 2px 0px;
	box-shadow: 0px 1px 5px 1px rgba(0, 0, 0, 0.7);
}

.copyright_text a
{
	margin-left: 10px;
	color: <?php echo $color['text_color']; ?>;
	text-decoration: none;
}

.copyright_text a:hover
{
	color: white;
}

.links_footer
{
	position: relative;
	display: flex;
	justify-content: space-between;
}

.text_footer
{
	line-height: 20pt;
	color: <?php echo $color['text_color']; ?>;
	margin-right: 10%;
	margin-bottom: 20px;
	text-align: center;
}

.text_footer a
{
	color: <?php echo $color['text_color']; ?>;
	text-decoration: none;
}

.text_footer a:hover
{	
	color: white;
}
