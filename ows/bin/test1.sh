#! /bin/sh

bbox="0,39,4.5,44"
PID=$$

echo == Build Catalunya Example == 


layer1="6ac5f5d1-6278-490c-baf2-47451a31c912%3AMER_RR__2PRACR20110104_102204_000026083098_00123_46258_0000.N1.tif"
ur1="http://ows.genesi-dec.eu/geoserver/6ac5f5d1-6278-490c-baf2-47451a31c912/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities"
xsltproc --stringparam mode "fragment" --stringparam layer '$layer1' --stringparam bbox "$bbox" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" ../xslt/wms/wms2owc.xsl "$url1" > ./tmp1.$PID

layer1="coastlines"
url1="http://nsidc.org/cgi-bin/atlas_north?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities"
xsltproc --stringparam mode "fragment" --stringparam layer "$layer1" --stringparam bbox "$bbox" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" ../xslt/wms/wms2owc.xsl "$url1" > ./tmp2.$PID

layer1="6ac5f5d1-6278-490c-baf2-47451a31c912%3AMER_RR__2PRACR20110104_102204_000026083098_00123_46258_0000.N1.tif"
url1="http://ows.genesi-dec.eu/geoserver/SST_MED_SST_L4_NRT_OBSERVATIONS_010_004_c_V2_2012-04-05-89a5711c-326e-42e7-b9e2-95d1b45bbf9d/wms?service=WMS&version=1.1.0&request=GetCapabilities"
xsltproc --stringparam mode "fragment" --stringparam layer "$layer1" --stringparam bbox "$bbox" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" ../xslt/wms/wms2owc.xsl "$url1" > ./tmp3.$PID



