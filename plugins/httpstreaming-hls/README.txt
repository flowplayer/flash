Installation Instructions:

1) Checkout OSMF 2.0 Source http://www.osmf.org/source.html
2) Checkout Apple OSMF Googlecode Project http://code.google.com/p/apple-http-osmf/
3) Download Source Patch http://apple-http-osmf.googlecode.com/issues/attachment?aid=170002000&name=apple-osmf.diff&token=1aj08zewyjMN-hOT1QJOhGISBdU%3A1342529151230
4) Run the patch file within the source directory patch patch -p0 -i apple-osmf.diff
5) Run ant example
6) Load example in build/example/index.html