<?php
session_start();
include_once('model/connexion_sql.php');
?>

<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Cairn Devices – Upgrade in freedom</title>
	<link href="css/about" rel="stylesheet" />
	<script type="text/javascript" src="js/piwik/piwik.js"></script>
</head>

<div class="conteneur" >
	<?php
	include_once('controller/about.php');
	?>
</div>

<html>
