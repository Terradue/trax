echo "test detection of missing url template with atom encoding"
file="../examples/description/osddeo01_noatom.xml"
echo ""
echo "#####################"
echo "does geo detects it ?"
sh rncv.sh -s "../schemas/opensearch/extensions/geo/1.0/osddgeo.rnc"  -f "$file"

echo ""
echo "#####################"
echo "does time detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/time/1.0/osddtime.rnc"  -f "$file"

echo ""
echo "#####################"
echo "does eo detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/eo/1.0/osddeo.rnc"  -f "$file" 

echo ""
echo "#####################"
echo "does correlation detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/correlation/1.0/osdd.rnc"  -f "$file"


echo ""
