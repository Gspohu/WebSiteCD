.header
{
	display: flex;
	justify-content: center;
	align-items: flex-start;
	width: 100%;
	height: 75px;
}

.titleLogoName
{
	display: flex;
	height: 100%;
	justify-content: flex-start;
	align-items: center;
	font-size: 15pt;
	letter-spacing: 1px;
	float: left;
	background-color: rgba(42, 42, 42, 0.8);
	flex: 1;
}

.titleLogoName img
{
	width: auto;
	height: 65px;
	margin-top: 5px;
	margin-left: 30px;
	float: left;
}

.titleLogoName a
{
	text-decoration: none;
	color: rgb(240, 240, 240);
	font-size: 20px;
	font-weight: normal;
	margin-left: 5px;
}

/* ----- Menu ----- */

#menu
{
	font-size: 95%;
}

#menu ul li
{
	float: right;
	display: inline;
	overflow: hidden;
}

#menu ul li a
{
	text-decoration: none;
	color: rgb(240, 240, 240);
	font-size: 16px;
	letter-spacing: 1px;
	display: block;
	padding: 28px 30px 0;
	height: 47px;
	background-color: rgba(42, 42, 42, 0.8);
}

#menu ul li a:hover
{
	background-color: rgba(0, 0, 0, 0.1);
	color: rgb(255, 255, 255);
	text-shadow: 1px 1px 3px rgb(0, 0, 0);
}

#menu ul li a.active
{
	color: rgb(255, 255, 255);
	text-shadow: 1px 1px 3px rgb(0, 0, 0);
	background-color: rgba(0, 0, 0, 0.1);
}

.navIcon
{
	display: none;
}

/* Style for mobile (>900px) */

@media all and (max-width: 1000px)
{
	/* TODO mutiplier par deux la hauteur de la bar de nav centrer le logo virer le nom CD mettre un boutton trois bars sur le coté gauche et afficher au clic le nav en fixed */

	.header
	{
		display: flex;
		justify-content: center;
		align-items: center;
		height: 140px;
		background-color: rgba(42, 42, 42, 0.8);
	}

	.titleLogoName
	{
		float: none;
		justify-content: center;
		background: none;
	}

	.titleLogoName img
	{
		width: auto;
		height: 100px;
	}

	.navIcon
	{
		display: block;
		float: right;
		margin-right: 30px;
		font-size: 60px;
		color: rgb(240, 240, 240);
	}

	.companyName
	{
		display: none;
	}

	.titleLogoName a
	{
		font-size: 22px;
	}

	#menu
	{
		display: none;
	}

	#menu ul li a
	{
		font-size: 18px;
	}
}
