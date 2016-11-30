<?php
        session_start();
        include_once('model/connexion_sql.php');
?>

<!DOCTYPE html>
<html>
        <head>
                <meta charset="utf-8" />
                <title>Cairn Devices – Upgrade in freedom</title>
                <link href="css/rss" rel="stylesheet" />
        </head>

        <div class="conteneur" >
                <?php
                        include_once('controller/rss.php');
                ?>
        </div>

<html>

