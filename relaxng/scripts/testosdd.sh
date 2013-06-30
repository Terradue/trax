#! /bin/sh
for ex in `ls ../examples/description/*.xml`
	do echo "####################################"
	echo "$ex"
	sc="../schemas/opensearch/1.1/osdd.rnc"
	echo "  $sc"
	sh test.sh -s $sc -f $ex 
	for sc in `ls ../schemas/opensearch/extensions/*/1.0/osdd*.rnc`
		do echo "  $sc"
		sh test.sh -s $sc -f $ex
	done
done
