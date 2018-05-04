 failed←UT debug;q;⎕IO;shouldbe;name;aplx;qx;OK;start;expected;got
⍝ if debug = 1, stop on error

 ⎕IO←0
 :If 0=⎕NC'DRC' ⋄ 'DRC'⎕CY'conga.dws' ⋄ :EndIf ⍝ Make sure conga client is here

 start←2⊃⎕AI
 q←⎕NEW Q('127.0.0.1' 5000 'mkrom') ⍝ Connect to Q
 {}q.x'\l sp.q'                     ⍝ Load Suppliers and Parts
 :Trap 11                           ⍝ Will fail if TAQ already loaded
     {}q.x'\l db/taq'               ⍝ Load Trades and Quotes
 :EndTrap

 failed←⍬

 :For (qx aplx name) :In 1↓↓Qtests

     :Trap debug↓0
         :If (got←q.x qx)≢expected←⍎aplx
             failed,←⊂'FAIL: ',name
             :If debug
                 ⎕←disp 2 4⍴'qx' 'Expected' 'aplx' 'Got',⍪qx expected aplx got
                 ∘∘∘ ⍝ Now fix it!
             :EndIf
         :EndIf
     :Else
         failed,←⊂'CRASHED ("',(⊃⎕DM),'"): ',name
     :EndTrap

 :EndFor
 ⎕←(⍕≢Qtests),' unit tests completed in ',(⍕(2⊃⎕AI)-start),' ms.'

 failed←⍪failed
