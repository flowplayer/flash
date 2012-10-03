Installation Instructions:

1) Checkout OSMF 2.0 Source http://www.osmf.org/source.html or download here http://sourceforge.net/projects/osmf.adobe/files/OSMF%202.0%20Release%20%28final%20source%2C%20ASDocs%2C%20pdf%20guides%20and%20release%20notes%29/
2) Checkout Apple OSMF Googlecode Project http://code.google.com/p/apple-http-osmf/
3) Download Source Patch http://apple-http-osmf.googlecode.com/issues/attachment?aid=170002000&name=apple-osmf.diff&token=1aj08zewyjMN-hOT1QJOhGISBdU%3A1342529151230
4) Run the patch file within the source directory patch patch -p0 -i apple-osmf.diff
5) Change the location of the build property apple-osmf-dir to the location of the apple-osmf project checkout.
6) Change the location of the build property osmf-dir to the location of the osmf 2.0 checkout or download.
7) Run ant example
8) Load example in build/example/index.html