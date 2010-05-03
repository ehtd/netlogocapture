
;;allowed breeds
breed [ freeagents freeagent]
breed [agents agent]
breed [ captains captain]
breed [ bodyguards bodyguard]
breed [ flags flag]
breed [ flagdefenders flagdefender]

;;characteristics
turtles-own [ 
;;agent variables
  intentions;; list of goals to achieve
  beliefs;; current state of the world
;;game variables
  team;;team number (1 or 2)
  ;life;;heath points
  dmg;;damage;;TODO: remover este valor si no se usa
;;cnet variables
  task-to-do;;task commited to do
  wait-for-bid;; variable for cnet
  task-assigned;;variable for cnet
  cnet-start-time; beginning of announcement
  cnet-end-time; max time for making deal
  cnet-task;
  cnet-bids;
;;extras
  patch-to-defend
  is-player;
]
flags-own [ 
  status ;"captured", "dropped", "in-base"
  contracts;list of posible contracts
  contracted;list of contracted makes match with 
]
captains-own [
  life;;heath points
]
bodyguards-own [
  life;;heath points
]
flagdefenders-own [
  life;;heath points
]
freeagents-own [
  life;;heath points
]
;bodyguards-own [
;  is-eye-candy;;helper variable
;  is-player;;helper variable
;  life;;heath points
;  dmg;;damage;;TODO: considerar hacer el daﾖo random dmg para que que sea mﾇs variable, tal vez aumentar el daﾖo a 20
;  behavior;;task assigned "patrol","attack"
;  patch-to-defend
;  in-position
;]
;flagdefenders-own [
;  patch-to-defend;
;]

;;global variables
globals [ 
  winred
  wingreen 
  winner;
  captain1;
  captain2;
  end-game;;criteria for stopping the simulation
]


to setup-turtles 
  create-freeagents 21  [
    set team 1
    set beliefs []
    set intentions []
    set wait-for-bid false;; variable for cnet
    set cnet-start-time 0; beginning of announcement
    set cnet-end-time 0; 
    set cnet-task []
    set cnet-bids []
    set task-assigned true
    set life 100
    set dmg 10
    set task-to-do "none"
    set patch-to-defend nobody
    set is-player true
  ]
  create-freeagents 21 [
    set team  2
    set beliefs []
    set intentions []
    set wait-for-bid false;; variable for cnet
    set cnet-start-time 0; beginning of announcement
    set cnet-end-time 0; 
    set cnet-task []  
    set cnet-bids []  
    set task-assigned true
    set life 100
    set dmg 10
    set task-to-do "none"
    set patch-to-defend nobody
    set is-player true
  ]
  
  ask freeagents with [team = 1][
    set color red
    setxy random-xcor random 15 
    while [ [count turtles in-radius 2] of self > 1 = true or pycor = 0]
      [ setxy random-xcor random 15 ]
  ] 
  
  ask freeagents with [team = 2][
    set color green
    setxy random-xcor random -15 
    while [ [count turtles in-radius 2] of self > 1 = true or pycor = 0]
      [ setxy random-xcor random -15 ]
  ]
  
  set captain1 nobody
  set captain2 nobody
end

;TODO:la tortuga con mas tortugas alrededor se hace capitan

;;setting default shapes
to default-shapes
  set-default-shape flags "flag" 
  set-default-shape captains "captain"
  set-default-shape bodyguards "person"  
  set-default-shape flagdefenders "person soldier"
end

to set-globals
  set end-game false
end

;;create players & items
;to assign-variables
;      ask flags [ 
;        set is-eye-candy false
;        set is-player false
;        set status "in-base"
;        set contracted-list[nobody nobody nobody nobody nobody nobody nobody]
;      ]
;      ask captains  [ 
;        set life 100 
;        set is-eye-candy false
;        set is-player true
;        set contracted-list[nobody nobody nobody nobody nobody nobody nobody]
;        set all-in-position false
;        set contract-ready false
;      ]
;      ask bodyguards [  
;        set life 100 
;        set dmg 10 
;        set is-eye-candy false
;        set is-player true
;        set behavior "patrol"
;        set patch-to-defend nobody
;        set in-position false
;      ]
;      ask flagdefenders [ 
;        set life 100 
;        set dmg 10 
;        set is-eye-candy false
;        set is-player true
;        set behavior "patrol" 
;        set patch-to-defend nobody
;        ]
;end


