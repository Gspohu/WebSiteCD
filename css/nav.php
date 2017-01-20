#header
{
	width: 100%;
	height: 75px;
	background-color: #fff;
}

#header_in
{
	width: 90%;
	height: 75px;
	margin: auto;
	position: relative;
}

.titleLogoName
{
	display: flex;
	height: 100%;
	justify-content: center;
	align-items: center;
	font-size: 15pt;
	letter-spacing: 1px;
	float: left;
}

.titleLogoName img
{
	width: auto;
	height: 65px;
	margin-top: 5px;
	float: left;
}

.titleLogoName a
{
	text-decoration: none;
	color: #111;
	font-size: 20px;
	font-weight: normal;
	margin-left: 5px;
}

/* ----- Menu ----- */

#menu
{
	position: absolute;
	right: 0;
	width: 80%;
	font-size: 95%;
	background: url('img/menu_cut.jpg') no-repeat scroll right;
	margin-right: 0;
}

#menu ul li
{
	float: right;
	display: inline;
}

#menu ul li a
{
	text-decoration: none;
	color: #101115;
	font-size: 16px;
	letter-spacing: 1px;
	display: block;
	padding: 28px 30px 0;
	height: 47px;
	background-color: #fff;
}

#menu ul li a:hover
{
	background-color: #f3f3f3;
}

#menu ul li a.active
{
	background: none;
	color: #101115;
}
