#! /bin/sh
PID=$$
folder="`dirname $0`"
# check the param
while getopts t:j:s:f: name
do
 case $name in
  t) trangjar=$OPTARG;;
  j) jingjar=$OPTARG;;
  s) schema=$OPTARG;;
  f) file=$OPTARG;;
esac
done


function show_usage () {
	echo "rncv - XML validation with RELAX-NG Compact Syntax and ISO Schematron"
	echo "2013 Terradue srl"
	echo "This script joins trang and jing java packages with xsl file supporting the ISO schematron" 
	echo "usage rncv.sh -s <schema_file_name.rnc> [-t <trang_file_name.jar] [-f <path_xml_file_or_files>] [-j <jing_file_name.jar>]"
	echo "examples :"
	echo "    validate a single file against a rnc schema "
	echo "      sh rncv.sh -s ../schemas/opensearch/1.1/osatom.rnc -f ../examples/atom/atomeo01_noauthor.xml"
	echo "    validate multiple files against a rnc schema "
	echo "      sh rncv.sh -s ../schemas/opensearch/1.1/osatom.rnc -f \"../examples/atom/atomeo01.xml ../examples/atom/atomeo01_noauthor.xml\" "
	echo "    use patterns to define multiple files to validate "
	echo "      sh rncv.sh -s ../schemas/opensearch/1.1/osatom.rnc -f \"../examples/atom/atomeo*.xml\" "
	echo "    using curl as input file "
	echo "      curl 'https://api.echo.nasa.gov/opensearch/granules.atom?clientId=&shortName=MERIS_L1B_RR&versionId=1&dataCenter=OBPG' | sh rncv.sh -s ../schemas/atom/2005/rfc4287.rnc "
	
}


if [ -z "$schema" ]; then
	show_usage
    exit 0
fi

if [ -z "$trangjar" ]; then
	trangjar="../libs/trang/trang.jar"
fi

if [ ! -f $trangjar ]; then
	echo "ERROR: Missing trang jar ( $trangjar )"
	echo "Please download it from https://code.google.com/p/jing-trang/"
	echo "and use the -t option to specify the location"
	show_usage
	exit 1
fi

if [ -z "$jingjar" ]; then
	jingjar="../libs/jing/bin/jing.jar"
fi

if [ ! -f "$jingjar" ]; then
	echo "ERROR: Missing jing jar ( $jingjar )"
	echo "Please download it from https://code.google.com/p/jing-trang/"
	echo "and use the -j option to specify the location"
	exit 1
fi

if [  ! -f $schema  ]; then
	echo "ERROR: Can't find $schema"
	exit 3
fi

mkdir -p output/file_$PID/




res=`java -jar $trangjar -I rnc -O rng "$schema" "output/file_$PID/file.rng" 2>&1`

if [ -z "$res" ]; then
	
	
	if [ -z "$file" ]; then
		cat >> output/file_$PID/stdin
		file="output/file_$PID/stdin"
	fi
	
	if [ -n "$file" ]; then
		echo "schema: $schema "
		lasterr=0
		howmanyfiles=`ls $file`
		[ "$?" != "0" ] && exit 5
		howmanyfiles=`echo $howmanyfiles| wc -w` 
		if [ "1" == $howmanyfiles ]; then
			if [  ! -f $file  ]; then
				echo "ERROR: Can't find $file"
				exit 4
			fi
		fi
		for ff in `ls $file`
			do if [ "$file" != "output/file_$PID/stdin" ]; then echo "$ff"; fi
			cat $ff > output/file_$PID/input.xml
			java -jar $jingjar output/file_$PID/file.rng output/file_$PID/input.xml 1> output/file_${PID}/jing.log 2> output/file_${PID}/jing.log
			awk -F "output/file_$PID/" '{ print $2 }' < output/file_${PID}/jing.log > output/file_${PID}/err.log
			res=`cat output/file_${PID}/err.log`
			if [ -z "$res" ]; then 
				echo "    xml is valid"
				res=`xsltproc xslt/rng2sch.xsl output/file_$PID/file.rng | xsltproc xslt/sch2xsl.xsl - | xsltproc - $ff` 
				if [ -z "$res" ]; then 
					echo "    schematron rules are valid"
				else
					echo "    schematron rules are NOT valid"
					echo "    Error:"
					echo "$res"
					lasterr=12
					if [ "1" == $howmanyfiles ]; then
						#rm output/file_$PID/*
						#rmdir output/file_$PID	
						exit $lasterr
					fi
				fi
			else
				echo "    xml is NOT valid"
				echo "    Error:"
				cat output/file_${PID}/err.log 
				lasterr=14
				if [ "1" == $howmanyfiles ]; then
					rm output/file_$PID/*
					rmdir output/file_$PID	
					exit $lasterr
				fi
				
			fi
			echo ""
		done
	fi
	rm output/file_$PID/*
	rmdir output/file_$PID
	exit $lasterr	
else
	echo "failed to create rng files"
	echo "message was:"
	echo $res
	rmdir output/file_$PID
	exit 6
fi