to search-for-captain
  
  ask agents with [team = 1][
    let myteam team
    let mydensity count turtles in-radius 5 with [team = myteam]    

    ifelse captain1 = nobody[
      set captain1 self 
    ][
    ask captain1 [
      let density count turtles in-radius 5 with [team = myteam]
      if mydensity > density [
        set captain1 myself 
      ]   
    ]
    ]
  ]
  
    ask agents with [team = 2][
    let myteam team
    let mydensity count turtles in-radius 5 with [team = myteam]    

    ifelse captain2 = nobody[
      set captain2 self 
    ][
    ask captain2 [
      let density count turtles in-radius 5 with [team = myteam]
      if mydensity > density [
        set captain2 myself 
      ]   
    ]
    ]
  ]
  
end

to setup-flags
  create-flags 1[
    set team 1 
    set color red
    setxy 0 15
    set pcolor red + 3
    set beliefs []
    set intentions []
    set status "in-base"
    set cnet-bids []
    set task-assigned false
    set contracts []
    set is-player false
  ]
  create-flags 1[
    set team 2 
    set color green
    setxy 0 -15
    set pcolor green + 3
    set beliefs []
    set intentions []
    set status "in-base"
    set cnet-bids []
    set task-assigned false
    set contracts []
    set is-player false
  ]
end

to setup
  clear-turtles
  clear-patches
  clear-links
  setup-flags
  
  setup-turtles
  set-globals
  default-shapes
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for debugging;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to debug [text]
  if debug?
    [ 
      print text
    ]
end

to debug-turtle [ this]
  if debug?
    [ 
      print "turtle:"
      show this
    ]
end

