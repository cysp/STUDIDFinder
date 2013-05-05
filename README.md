STUDIDFinder
============

Detect unexpected uses of -[UIDevice uniqueIdentifier]


USAGE
=====

1. Build .dylib
2. Add `DYLD_INSERT_LIBRARIES=/path/to/STUDIDFinder.dylib` to your application's environment variables

This is obviously much easier to do in the simulator. :-)
