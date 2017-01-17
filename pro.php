<?php
session_start();
include_once('model/connexion_sql.php');
?>
# TODO Changer le nom de cette page
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Cairn Devices – Upgrade in freedom</title>
	<link href="css/pro" rel="stylesheet" />
	<script type="text/javascript" src="js/piwik/piwik.js"></script>
</head>

<div class="conteneur" >
	<?php
	include_once('controller/pro.php');
	?>
</div>

<html>
