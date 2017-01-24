<?php
header('content-type: text/css');
ob_start('ob_gzhandler');
header('Cache-Control: max-age=31536000, must-revalidate');

include_once('../model/connexion_sql.php');

include_once('../model/design.php');

include_once('style.php');

include_once('nav.php');
?>

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

<?php
include_once('footer.php');
?>
