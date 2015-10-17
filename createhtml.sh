#!/bin/bash
# Code is GPL-2.0
# CSS and table html from http://johnsardine.com/freebies/dl-html-css/simple-little-tab/
# Code Generates a page to display thumbnailed images

error="\e[31mError:\e[0m"
notice="\e[93mNotice:\e[0m"

# Check for images directory.
if [[ ! -d images ]]
  then
    echo -e "$error No images folder found!"
    read -p "Do you want to create it (y/n)? "  -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
     then
       mkdir images
     else
       echo ""
       echo -e "$error Cannot continue without images folder."
       exit 1
    fi
    
fi

# Check for convert by imagemagick
if [[ ! -f /usr/bin/convert ]]
  then
    echo -e "$error ImageMagick not installed. Cannot find /usr/bin/convert"
    exit 1
fi

# Check if images folder empty
if [[ $(find images -type f | wc -l) -eq 0 ]]
  then echo -e "$error No files found in images directory."
  exit 1
fi


# Do thumbnails
pushd images
for file in *;do
  if [[ ! $file == thmb* ]]
    then
      if [[ ! -f thmb_$file ]]
      then
        convert -resize 350 "$file" "thmb_$file"
      fi
  fi
done
popd
echo -e "$notice Indexing done. Generating HTML."

# Find images and index them
if [[ -f index ]];then rm index;fi
if [[ -f index.html ]];then rm index.html;fi
find images/ -type f > index
sed -i '/thmb/d' index

# Add initial html

cat <<'EOF' >> index.html
<html>
<head>
<title>Sample Image Collection</title>
<style>
/*
Taken from: http://johnsardine.com/freebies/dl-html-css/simple-little-tab/
Table Style - This is what you want
------------------------------------------------------------------ */
table a:link {
	color: #666;
	font-weight: bold;
	text-decoration:none;
}
table a:visited {
	color: #999999;
	font-weight:bold;
	text-decoration:none;
}
table a:active,
table a:hover {
	color: #bd5a35;
	text-decoration:underline;
}
table {
	font-family:Arial, Helvetica, sans-serif;
	color:#666;
	font-size:12px;
	text-shadow: 1px 1px 0px #fff;
	background:#eaebec;
	margin:20px;
	border:#ccc 1px solid;

	-moz-border-radius:3px;
	-webkit-border-radius:3px;
	border-radius:3px;

	-moz-box-shadow: 0 1px 2px #d1d1d1;
	-webkit-box-shadow: 0 1px 2px #d1d1d1;
	box-shadow: 0 1px 2px #d1d1d1;
}
table th {
	padding:21px 25px 22px 25px;
	border-top:1px solid #fafafa;
	border-bottom:1px solid #e0e0e0;

	background: #ededed;
	background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(#ebebeb));
	background: -moz-linear-gradient(top,  #ededed,  #ebebeb);
}
table th:first-child {
	text-align: left;
	padding-left:20px;
}
table tr:first-child th:first-child {
	-moz-border-radius-topleft:3px;
	-webkit-border-top-left-radius:3px;
	border-top-left-radius:3px;
}
table tr:first-child th:last-child {
	-moz-border-radius-topright:3px;
	-webkit-border-top-right-radius:3px;
	border-top-right-radius:3px;
}
table tr {
	text-align: center;
	padding-left:20px;
}
table td:first-child {
	text-align: left;
	padding-left:20px;
	border-left: 0;
}
table td {
	padding:18px;
	border-top: 1px solid #ffffff;
	border-bottom:1px solid #e0e0e0;
	border-left: 1px solid #e0e0e0;
	
	background: #fafafa;
	background: -webkit-gradient(linear, left top, left bottom, from(#fbfbfb), to(#fafafa));
	background: -moz-linear-gradient(top,  #fbfbfb,  #fafafa);
        text-align: left;
}
table tr.even td {
	background: #f6f6f6;
	background: -webkit-gradient(linear, left top, left bottom, from(#f8f8f8), to(#f6f6f6));
	background: -moz-linear-gradient(top,  #f8f8f8,  #f6f6f6);
}
table tr:last-child td {
	border-bottom:0;
}
table tr:last-child td:first-child {
	-moz-border-radius-bottomleft:3px;
	-webkit-border-bottom-left-radius:3px;
	border-bottom-left-radius:3px;
}
table tr:last-child td:last-child {
	-moz-border-radius-bottomright:3px;
	-webkit-border-bottom-right-radius:3px;
	border-bottom-right-radius:3px;
}
table tr:hover td {
	background: #f2f2f2;
	background: -webkit-gradient(linear, left top, left bottom, from(#f2f2f2), to(#f0f0f0));
	background: -moz-linear-gradient(top,  #f2f2f2,  #f0f0f0);	
}

h2 {
	font-family:Arial, Helvetica, sans-serif;
	color:#666;
	font-size:24px;
}

h4 {
	color:#666;
	font-size:12px;
}

h3 {
	color:#ef2121;
	font-size:12px;
}

hr {
	color:#666;
}
</style>
</head>
<body>
<center><h2>Sample Image Collection</h2>
<table class="tablesorter" cellspacing='0' width="325">
EOF

# List images and thumbnails

while read line
do
  echo "        <tr class=even>" | tee -a index.html
  echo "                <td><a href=\""$line"\"><img src=\"$(echo $line | sed 's/\//\/thmb_/g')\"></img></a><br><center>$(echo $line | cut -d/ -f 2 | cut -d"." -f 1)</center></td>" | tee -a index.html
  echo "        </tr>" | tee -a index.html
done <index

# Add final html bit

cat <<'EOF' >> index.html
        </tbody>
</table>
EOF
echo "<div><small>Made by <a href=mailto:justin.zobel@gmail.com>Justin Zobel</a><br>Last update $(date | sed 's/  / /g')</small></div>" | tee -a index.html
cat <<'EOF' >> index.html
</center>

</body>
</html>
EOF

rm index
echo -e "$notice HTML ready."
