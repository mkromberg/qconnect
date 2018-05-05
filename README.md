# qconnect

An interface from Dyalog APL to Q. To use it, start q specifying
a port to listen on:
``` 
     q -p 5000
```
Then from APL (replacing "qconnect" below with folder name which
you have cloned or unzipped this repository to):
``` 
     ]load qconnect/Q
     )copy conga DRC
     q←⎕NEW Q ('127.0.0.1' 5000 'user')
     q.x 'sum til 10'
     ⍝ Now run unit tests (some will fail due to missing tables)
     Qtests←⎕CSV 'qconnect/QTests.csv'
     ]load qconnect/UT
     UT 0
```
Prerequisites: Only tested with version 16.0, but should work with Dyalog version 13.1 or later. The use of ⎕CSV above requires Dyalog version 15.0 or later.
