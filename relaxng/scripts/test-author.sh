echo "test detection of missing author"
echo "does atom detects it?"
sh rncv.sh -s "../schemas/atom/2005/rfc4287.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"

echo ""
echo "#####################"
echo "does geo detects it ?"
sh rncv.sh -s "../schemas/opensearch/extensions/geo/1.0/atomgeo.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"

echo ""
echo "#####################"
echo "does time detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/time/1.0/atomtime.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"

echo ""
echo "#####################"
echo "does eo detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/eo/1.0/atomeo.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"

echo ""
echo "#####################"
echo "does owc detects it?"
sh rncv.sh -s "../schemas/owc/1.0/owc.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"

echo ""
echo "#####################"
echo "does correlation detects it?"
sh rncv.sh -s "../schemas/opensearch/extensions/correlation/1.0/atom.rnc"  -f "../examples/atom/atomeo01_noauthor.xml"



