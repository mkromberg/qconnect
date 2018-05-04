# qconnect

An interface from Dyalog APL to Q. To use it, start q specifying
a port to listen do:
``` 
     q -p 5000
```
Then from APL (repplace "qconnect" below with folder name which
you have cloned the repo to):
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
 

