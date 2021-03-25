:Class Q
⍝ Interface from Dyalog APL to Q
⍝ Currently asssumes existence of #.DRC

    ⎕ML←1 ⋄ ⎕IO←0 ⋄ ⎕PP←34

    :Field Public CLT←''         ⍝ Public for debugging
    :Field Private LittleEndian

    cols←{(((⍴⍵)÷⍺),⍺)⍴⍵} ⍝ 4 cols ⍵ reshapes to have 4 cols
    fromsym←{z←¯1⌽⍵ ⋄ 1↓¨(z=⎕UCS 0)⊂z}
    to64Int←{{⊃⍵:-2⊥~⍵⋄2⊥⍵},⌽[0]8 8⍴11 ⎕DR ⍵} ⍝ thanks VMJ for pimping my code
    toReal←{(sign×exp×frac),⊖[0]4 8⍴11 ⎕DR ⍵} ⍝ thanks VMJ for pimping my code
    frac←{⎕io←1⋄1++/2*-(9↓⍵)/⍳23}
    exp←{2*127-⍨+/2*(⌽8↑1↓⍵)/⍳8}
    sign←{¯1*1↑⍵}
    split←{a←⍺⋄''{0=⍴⍵:⍺ ⋄ ⍺,(⊂a↑⍵)∇(a↓⍵)}⍵}
    rnd←{a←10*⍺ ⋄ a÷⍨⌊0.5+a×⍵}
    IntToBytes←{⎕FR←(⍺=8)⊃645 1287 ⋄ ⍺↑⎕UCS 80 ⎕DR(×⍵)×((2*(8×⍺))-1)⌊|⍵}
      q2a←{
        ⍺=1:⎕UCS ⍵
        ⍺=2:{{b←1 1 1 1 0 1 1 0 1 1 0 1 1 0 1 1 1 1 1 1
             a←(b\⍵) ⋄ ((~b)/a)←⊂'-' ⋄ ∊a
            }hex 83 ⎕DR ⍵}¨16 split ⍵
        ⍺=4:83 ⎕DR ⍵
        ⍺=5:163 ⎕DR ⍵
        ⍺=6:323 ⎕DR ⍵
        ⍺=7:to64Int¨8 split ⍵
        ⍺=8:toReal¨4 split ⍵
        ⍺=9:645 ⎕DR ⍵
        ⍺=10:⍵
        ⍺=11:fromsym ⍵
        ⍺=12:10 ¯3 ⎕DT to64Int¨8 split ⍵
        ⍺=13:{(⌊⍵÷12),1+12|⍵}¨24000+323 ⎕DR¨4 split ⍵
        ⍺=14:{3↑2 ⎕NQ'.' 'IDNToDate'(36525+⍵)}¨323 ⎕DR ⍵
        ⍺=15:{∊13 ¯1 ⎕DT 10957+⍵}¨645 ⎕DR ⍵
        ⍺=16:{(×⍵)×{⍵-2000 1 1 0 0 0 0
            }¨10 ¯3 ⎕DT|⍵}to64Int¨8 split ⍵
        ⍺=17:↓[0]100 60⊤323 ⎕DR ⍵
        ⍺=18:↓[0]100 60 60⊤323 ⎕DR ⍵
        ⍺=19:↓[0]100 60 60 1000⊤323 ⎕DR ⍵
        ⎕SIGNAL
      }
      dec←{
          ⎕IO ⎕ML←0 1                                ⍝ Decimal from hexadecimal
          ⍺←0                                         ⍝ unsigned by default.
          1<⍴⍴⍵:⍺∘∇⍤1⊢⍵                               ⍝ vector-wise:
          0=≢⍵:0                                      ⍝ dec'' → 0.
          1≠≡,⍵:⍺ ∇¨⍵                                 ⍝ simple-array-wise:
          ws←∊∘(⎕UCS 9 10 13 32 160)                  ⍝ white-space?
          ws⊃⍵:⍺ ∇ 1↓⍵                                ⍝ ignoring leading and
          ws⊃⌽⍵:⍺ ∇ ¯1↓⍵                              ⍝ ... trailing blanks.
          ∨/ws ⍵:⍺ ∇¨(1+ws ⍵)⊆⍵                       ⍝ white-space-separated:
          v←16|'0123456789abcdef0123456789ABCDEF'⍳⍵   ⍝ hex digits.
          11::'Too big'⎕SIGNAL 11                     ⍝ number too big.
          (16⊥v)-⍺×(8≤⊃v)×16*≢v                       ⍝ (signed) decimal number.
      }
      hex←{
          ⎕CT ⎕IO←0                           ⍝ Hexadecimal from decimal.
          ⍺←⊢                                 ⍝ no width specification.
          1≠≡,⍵:⍺ ∇¨⍵                         ⍝ simple-array-wise:
          1∊⍵=1+⍵:'Too big'⎕SIGNAL 11         ⍝ loss of precision.
          n←⍬⍴⍺,2*⌈2⍟2⌈16⍟1+⌈/|⍵              ⍝ default width.
          ↓[0]'0123456789abcdef'[(n/16)⊤⍵]    ⍝ character hex numbers.
      }
      a2q←{∊(⍺{
              ⍺=1:⍵
              ⍺=2:dec 16 2⍴⍵~'-'
              ⍺=4:⍵
              ⍺=5:2 IntToBytes ⍵
              ⍺=6:4 IntToBytes ⍵
              ⍺=7:8 IntToBytes ⍵
              ⍺=8:⌽⎕UCS 80 ⎕DR d2r ⍵
              ⍺=9:⎕UCS 80 ⎕DR⊃0 645 ⎕DR ⍵
              ⍺=10:⎕UCS ⍵
              ⍺=11:0,⍨⎕UCS ⍵
              ⍺=12:8 IntToBytes ¯3 10 ⎕DT ⍵
              ⍺=13:4 IntToBytes(1⊃⍵)+(⊃⍵×12)-24001
              ⍺=14:4 IntToBytes 36525-⍨1↑2 ⎕NQ'.' 'DateToIDN'⍵
              ⍺=15:8 IntToBytes 10957-⍨¯1 13 ⎕DT ⍵
              ⍺=16:8 IntToBytes ¯3 10 ⎕DT ⍵+2000 1 1 0 0 0 0
              ⍺=17:4 IntToBytes 100 60⊥⍵
              ⍺=18:4 IntToBytes 100 60 60⊥⍵
              ⍺=19:4 IntToBytes 100 60 60 1000⊥⍵
              ⎕SIGNAL
          }¨⍵)
      }

    ∇ r←SendWait data;z;done;length
      :If 0≠0⊃z←#.DRC.Send CLT data
          ('Send failed: ',,⍕z)⎕SIGNAL 11
      :EndIf
     
      r←⍬ ⋄ done←0 ⋄ length←¯1
      :Repeat
          :If 0=0⊃z←#.DRC.Wait CLT
              data←3⊃z
              :If length=¯1 ⍝ First block
                  length←256⊥⌽⍣(LittleEndian=⊃data)⊢4↓8↑data
                  r←data
              :Else
                  r,←data
              :EndIf
              done←length≤⍴r
          :Else
              ∘ ⍝ Transfer failed
          :EndIf
      :Until done
    ∇

    ∇ r←x expr;data;z
      :Access Public
      data←apl2q expr
      r←SendWait data
      :If LittleEndian≠⊃r ⋄ ∘ ⋄ :EndIf ⍝ Can't deal with other-endian architecture
      :If 128=⊃BUFFER←8↓r ⍝ Error?
          (⎕UCS 1↓BUFFER)⎕SIGNAL 11
      :Else
          r←q2apl ⍬
      :EndIf
    ∇
    ∇ r←l args;a;a1;a2;arg;b;data;dt;fu;head;length;list;out;ty;type
      :Access Public
    ⍝ Q -8! serialization
    ⍝ Let's  (function arg1 arg2 types)
      head←4⍴0
      head[0]←LittleEndian
      head[1]←2 ⍝ [1] 0=asynch, 1=synch, 2=response from Q
    ⍝ [2 3] = 0 unused
     
    ⍝ Data:
    ⍝ [0] = Type http://code.kx.com/wiki/Reference/Datatypes
    ⍝ [1] = Attributes (1=sorted+2=Unique+4=Parted+8=Grouped)
    ⍝ [2-5] = Element count
    ⍝ [6-] = Data
    ⍝ list with function + arguments
      b←+/∧\80∊⍨{⎕DR ⍵}¨args
      fu←b↑args ⋄ args←b↓args
      data←0 0,4 IntToBytes b+≢args
     
      :If b>0
          data,←10 0,(4 IntToBytes≢⊃fu),¯1↓∊{(⎕UCS ⍵),245}¨fu
      :Else
          'Unsupported type for function'⎕SIGNAL 11
      :EndIf
     
      :While 0≠≢args
          :If ∨/80 83 163 323 645∊⍨⎕DR⊃args
              arg←⊃args
              :Select ⎕DR⊃arg
              :Case 80
                  ∘
              :Case 83
                  data,←4 0,(4 IntToBytes≢arg),4 a2q arg
              :Case 163
                  data,←5 0,(4 IntToBytes≢arg),5 a2q arg
              :Case 323
                  data,←6 0,(4 IntToBytes≢arg),6 a2q arg
              :Case 645
                  data,←9 0,(4 IntToBytes≢arg),9 a2q arg
              :Else
                  ∘
              :EndSelect
          :Else
              (arg type)←⊃args
              type←'*bgåxhijefcspmdznuvt'⍳type
              :If ¯2≡≡arg
                  :If ∧/80∊⍨⎕DR¨arg[0;]
                      data,←98 0 99
                      data,←11 0,(4 IntToBytes≢arg[0;]),11 a2q arg[0;]
                      arg←1↓arg
                  :EndIf
                  data,←0 0,4 IntToBytes 1⊃⍴arg
                  data,←∊type{⍺ 0,(4 IntToBytes≢⍵),⍺ a2q ⍵}¨↓[0]arg
              :Else
                  ∘
              :EndIf
     
          :EndIf
          args←1↓args
      :EndWhile
      length←4 IntToBytes 8+≢data ⍝ [4-7] = overall length
      out←(head,length),data
      r←SendWait out
      :If LittleEndian≠⊃r ⋄ ∘ ⋄ :EndIf ⍝ Can't deal with other-endian architecture
      :If 128=⊃BUFFER←8↓r ⍝ Error?
          (⎕UCS 1↓BUFFER)⎕SIGNAL 11
      :Else
          r←q2apl ⍬
      :EndIf
    ∇

    ∇ r←apl2q x;head;⎕IO;data;length
      :Access Public
     
      head←4⍴0
      head[0]←LittleEndian
      head[1]←1 ⍝ [1] 0=asynch, 1=synch, 2=response from Q
    ⍝ [2 3] = 0 unused
     
    ⍝ Data:
    ⍝ [0] = Type http://code.kx.com/wiki/Reference/Datatypes
    ⍝ [1] = Attributes (1=sorted+2=Unique+4=Parted+8=Grouped)
    ⍝ [2-5] = Element count
    ⍝ [6-] = Data
     
      :Select ⎕DR x
      :Case 80
          data←10 0,(4 IntToBytes⍴,x),⎕UCS x
      :Else
          'Unsupported type'⎕SIGNAL 11
      :EndSelect
     
      length←4 IntToBytes 8+⍴data ⍝ [4-7] = overall length [4 bytes]
      r←(head,length),data
    ∇

    ∇ r←qcutlist r;x;m;offset;type;n
    ⍝ Cut a Q list into a piece per element
     
      m←(⍴x←r)⍴0
      offset←0
     
      :Repeat
          :Select type←⊃x
          :Case 245 ⋄ n←1+x⍳0 ⍝ Scalar symbol
          :Case 7 ⋄ shape←256⊥(⌽⍣LittleEndian)2↓6↑x
              n←6+8×shape
          :Case 0
              'Doubly nested list encountered'⎕SIGNAL 11
          :Else
              ∘
          :EndSelect
          m[offset]←1
          offset+←n
          x←n↓x
      :Until 0=⍴x
      r←m⊂r
    ∇

    ∇ r←q2apl dummy;type;flags;shape;n;atom;error;list;result;headsize;length;size;extrabyte;t;names;a
      :Access Public
    ⍝ Implement Q -9! deserialization to Dyalog APL
     
      type←⊃BUFFER
      error←type=128
      atom←type>236
      :If (type≥100)∧type≤112 ⋄ r←'Function type: ',⍕type ⋄ →0 ⋄ :EndIf
     
      :If error∨atom
          type←256-type
          headsize←shape←1
      :Else
          list←type=0
          flags←2⊃BUFFER
          headsize←6+type=99
          shape←256⊥(⌽⍣LittleEndian)¯4↑headsize↑BUFFER
      :EndIf
     
      :Select type
      :Case 0 ⍝ List
          BUFFER←headsize↓BUFFER
          r←q2apl¨⍳shape
     
      :Case 99 ⍝ Dict
          :If 98=1⊃BUFFER ⍝ key table
              BUFFER←1↓BUFFER
              r←q2apl¨0 0
              r←⊃,/r
          :Else
              BUFFER←headsize↓BUFFER
              length←1+(+\0=BUFFER)⍳shape ⍝ Look for shape'th null terminator
              names←fromsym ⎕UCS length↑BUFFER
              BUFFER←length↓BUFFER        ⍝ Drop names from buffer
              :If shape=⍴names ⍝ That looks right
              :AndIf 0=⊃BUFFER ⍝ First thing in BUFFER is a list
              :AndIf shape=⍴r←q2apl 0 ⍝ And it has the right length
                  r←names⍪↑[¯0.5]r
              :Else
                  ∘ ⍝ Unable to decipher dictionary
              :EndIf
          :EndIf
     
      :Case 98 ⍝ Table ("flipped" dictionary)
          :If 99=2⊃BUFFER ⍝ Should be a dictionary inside
              BUFFER←2↓BUFFER
              r←q2apl 0   ⍝ Just decipher that
          :Else
              ∘ ⍝ Unable to decipher table
          :EndIf
      :Case 128 ⍝ Error
          (⎕UCS 1↓BUFFER)⎕SIGNAL 11
      :Else
     
          size←type⊃0 1 16 0 1 2 4 8 4 8 1 ¯1 8 4 4 8 8 4 4 4
     
          :If error∨atom∧type=11 ⋄ length←1+(headsize↓BUFFER)⍳0
          :ElseIf type=11 ⍝ symbol vector
              length←1+(+\0=headsize↓BUFFER)⍳shape
          :Else ⋄ length←size×shape
          :EndIf
     
          r←headsize↓(n←length+headsize)↑BUFFER
          BUFFER←n↓BUFFER
          r←type q2a ⎕UCS r
      :EndSelect
     
      :If atom ⋄ r←⍬⍴r ⋄ :EndIf
    ∇


    ∇ Make(address port credentials);rc;r;z;step
      :Access Public
      :Implements Constructor
     
      'Credentials must be single-byte char'⎕SIGNAL(80≠⎕DR credentials)/11
      {}#.DRC.Init''
      :If 0=0⊃z←#.DRC.Clt''address port'Raw'⊣step←'Connect'
          CLT←1⊃z ⍝ Extract Conga client name
      :AndIf 0=0⊃z←#.DRC.Send CLT((⎕UCS credentials),3 0)⊣step←'Send Handshake'
      :AndIf 0=0⊃z←#.DRC.Wait CLT⊣step←'Wait for confirmation'
      :AndIf (,3)≡3⊃z⊣step←'Check Q return code'
          LittleEndian←2=⊃4 IntToBytes 2
      :Else
          ('Failed at step ',step,': ',,⍕z)⎕SIGNAL 11
      :EndIf
    ∇

    ∇ UnMake
      :Implements Destructor
      :Trap 0 ⍝ Ignore errors in teardown
          :If 0≠⍴CLT ⋄ {}DRC.Close CLT ⋄ :EndIf
      :EndTrap
    ∇

:EndClass
