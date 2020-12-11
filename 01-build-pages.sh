#! /bin/sh
# vim: set noexpandtab tw=0:
# Rebuild the documentation and upload this to the web server.

set -e # we want to fail on any error instead of risking uploading broken stuff
#set -x

echo
echo "XXX Get the latest translations from git"
git pull
git pull salsa master

curdir=$(pwd)

# Path to po4a sources
srcdir=../po4a

if [ ! -e ${srcdir}/po4a-gettextize ]
then 
	echo "The source tree of po4a does not seem to be in '${srcdir}'."
	echo "Please fix the srcdir variable at the top of this script."
	exit 1
fi

percent_lang() {
	STATS=`msgfmt -o /dev/null --statistics $srcdir/po/pod/$1.po 2>&1`
	YES=`echo $STATS | sed -n -e 's/^\([[:digit:]]*\).*$/\1/p'`
	NO=`echo $STATS | sed -n -e 's/^\([[:digit:]]\+\)[^[:digit:]]\+\([[:digit:]]\+\).*$/\2/p'`
	if [ ! $NO ]; then
		NO=0
	fi
	O3=`echo $STATS | sed -n -e 's/^\([[:digit:]]\+\)[^[:digit:]]\+\([[:digit:]]\+\)[^[:digit:]]\+\([[:digit:]]\+\).*$/\3/p'`
	if [ $O3 ]; then
		NO=$(($NO + $O3))
	fi
	TOTAL=$(($YES+$NO))
	echo $((($YES*100)/$TOTAL))
}

libver=$(grep '^$VERSION =' $srcdir/lib/Locale/Po4a/TransTractor.pm | \
           sed -e 's/^.*"\([^"]*\)".*/\1/')
webver=$(cat VERSION)
if [ "x$libver" = "x$webver" ] ; then
	echo "XXX Regenerating the documentation because the code is at the same version than the website ($libver)"
	cd $srcdir
	LANGS=
	for lang in po/pod/*.po
	do
		LANGS=$LANGS" "$(echo $lang | sed -e 's,^po/pod/,,' -e 's,\.po$,,')
	done

	perl Build.PL
	PO4AFLAGS='-k 0' ./Build
	cd $curdir

	rm -rf html/
	find src -name \*~ -exec rm {} \;
	cp -a $srcdir/blib/man html
	find html -name \*.gz -exec gunzip {} \;
	for f in $(find html/man1 html/*/man1 -name \*.1p); do mv $f ${f%p}; done
	mkdir -p html/en/
	mv html/man* html/en/
	mkdir html/man
	mkdir html/man/man1
	mkdir html/man/man3
	mkdir html/man/man5
	mkdir html/man/man7
else
	echo "XXX Not regenerating the documentation because the webversion ($webver) is not the libversion ($libver)"
fi

echo
echo "XXX Generate the web pages translations with po4a"
PERLLIB=$srcdir/lib $srcdir/po4a --previous -v --msgid-bugs-address devel@lists.po4a.org --package-name po4a --package-version $libver po/html.cfg

