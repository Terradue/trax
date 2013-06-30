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

if [ -z "$schema" ]; then
	echo "usage app.sh -s <path_schema_name.rnc> [-t <path_to_trang.jar] [-f <path_xml_file>] [-j <path_to_jing.jar>]"
    exit 0
fi

if [ -z "$trangjar" ]; then
	trangjar="../libs/trang/trang.jar"
fi

if [ ! -f $trangjar ]; then
	echo "ERROR: Missing trang jar ( $trangjar )"
	echo "Please download it from https://code.google.com/p/jing-trang/"
	echo "and use the -t option to specify the location"
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
#echo "java -jar $trangjar -I rnc -O rng $schema output/file_${PID}/file.rng "
res=`java -jar $trangjar -I rnc -O rng "$schema" "output/file_$PID/file.rng" 2>&1`

if [ -z "$res" ]; then
	#echo "schema: $schema "
	if [ -n "$file" ]; then
		
		if [  ! -f $file  ]; then
			echo "ERROR: Can't find $file"
			exit 4
		fi

		#java -jar $relamesjar output/file_$PID/file.rng $file 1>> output/file_${PID}/relames.log 2>> output/file_${PID}/relames.log 
		#res=`tail -2 output/file_${PID}/relames.log | head -1`
		
		java -jar $jingjar output/file_$PID/file.rng $file 1>> output/file_${PID}/jing.log 2>> output/file_${PID}/jing.log
		res=`cat output/file_${PID}/jing.log`
		if [ -z "$res" ]; then 
			echo "    xml is valid"
			res=`xsltproc xslt/rng2sch.xsl output/file_$PID/file.rng | xsltproc xslt/sch2xsl.xsl - | xsltproc - $file` 
			if [ -z "$res" ]; then 
				echo "    schematron rules are valid"
			else
				echo "    schematron rules are NOT valid"
				echo "    Error:"
				echo "$res"
				rm output/file_$PID/*
				rmdir output/file_$PID	
				exit 12
			fi
		else
			echo "    xml is NOT valid"
			echo "    Error:"
			cat output/file_${PID}/jing.log
			rm output/file_$PID/*
			rmdir output/file_$PID	
			exit 14
		fi
		rm output/file_$PID/*.log
	fi
	rm output/file_$PID/*.rng
	rmdir output/file_$PID	
else
	echo "failed to create rng files"
	echo "message was:"
	echo $res
	rmdir output/file_$PID
	exit 6
fi