to debug-list [mylist ]
  if debug?
    [ 
      print "list:"
      show mylist
    ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for managing intentions and beliefs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to add-intention [new-intention]
  if not i-have-intention? new-intention[
    set intentions lput new-intention intentions
  ]
  debug "==ADD-INTENTION"
  debug new-intention
end

to add-belief [new-belief]
  debug "==ADD-BELIEF"
  debug new-belief
  set beliefs lput new-belief beliefs
end
      
to clean-beliefs
    debug "==CLEAN-BELIEFS"
  set beliefs []
end

to-report i-have-intention? [intention]
    debug "==I-HAVE-INTENTION?"
    debug intention
  let i 0
  let intention? false
  if length intentions != 0 [
    
    foreach intentions [
      ifelse ? = intention [
        set intention? true
      ][
      set i i + 1
      ]
    ]
  ]
  report intention?
end

to-report i-have-belief? [belief]
  debug "==I-HAVE-BELIEF?"
  debug belief
  let i 0
  let belief? false
  if length beliefs != 0 [
    
    foreach beliefs [
      ifelse ? = belief [
        set belief? true
      ][
      set i i + 1
      ]
    ]
  ]
  report belief?
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CNET helper procedures;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report player [agent]
  debug ">>>TO-REPORT PLAYER"
  let a nobody
  ask agent [
    set a self
    debug-turtle self
  ]
  debug "<<<TO-REPORT PLAYER"
report a
end

to cnet-broadcast-task [myteam task requirement1 reference1 requirement2 reference2 timespan contractor]
    debug ">>>TO CNET-BROADCAST-TASK"
  set cnet-start-time ticks
  set cnet-end-time cnet-start-time + timespan; 
  
  debug "CNET-START-TIME"
  debug cnet-start-time
  
  debug "CNET-END-TIME"
  debug cnet-end-time
  ;;TODO:Validate time
  
  ask other turtles with [team = myteam and task-to-do = "none"][
    cnet-add-task task requirement1 reference1 requirement2 reference2 contractor
    debug-list cnet-task
  ]
  set wait-for-bid false
  debug "<<<TO CNET-BROADCAST-TASK"
end

to cnet-add-task [task requirement1 reference1 requirement2 reference2 contractor]
  debug ">>>TO CNET-ADD-TASK"
    set cnet-task lput task cnet-task
    set cnet-task lput requirement1 cnet-task
    set cnet-task lput reference1 cnet-task
    set cnet-task lput requirement2 cnet-task
    set cnet-task lput reference2 cnet-task
    set cnet-task lput contractor cnet-task
    debug "<<<TO CNET-ADD-TASK"
end

to bid [contractor agent offer]
  debug ">>>TO BID"
   ask contractor [
     set cnet-bids lput (list agent offer) cnet-bids
   ]
   debug "<<<TO BID"
end

to award [task contract]
  debug ">>>TO AWARD"
  ;;select best offer
  let winner-agent nobody
  let winner-offer 500
  
  foreach cnet-bids[
    let bid-to-check ?
    
    let agent item 0 bid-to-check
    let offer item 1 bid-to-check
    
    if offer < winner-offer [
      set winner-agent agent
      set winner-offer offer
    ]
    ;;;;;;;;;escoger al ganador
    
  ]
  ;;award
  debug "WINNER:"
  debug-turtle winner-agent
  if winner-agent != nobody[;;TODO:reasignar a uno no muerto
  ask winner-agent [
    set breed captains
    set task-to-do task
    set dmg 0
    set patch-to-defend nobody
  ]
  ]
  
  set cnet-bids []
  
   debug "TO AWARD<<<"
end

to cnet-calculation
  
  debug ">>>>>>>>>TO CNET-CALCULATION"
      if length cnet-task != 0[
      let requirement1 item 1 cnet-task
      let reference1 item 2 cnet-task
      let requirement2 item 3 cnet-task
      let reference2 item 4 cnet-task
      let contractor item 5 cnet-task
      let offer 0
      
      if requirement1 = "distance"[
        set offer (distance reference1) * 10
      ]
      
      if requirement2 = "life"[
        set offer (offer - life)
      ]
      debug "PLACING MY OFFER"
      debug offer
      
      bid player contractor player self offer
      ;;after bid is done remove from list
      set cnet-task [] 
    ]
      debug "<<<<<<<<<TO CNET-CALCULATION"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to agent-loop-flags
  debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AGENT-LOOP-FLAGS"
  ask flags [
    debug "BEGIN AGENT PROCESS:"
    debug self
    
    let myteam team    
    let enemy-flag one-of flags with[team != myteam]
    let captain? false
    let enemy-flag-captured? false
    let action "none"
    let extra nobody
    let composite-action []
    
    clean-beliefs
    
    if any? (turtles with [team != myteam and is-player = true]) = nobody
    [set end-game true
      set winner myteam]
    
    if status = "in-base" [
;      let basx 0
;      let basy 15
      ifelse team = 1
      [move-to patch 0 15]
      [move-to patch 0 -15] 
      
;      set xcor basx
;      set ycor basy
    ]
    
    if count freeagents <= 0[
      if one-of captains with [team = myteam] = nobody[
        if any? turtles with [team =  myteam and is-player and life > 0][
          ask max-one-of turtles  with [team =  myteam and is-player and life > 0] with-min [distance (one-of flags with [team != myteam])] [life]  
          [set breed captains]
        ]
      ]
    ]
    
    
    ;;update beliefs according to percept
    ask turtles with [team = myteam] [
     if is-captain? self[
       set captain? true
     ] 
    ]
    
    if captain? = false[
     add-belief "no-captain" 
    ]
        
    if status = "captured" [
      add-belief "i-am-captured"
    ]
    
    if myteam = 2 and count flagdefenders with [team = myteam] = 0 and count turtles with [team = myteam and is-player = true] > 1 [
       add-belief "i-need-flagdefenders"
    ]
    ;;TODO:adjust radius if necesary
    if myteam = 1 and count flagdefenders with [team = myteam] in-radius 1 < 7 and status = "in-base"   ;;TODO: probablemente cambiar la condicion 1<7
    [
;      let no-def true
      
      if count flagdefenders with [team = 1] <= 7 and ticks >= cnet-end-time[
        add-belief "i-need-box"
      ] 
    ]
        
    if count bodyguards with [team = myteam] = 0 [
       add-belief "i-need-bodyguards"
    ]
    

    
    debug "SHOWING BELIEFS:"
    debug-list beliefs
  
  ;;Deliberate which options I have according to beliefs ->add intentions
  
    if i-have-belief? "no-captain"[
        add-intention "asign-captain"
    ]
    

    if i-have-belief? "i-need-box"[
        
        ;;patches list       
        ;        |p7|X|p6|
        ;        |p5|fl|p4|
        ;        |p2|p1|p3|
        let p1 patch xcor (ycor - 1)
        let p2 patch (xcor - 1) (ycor - 1)
        let p3 patch (xcor + 1) (ycor - 1)
        let p4 patch (xcor + 1) ycor
        let p5 patch (xcor - 1) ycor
        let p6 patch (xcor + 1) (ycor + 1)
        let p7 patch (xcor - 1) (ycor + 1)
        ; let p8 patch (xcor + 1) (ycor + 1)
        
  ;      if turtles-on patch p1 != nobody[] TODO:Validar quienes estan ocupando ya las casillas y dinamicamente agregar las faltantes a contracts
        
        ;;TODO: tal vez colocarlos en otro orden para que no se estorben y luego si llenar por prioridad
        set contracts (list p1 p2 p3 p4 p5 p6 p7); 
        foreach contracts[
          if not i-have-intention? (list "box-formation" ?) [
            add-intention (list "box-formation" ?)
          ]
        ]
      
    ]
    

    if i-have-belief? "i-need-flagdefenders"[

        add-intention "assign-def"

    ]
    
    if i-have-belief? "i-need-bodyguards"[

        add-intention "assign-bg"

    ]
    
    if i-have-belief? "i-am-captured"[

        ;add-intention "ask-for-help"

    ]
    

   
    debug "SHOWING INTENTIONS:"
    debug-list intentions
  
  ;;Select Intentions->Do one intention each turn in a FIFO
  if length intentions != 0[
    
    ifelse is-list? item 0 intentions [
      set composite-action item 0 intentions
      set extra item 1 composite-action
      set action item 0 composite-action
      debug "showing extra:"
      debug-turtle extra
    ][
    set action item 0 intentions
    ]

  ]
  
  debug "SHOWING ACTION:"
  debug action
  
  
  if action = "asign-captain"[
    debug "BEGIN CAPTAIN REQUEST----------"
    if team = 1 [
      ;; announce
      if task-assigned = false [
        cnet-broadcast-task team "captain" "distance" player enemy-flag "life" "none" 10 player self
        set task-assigned true
      ]
      ;;wait for bid
      
      if length cnet-bids != 0[
        
        ;;award
        award "captain" nobody

        ;;remove bids
        set intentions remove "asign-captain" intentions
        set task-assigned false
        
      ]
    ]
    
    if team = 2 [
      ask one-of turtles with [team = myteam and is-player][
        set breed captains
        set dmg 0
        ]
      set intentions remove "asign-captain" intentions
      debug-turtle self
    ]
    debug "END CAPTAIN REQUEST----------"
  ]
  
  if action = "box-formation"[
    debug "BEGIN BOX REQUEST-------"
    ;; announce

            
      if task-assigned = false [
        cnet-broadcast-task 1 "box-formation" "distance" extra "none" "none" 5 player self
        set task-assigned true
      ]
      
            
;;wait for bid
      if length cnet-bids != 0[
        ;;award
        
        debug "CNET-AWARD"
        ;select best offer
        
        let winner-agent nobody
        let winner-offer 500
        
        foreach cnet-bids[
          ;    write "CHECK NEW BID:"
          let bid-to-check ?
          
          let agent item 0 bid-to-check
          let offer item 1 bid-to-check
          
          if offer < winner-offer [
            set winner-agent agent
            set winner-offer offer
          ]
          debug "OFFER:"
          debug offer
          ;;;;;;;;;escoger al ganador
          
        ]
        ;;award
        debug "WINNER:"
        debug-turtle winner-agent
        
        if winner-agent != nobody[;TODO: ver por que mueren y que gane otra que est� vivo
        ask winner-agent [
          set breed flagdefenders
          set task-to-do "box-formation"
          set patch-to-defend extra
        ]
        ]
        set cnet-bids []
  

      ;;remove bids
      set intentions remove (list "box-formation" extra) intentions
      set task-assigned false
    
    
    ;;expedite
            ]
            
            debug "END BOX REQUEST-------"
  ]
  
  
  if action = "assign-def"[
    debug "BEGIN ASSIGN-DEF"
    let i 0
    while [ i < 10][
      
      ask one-of freeagents with [team = 2][
        set breed flagdefenders
        set i i + 1
      ]
    ]
    set intentions remove "assign-def" intentions
    debug "END ASSIGN-DEF"
  ]
  
  if action ="assign-bg"[;;TODO:separar uno diferente para cada equipo
    debug "BEGIN ASSIGN-BG"
    ask freeagents with [team = 1][
      if count flagdefenders with [team = 1] >= 7[
      set breed bodyguards 
      ]
    ]
    ask freeagents with [team = 2][
      set breed bodyguards 
    ]
    set intentions remove "assign-bg" intentions
    debug "END ASSIGN-BG"
  ]
  
  
;  IF the intention stack is not empty THEN do: Get intention I from the top of the stack; Execute I-name; IF I-done evaluates to true THEN pop I from stack;
;ELSE do nothing

  ;;make plan
  
  ;;execute plan
    debug "END AGENT PROCESS:"
    debug self
  ]
    debug "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<AGENT-LOOP-FLAGS"
end

to agent-loop-freeagent
    debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AGENT-LOOP-FREEAGENT"
  ask freeagents [
        debug "BEGIN AGENT PROCESS:"
    debug self
    
    let myteam team
    let myflag one-of flags with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    
    ;;update beliefs according to percept
    
    clean-beliefs
    debug "CNET-TASK:"
    debug-list cnet-task
    cnet-calculation

    
  ;;Deliberate which options I have according to beliefs
  
  ;;Select Intentions
  
;  IF the intention stack is not empty THEN do: Get intention I from the top of the stack; Execute I-name; IF I-done evaluates to true THEN pop I from stack;
;ELSE do nothing

  ;;make plan
  
  ;;execute plan
      debug "END AGENT PROCESS:"
    debug self
    
  ]
    debug "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<AGENT-LOOP-FREEAGENT"
end

to agent-loop-def
    debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AGENT-LOOP-DEF"
  ask flagdefenders [
    debug "BEGIN AGENT PROCESS:"
    debug self
    
    let myteam team
    let mydmg dmg
    let myflag one-of flags with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    let enemies []
    let action "none"
    let extra nobody
    let composite-action []
    
    ;;update beliefs according to percept
    
    clean-beliefs
;        debug "CNET-TASK:"
;    debug-list cnet-task
;    cnet-calculation
    if team = 1 [
      ifelse [status] of myflag = "captured"
      [add-belief "myflag-captured"]
      [
        ifelse distance enemyflag < 4
        [add-belief "danger"]
        [
          if patch-to-defend != nobody and distance patch-to-defend != 0 [
            add-belief "defend" 
          ]
          
          if patch-to-defend != nobody and distance patch-to-defend = 0 [
            add-belief "in-position"
          ]
        ]
      ]
    ]
      
    if team = 2 [
      ifelse any? turtles with [team != myteam] in-radius 3
      [add-belief "danger"]
      [add-belief "patrol"]
    ]
    

      
    debug "SHOWING BELIEFS:"
    debug-list beliefs

  ;;Deliberate which options I have according to beliefs
      
      if i-have-belief? "myflag-captured"[

        add-intention "recover-flag"
      
    ]
      
      if i-have-belief? "danger"[

        add-intention "attack"
      
    ]
      if i-have-belief? "patrol"[

        add-intention "patrol-flag"
      
    ]
      
      if i-have-belief? "in-position"[

        add-intention "protect-patch"
      
    ]
            
      
      if i-have-belief? "defend"[

          add-intention "defend-flag"

      ]
            
      
      debug "SHOWING INTENTIONS:"
      debug-list intentions
    
      ;;Select Intentions->Do one intention each turn in a FIFO
  if length intentions != 0[
    
    ifelse is-list? item 0 intentions [
      set composite-action item 0 intentions
      set extra item 1 composite-action
      set action item 0 composite-action
      debug "showing extra:"
      debug-turtle extra
    ][
    set action item 0 intentions
    ]
  ]
  
  if action = "recover-flag"
  [
        set heading towards myflag
        move
  attack myteam

     set intentions remove action intentions
  ]
  
  if action = "attack"[
        let front patch-ahead 1
        
         set enemies turtles with [team != myteam and is-player = true] in-radius 3 
         
        ifelse any? enemies
        [set heading towards one-of enemies
        move]
        [face myflag]

;;heading
    attack myteam
      
    set intentions remove action intentions
  ]
  
  
  if action = "patrol-flag"[
    ifelse myflag != nobody and distance myflag > 7[;;TODO:validar por que desaparece la bandera
      face myflag
      move
    ][
    ;;move random if inside safe radius
    set heading random 360
    move
    ]
    set intentions remove action intentions
  ]
  
  if action = "protect-patch"[
        let front patch-ahead 1
        
         set enemies turtles with [team != myteam and is-player = true] in-radius 2 
         
        ifelse any? enemies
        [face one-of enemies]
        [face myflag]

        attack myteam
      
    set intentions remove "protect-patch" intentions
  ]
    
  
    if action = "defend-flag"[
      if distance patch-to-defend > 0[
        set heading towards patch-to-defend
        move
      ]
      set intentions remove "defend-flag" intentions
  ]
    
  ;;Select Intentions
  
;  IF the intention stack is not empty THEN do: Get intention I from the top of the stack; Execute I-name; IF I-done evaluates to true THEN pop I from stack;
;ELSE do nothing

  ;;make plan
  
  ;;execute plan
      debug "END AGENT PROCESS:"
    debug self
    
  ]
    debug "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<AGENT-LOOP-DEF"
end

to attack [myteam]
  let front patch-ahead 1
    if front != nobody [
      if (any? (turtles-on front) with [team != myteam and is-player = true])[
        ;;if  turtle one-of [who] of turtles-here team = 
        ask (turtles-on front) with [team != myteam and is-player = true] [
            set color pink
            set life life - 10
            
            dead?
            
        ]
      ]
    ]
    
end

to agent-loop-bg
    debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AGENT-LOOP-BG"
  ask bodyguards [
    debug "BEGIN AGENT PROCESS:"
    debug self
    
    let myteam team
    let mycaptain one-of captains with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    let enemies []
    let action "none"
    let extra nobody
    let composite-action []
    
    ;;update beliefs according to percept
    
    clean-beliefs
;            debug "CNET-TASK:"
;    debug-list cnet-task
;    cnet-calculation
    
    

    if team = 1 and mycaptain != nobody[
      ask mycaptain[
              ifelse any? turtles with [team != myteam] in-radius 3 [
        ;show "enemy near"
        ask bodyguards with [team = myteam ][
          add-belief "defend"
        ]
      ]
                          [
        ask bodyguards with [team = myteam ][
          add-belief "patrol"
        ]
      ]
        
      ]
            add-belief "patrol"
    ]
    
    if team = 2 and mycaptain != nobody[
      ask mycaptain[
              ifelse any? turtles with [team != myteam] in-radius 3 [
        ;show "enemy near"
        ask bodyguards with [team = myteam ][
          add-belief "captain-needs-defend"
        ]
      ]
                          [
        ask bodyguards with [team = myteam ][
          add-belief "patrol"
        ]
      ]
        
      ]
            add-belief "patrol"
    ]
    
  ;;Deliberate which options I have according to beliefs
    if i-have-belief? "patrol"[
      
      add-intention "patrol-captain"
      
    ]
    
    if i-have-belief? "captain-needs-defend"[
      
      add-intention "defend-captain"
      
    ]
        
  ;;Select Intentions
        ;;Select Intentions->Do one intention each turn in a FIFO
  if length intentions != 0[
    
    ifelse is-list? item 0 intentions [
      set composite-action item 0 intentions
      set extra item 1 composite-action
      set action item 0 composite-action
      debug "showing extra:"
      debug-turtle extra
    ][
    set action item 0 intentions
    ]
  ]
  
  if action = "patrol-captain"[
    ifelse mycaptain != nobody and distance mycaptain > 3[
      face mycaptain
      move
    ][
    ;;move random if inside safe radius
    set heading random 360
    move
    ]
    set intentions remove "patrol-captain" intentions
  ]
  
    if action = "defend-captain" and mycaptain != nobody[
      
      ask mycaptain [
        set enemies turtles with [team != myteam and is-player = true] in-radius 2;;TODO:ajustar radio
      ]
      
      ifelse any? enemies[
        face one-of enemies with-min[distance myself]
      ][
      face mycaptain
      ]
      move
      attack myteam
    set intentions remove "patrol-captain" intentions
  ]
  
  

  ;;make plan
  
  ;;execute plan
      debug "END AGENT PROCESS:"
    debug self
    
  ]
    debug "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<AGENT-LOOP-BG"
end

to agent-loop-captain
    debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>AGENT-LOOP-CAPTAIN"
  ask captains [
    debug "BEGIN AGENT PROCESS:"
    debug self
    
    let myteam team
    let myflag one-of flags with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    let base patch 0 15
    if myteam = 2 
    [set base patch 0 -15]
    let action []
    let mycap one-of captains with [team = myteam]

    
    ;;update beliefs according to percept
    clean-beliefs
    
    if team = 1 [
    if not any? bodyguards with [team = myteam] in-radius 3
    [add-belief "in-danger"]
     ]
    
    if distance enemyflag <= 1 
    [add-belief "enemyflag-near"]
    if (any? flags with [team != myteam and status != "captured"])
    [add-belief "enemyflag-not-captured"]
    if (any? flags with [team != myteam and status = "captured"])
    [add-belief "i-have-the-flag"]
    if distance base <= 1
    [add-belief "base-near"]
     
    
  ;;Deliberate which options I have according to beliefs
   if i-have-belief? "i-have-the-flag" and i-have-belief? "base-near"
   [add-intention "touch-base"]
   ifelse i-have-belief? "i-have-the-flag"
   [add-intention "return-to-base"]
   [ifelse i-have-belief? "in-danger"
   [add-intention "wait-for-help"]

   [if i-have-belief? "enemyflag-near" and i-have-belief? "enemyflag-not-captured"
   [add-intention "take-enemyflag"]
   if i-have-belief? "enemyflag-not-captured"
   [add-intention "go-for-enemyflag"]
   ]
   ]
  ;;Select Intentions
  if length intentions > 0
  [set action item 0 intentions]
   
   ;write action
   ;;Actions
      if action = "wait-for-help"
     []
   if action = "go-for-enemyflag"
   [set heading towards enemyflag
     move]
   if action = "take-enemyflag"
   [  setxy ([xcor] of enemyflag ) ([ycor] of enemyflag) 
      ask enemyflag [
      set color yellow
      set status "captured"
      ]
      
      create-link-to enemyflag [tie]
      set intentions []
   ]
   if action = "return-to-base"
   [set heading towards base
     move]
   if action = "touch-base"
   [set end-game true
    set winner myteam]
   set intentions remove action intentions

;  IF the intention stack is not empty THEN do: Get intention I from the top of the stack; Execute I-name; IF I-done evaluates to true THEN pop I from stack;
;ELSE do nothing

  ;;make plan
  
  ;;execute plan
      debug "END AGENT PROCESS:"
    debug self
    
  ]
    debug "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<AGENT-LOOP-CAPTAIN"
end



to agent-loop
  
  ask turtles [
    let myteam team
    let myflag one-of flags with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    
    ;;update beliefs according to percept
    
    clean-beliefs
    
    if is-flag? self = false[
      ask myflag [
        
        if status = "in-base"[
          ask myself[
            add-belief "flag-is-safe"
          ]
        ]
        if status = "captured"[
          ask myself[
            add-belief "flag-is-captured"
          ]
        ]
        
      ] 
    ]
    
    if is-captain? self =  false[
     
      
    ]
  
  ;;Deliberate which options I have according to beliefs
  
  ;;Select Intentions
  
;  IF the intention stack is not empty THEN do: Get intention I from the top of the stack; Execute I-name; IF I-done evaluates to true THEN pop I from stack;
;ELSE do nothing

  ;;make plan
  
  ;;execute plan
  
  ]
end




to show-life
  ask turtles [
    if not is-flag? self[
      ifelse show-life?
      [ set label life ]
      [ set label "" ]
    ]
  ]
end


to move
  

  let front patch-ahead 1
  let alternatives []
      
  if front != nobody [
    ifelse not any? turtles-on front[
      move-to front ][
    ;;validate alternate movements
    if (patch-left-and-ahead 45 1 != nobody) and (not any? turtles-on patch-left-and-ahead 45 1) [
      set alternatives lput patch-left-and-ahead 45 1 alternatives
    ]
    if (patch-left-and-ahead -45 1 != nobody) and (not any? turtles-on patch-left-and-ahead -45 1) [
      set alternatives lput patch-left-and-ahead -45 1 alternatives
    ]
    if (patch-left-and-ahead 90 1 != nobody) and (not any? turtles-on patch-left-and-ahead 90 1) [
      set alternatives lput patch-left-and-ahead 90 1 alternatives
    ]
    if (patch-left-and-ahead -90 1 != nobody) and (not any? turtles-on patch-left-and-ahead -90 1) [
      set alternatives lput patch-left-and-ahead -90 1 alternatives
    ]
    if not empty? alternatives [
      move-to one-of alternatives      
    ]
      ]
  ]
  
  
end


to dead?
  if (life <= 0) [
        die-clean
  ]
end



to die-clean

    let myteam team
    let myflag one-of flags with [team = myteam]
    let enemyflag one-of flags with [team != myteam]
    
        if is-captain? self [
         
          if count turtles-here > 1 [
            ask enemyflag [
              if status = "captured"[
                set status "in-base"
              ]
            ]  
                        
          ]
          
          ask other turtles with [team = myteam][
            set task-to-do "none" 
          ]

    ]
    if not is-flag? self[        
    die
    ]
  
end

to normal-setup
  setup
end

to set-teamcolor
  ask turtles [
    ifelse (team = 1) [
      set color red
    ] 
    [
      set color green
    ]
  ] 
end

to cnet-start

  set-teamcolor
  agent-loop-flags
  agent-loop-captain
  agent-loop-def
  agent-loop-bg
  
  agent-loop-freeagent
  tick
    if (end-game = true)
    [
      show winner
      stop 
      ] 

end

to start
  clear-all
  set winred 0
  set wingreen 0
  if loops < 2
  [set loops 1]
  repeat loops [
    setup
    one-game
    do-plots
    if winner = 1 [set winred winred + 1]
    if winner = 2 [set wingreen wingreen + 1]
    reset-ticks 
  ]
end

to one-game
  show-life
  set-teamcolor
  agent-loop-flags
  agent-loop-def
  agent-loop-bg
  agent-loop-captain
  agent-loop-freeagent
  tick
    ifelse (end-game = true)
    [
      show winner
      stop 
      ] [one-game]
  
end

to do-plots
  set-current-plot "Survivors"
  set-current-plot-pen "Red"
  plot count turtles with [team = 1 ]
  set-current-plot-pen "Green"
  plot count turtles with [team = 2 ]
  set-current-plot "Game Time"
  plot ticks
end
@#$#@#$#@
GRAPHICS-WINDOW
213
10
748
536
17
16
15.0
1
10
1
1
1
0
0
0
1
-17
17
-16
16
0
0
1
ticks

SWITCH
33
163
153
196
show-life?
show-life?
0
1
-1000

MONITOR
27
224
165
269
Red turtles (Team 1)
count turtles with [team = 1]
17
1
11

MONITOR
23
283
171
328
Green turtles(Team 2)
count turtles with [team = 2]
17
1
11

INPUTBOX
21
28
176
88
loops
500
1
0
Number

BUTTON
65
117
128
150
NIL
start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
769
21
1177
184
Survivors
Game
Survivors
0.0
10.0
0.0
21.0
true
false
PENS
"Red" 1.0 0 -2674135 true
"Green" 1.0 0 -10899396 true

MONITOR
824
403
958
448
Red Team (intelligent)
winred
17
1
11

MONITOR
975
403
1083
448
Green Team
wingreen
17
1
11

TEXTBOX
896
368
1046
393
Victories
20
0.0
1

PLOT
772
200
1176
350
Game Time
Game
Ticks
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

SWITCH
47
369
150
402
debug?
debug?
1
1
-1000

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

blocker
true
0
Circle -7500403 true true 73 75 152
Polygon -7500403 true true 150 0 90 150 210 150 150 0
Rectangle -7500403 true true 0 135 75 150
Rectangle -7500403 true true 225 135 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

captain
false
0
Circle -1184463 true false 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1184463 true false 105 90 60 150 75 180 135 105
Polygon -1184463 true false 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 210 165 300 195 300 210 285 180 195 195 90

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 false true 45 45 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

defense
true
0
Circle -7500403 true true 73 75 152
Polygon -7500403 true true 150 0 90 150 210 150 150 0
Polygon -7500403 true true 180 210 210 225 210 195 240 195 225 165 240 150 225 135 195 210
Polygon -7500403 true true 120 210 90 225 90 195 60 195 75 165 60 150 75 135 105 210
Polygon -7500403 true true 180 90 210 75 210 105 240 105 225 135 240 150 225 165 195 90
Polygon -7500403 true true 120 90 90 75 90 105 60 105 75 135 60 150 75 165 105 90

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -6459832 true false 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

hp bar
false
0
Line -7500403 true 285 300 15 300

hp bar 1/2
false
0
Line -7500403 true 150 300 0 300

hp bar 1/4
false
0
Line -7500403 true 75 300 0 300

hp bar 3/4
false
0
Line -7500403 true 225 300 0 300

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

nariz
true
0
Circle -7500403 true true 58 58 182
Polygon -7500403 true true 300 150 150 60 150 240 300 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 135 105
Polygon -1 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 120 90 105 90 180 195 180 165
Line -1 false 109 105 139 105
Line -1 false 122 125 151 117
Line -1 false 137 143 159 134
Line -1 false 158 179 181 158
Line -1 false 146 160 169 146
Rectangle -1 true false 120 193 180 201
Polygon -1 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -1 true false 183 90 240 15 247 22 193 90
Rectangle -1 true false 114 187 128 208
Rectangle -1 true false 177 187 191 208

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

qb
true
0
Circle -1184463 true false 60 60 180
Circle -7500403 true true 73 75 152
Polygon -7500403 true true 150 0 90 150 210 150 150 0
Polygon -1184463 true false 150 0 120 75 180 75 150 0
Polygon -7500403 true true 150 15 90 165 210 165 150 15

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