for lang in po/www/*.po
do
	lang=$(basename ${lang%.po})
	for f in html/*.$lang
	do
		sed -i -e "s/\.en\"; ?>/\.$lang\"; ?>/" $f
	done
done


if [ "x$libver" = "x$webver" ] ; then
for lang in en $LANGS ; do
	header=header.php.$lang
	[ -e html/$header ] || header=header.php.en
	echo Generate the $lang index

	cat << EOT > html/man/index.php.$lang
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
 <head>
  <link rel="stylesheet"
        title="Default Style"
        type="text/css"
        href="../default.css" >
  <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  <title>Table of Contents</title>
 </head>
 <body>
  <?php \$topdir = "../"; include "../$header"; ?>
  <div id="content">
  <h1>Table of Contents</h1>
   <table>
EOT
	for man in html/en/man*/*
	do
		man=${man#html/en/}
		if test -e html/$lang/$man
		then
			page=html/$lang/$man
		else
			page=html/en/$man
		fi
		title=$(lexgrog "$page" |
		        sed -ne 's/.*: \".* - //;s/"$//;p')
		ref=$man.php
		man=$(basename $man)
		man=$(echo $man | sed -e 's/^\(.*\)\.\([0-9]\(pm\)\?\)$/\1(\2)/')
		cat << EOT >> html/man/index.php.$lang
    <tr>
     <td><a href="$ref">$man</a></td>
     <td>$title</td>
    </tr>
EOT
	done
	cat << EOT >> html/man/index.php.$lang
   </table>
  </div>
  <?php include "footer_index.php"; ?>
  <?php include "../footer.php"; ?>
 </body>
</html>
EOT

	echo "XXX Generate the $lang HTML pages"
	for man in html/$lang/man*/*
	do
		#test -e $man || continue
		out=html/man/${man#html/$lang/}.php.$lang
		footer=footer_$(basename $out)
		footer=${footer%.$lang}
		man2html -r $man | sed -e '/Content-type: text.html/d' \
		                       -e '/HREF="\/man\/man2html/d' \
		                       -e '/cgi-bin.man.man2html/d' \
		                       -e 's/\.html"/\.php"/g' \
		                       -e 's,/man3pm/,/man3/,g' \
		                       -e 's,<HEAD>,<HEAD><link rel="stylesheet" title="Default Style" type="text/css" href="../../default.css"><meta content="text/html; charset=UTF-8" http-equiv="Content-Type">,' \
		                       -e 's,<BODY>,<BODY><?php $topdir = "../../"; include "../../'$header'"; ?><div id="content">,' \
		                       -e 's,</BODY>,</div><?php include "'$footer'"; ?><?php include "../../footer.php"; ?></BODY>,' > $out
	done

	if [ "$lang" != "en" ]
	then
		rm -rf html/$lang
	fi
done
rm -rf html/en
fi

echo Extract the version
echo $webver > html/version.php

get_language() {
# FIXME: use gettext
# https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	case $1 in
		ca)
			echo -n "català"
			;;
		de)
			echo -n "Deutsch"
			;;
		en)
			echo -n "English"
			;;
		eo)
			echo -n "Esperanto"
			;;
		es)
			echo -n "español"
			;;
		fr)
			echo -n "français"
			;;
		hu)
			echo -n "Magyar"
			;;
		hr)
			echo -n "hrvatski"
			;;
		it)
			echo -n "Italiano"
			;;
		ja)
			echo -n "日本語"
			;;
		nb)
			echo -n "Bokmål"
			;;
	        nb_NO)
			echo -n "norsk bokmål"
			;;
		nl)
			echo -n "Nederlands"
			;;
		pl)
			echo -n "polski"
			;;
		pt)
			echo -n "Português"
			;;
		pt_BR)
			echo -n "Português (Brasil)"
			;;
		ru)
			echo -n "Русский"
			;;
		sr_Cyrl)
			echo -n "српски језик"
			;;
		uk)
			echo -n "український"
			;;
		zh_CN)
			echo -n "简体中文"
			;;
		zh_CHS)
			echo -n "简体中文"
			;;
		*)
			echo "Language '$1' not supported" >&2
			exit 1
			;;
	esac
}

gen_language_footer() {
	page="$1"
	page=${page%.en}
	page=${page#src/}
	page=${page#html/}
	out=html/$(dirname $page)/footer_$(basename $page)
#	echo "Generating language footer for $page in $out"
	echo "<div id=\"languages\">" > $out
	for langcode in $(ls src/$page.* html/$page.* 2>/dev/null |grep -v ~)
	do
		echo $langcode
		langcode=${langcode#src/$page.}
		langcode=${langcode#html/$page.}
		language=$(get_language $langcode)
		echo "<a href=\"$(basename $page | sed -e 's/:/%3A/g').$langcode\">$language</a>" >> $out
	done
	echo '(how to set the <a href="https://www.debian.org/intro/cn">default document language</a>)' >> $out
	echo "</div>" >> $out
#	echo "done"
}

echo
echo "XXX Generating language footers"
for page in src/*.en
do
	gen_language_footer "$page"
done

if [ "x$libver" = "x$webver" ] ; then
	find html -name "*.en" | 
	while read page
	do
		gen_language_footer "$page"
	done
fi

echo
echo "XXX The pages are built now. You can browse them in html/, or upload them"
