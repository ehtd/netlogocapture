;TODO:Ver como hacer videos
;;allowed breeds
breed [ agents agent]
breed [ captains captain]
breed [ bodyguards bodyguard]
breed [ flags flag]
breed [ flagdefenders flagdefender]

;;for visual effects
breed [halos halo]
breed [hp-bars hp-bar]

;;characteristics
turtles-own [ 
  team;;team number (1 or 2)*TODO:podriamos ponerle red y green para mﾇs sencillo
]
flags-own [ 
  is-eye-candy;;helper variable
  is-player;;helper variable
  status ;"captured", "dropped", "in-base"
  contracted-list;list of contracts
]
captains-own [
  is-eye-candy;;helper variable
  is-player;;helper variable
  life;;heath points
  dmg;;damage;;TODO: remover este valor si no se usa
  contracted-list;list of contracts
  all-in-position;;Validates a contract list is fully assigned
  contract-ready;Validates a contract exists
]
bodyguards-own [
  is-eye-candy;;helper variable
  is-player;;helper variable
  life;;heath points
  dmg;;damage;;TODO: considerar hacer el daﾖo random dmg para que que sea mﾇs variable, tal vez aumentar el daﾖo a 20
  behavior;;task assigned "patrol","attack"
  patch-to-defend
  in-position
]
flagdefenders-own [
  is-eye-candy;;helper variable
  is-player;;helper variable
  life;;heath points
  dmg;;damage
  behavior;;task assigned "patrol","attack","contracted","disperse"
  patch-to-defend;
]

;;visual effects
halos-own[
  is-eye-candy;;helper variable 
  is-player;;helper variable
]
hp-bars-own[
  is-eye-candy;;helper variable 
  is-player;;helper variable
]

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
  create-agents 21  [
    set team 1
    ]
  create-agents 21 [
     set team  2
     ]
  
  ask agents with [team = 1][
    set color red
    setxy random-xcor random 15 
      while [ [count turtles in-radius 2] of self > 1 = true or pycor = 0]
      [ setxy random-xcor random 15 ]
  ] 
  
    ask agents with [team = 2][
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
  set-default-shape captains "person"
  set-default-shape bodyguards "person"  
  set-default-shape flagdefenders "person soldier"
  ;;visual effects
  set-default-shape halos "circle 2"
  set-default-shape hp-bars "hp bar"
end

to set-globals
  set end-game false
end

;;create players & items
to assign-variables
      ask flags [ 
        set is-eye-candy false
        set is-player false
        set status "in-base"
        set contracted-list[nobody nobody nobody nobody nobody nobody nobody]
      ]
      ask captains  [ 
        set life 100 
        set is-eye-candy false
        set is-player true
        set contracted-list[nobody nobody nobody nobody nobody nobody nobody]
        set all-in-position false
        set contract-ready false
      ]
      ask bodyguards [  
        set life 100 
        set dmg 10 
        set is-eye-candy false
        set is-player true
        set behavior "patrol"
        set patch-to-defend nobody
        set in-position false
      ]
      ask flagdefenders [ 
        set life 100 
        set dmg 10 
        set is-eye-candy false
        set is-player true
        set behavior "patrol" 
        set patch-to-defend nobody
        ]
end

;;set team colors 1-red 2-green
to set-teamcolor
  ask turtles with [is-eye-candy = false] [
    ifelse (team = 1) [
      set color red
    ] 
    [
      set color green
    ]
  ] 
end

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

to assign-captains
  
  ask captain1 [
    set breed captains
  ]
  ask captain2 [
    set breed captains
  ]
end

to assign-bodyguards
  let i 0
  let max-bg 10
  ask one-of captains with [team = 2][
    while [ i < 10][
      
      ask one-of agents with [team = 2] with-min [distance myself] [
        set breed bodyguards
        set i i + 1
      ]
    ]
  ]
  
  set i 0 
  
  ifelse offense-strat-team1 = "patrol" [
    set max-bg 10
  ][
  set max-bg 7
  ]
  
  ask one-of captains with [team = 1][
    while [ i < max-bg][
      
      ask one-of agents with [team = 1] with-min [distance myself] [
        set breed bodyguards
        set i i + 1
      ]
    ]
  ]  
end

to assign-flagdefenders
  ask agents [ 
    set breed flagdefenders
  ]
end

to assign-flags
  
  create-flags 1[
    set team 1 
    set color red
    setxy 0 15
    set pcolor red + 3
  ]
  
  create-flags 1[
    set team 2 
    set color green
    setxy 0 -15
    set pcolor green + 3
  ]
  
end

to setup
  clear-turtles
  clear-patches
  assign-flags
  setup-turtles
;  create
  set-globals
  default-shapes
  search-for-captain
  assign-captains
  set-halos
  
  assign-bodyguards
  assign-flagdefenders
  
  assign-variables;;sets init values for variables owned by each role
  
;  
;  set-teamcolor


;  set-hp-bars
;  reposition-team1
;  reposition-team2  
end

to set-halos
  ask captains [make-halo]  
end

to set-hp-bars
  ask turtles with [is-player =  true] [make-hp-bar]  
end

to show-life
  ask turtles with [is-player = true][
  ifelse show-life?
    [ set label life ]
    [ set label "" ]
  ]
end

to update-captains

  ask captains[
    
    let myteam team
    let myflag one-of flags with [team = myteam]  
    let enemyflag one-of flags with [team != myteam] 
    let front patch-ahead 1
    let basex 0
    let basey 15
    ifelse team = 1
    [set basey 15]
    [set basey -15]
    

    
    ;Si ya llego a la base enemiga captura la bandera enemiga 
    ifelse distance enemyflag <= 1
    [
      setxy ([xcor] of enemyflag ) ([ycor] of enemyflag) 
      ask enemyflag [
        set color yellow
        set status "captured"
      ]
      create-link-to enemyflag [tie] 
    ][
    
        ;Si la bandera enemiga no se ha capturado se dirige hacia la bandera enemiga   
    if (any? flags with [team != myteam and status != "captured"])
        [set heading towards enemyflag]  
              
    ]
    
    ;;;;;;;;;;;;;;;;
    ;Para el equipo sin inteligencia:
    ;El capitan pide a los guardaespaldas que lo defiendan cuando hay enemigos cercanos a ￩l
        if myteam = 2[
      ifelse any? turtles with [team != myteam and is-player = true] in-radius 3 [
        ;show "enemy near"
        ask bodyguards with [team = myteam ][
          set behavior "defend"
        ]
      ]
      [
        ask bodyguards with [team = myteam ][
          set behavior "patrol"
        ]
      ]
      move
    ]

    ;;;;;;;;;;;;;;;;;
    ;Para el equipo con inteligencia:
    
    ;remove contract from flagdefenders to allow him enter
    ask enemyflag [
      ifelse status = "captured" and distance patch basex basey < 3[
        ;;disperse flagdefenders
        ask flagdefenders with[team = myteam and behavior = "contracted"][
          set behavior "disperse" 
        ] 
      ]
      [
      ask flagdefenders with[team = myteam and behavior = "disperse"][
        set behavior "patrol" 
      ] 
      ]
    ]
    ;;;;;;;;;;;;;;
    
    if myteam = 1[
      
      if offense-strat-team1 = "V" [
      
        ;;patches list of V formation
        ;     |p7|X.|C.|X.|p8|
        ;     |p5|X.|X.|X.|p6|
        ;        |p2|X.|p4|
        ;        |X.|p1|X.|
        let p1 patch xcor (ycor - 3)
        let p2 patch (xcor - 1) (ycor - 2)
        let p3 patch (xcor) (ycor - 2)
        let p4 patch (xcor + 1) (ycor - 2)
        let p5 patch (xcor - 2) (ycor - 1)
        let p6 patch (xcor + 2) (ycor - 1)
        let p7 patch (xcor - 2) (ycor)
        let p8 patch (xcor + 2) (ycor)
        
        let positions (list p1 p2 p4 p5 p7 p6 p8) ;removiendo p3
        let i 0
        set i 0
        let p nobody
        
        if contract-ready = false[
        foreach contracted-list[
          
          set p item i positions
          if ?1 = nobody and p != nobody[
            let to-be-contracted one-of bodyguards with [team =  myteam and behavior != "contracted" and behavior !="disperse"] with-min [distance p]
            
            if to-be-contracted != nobody[
              ask to-be-contracted
              [
                set patch-to-defend p
                set behavior "contracted"
              ]
              set contracted-list (replace-item i contracted-list to-be-contracted)
              
            ] 
          ] 
          set i i + 1
        ]
        set contract-ready true
        ]
      
      
      ;;;;;;;;;;;;;
        if all-in-position = false[
          if ticks > 10 [
            set all-in-position true
          ]
        ]
        
        if all-in-position = true [
          set i 0
         if (ticks mod 2) = 0 [
        move
         ]
          ;;update patch to protect
          foreach contracted-list[
            if ? != nobody[
              ask ? [
                set patch-to-defend  (item i positions)
              ] 
            ]
          ]
          set i i + 1
          ;;;;;;;;
          
          if (any? flags with [team != myteam and status != "captured"])
          [set heading towards enemyflag];;TODO: reduce
          
          if front != nobody[
            if any? (flags-on front) with [team != myteam];;Validar aqui por que en veces no captura bien la bandera
            [
              setxy ([xcor] of enemyflag ) ([ycor] of enemyflag) 
              ask enemyflag [
                set color yellow
                set status "captured"
              ]
              create-link-to enemyflag [tie] 
            ]
          ]
          
        ]

      ]
      
    ]
    
  ]
  
end

to move
  

  let front patch-ahead 1
  let alternatives []

;      if is-captain? self and all-in-position = false and offense-strat-team1 = "V" [
;       stop
;      ]
;      
;      if is-bodyguard? self and offense-strat-team1 = "V" and patch-to-defend != nobody and (distance patch-to-defend = 0) [
;        stop
;      ]
      
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
    ;left (one-of angle) ;;probablemente sea mejor poner un heading hacia una casilla vacia para que no pierda tiempo.
    ;try to move
    
      ]
  ]
  
  
end

to patrol-flag
  ;;PATROL
  ask-concurrent flagdefenders with [behavior = "patrol"][ 
    let myteam team
    let myflag one-of flags with [team = myteam]  
    
    ifelse ( distance myflag > 5) [
      ;set color blue;;blink out of range turtles    
                    ;;move to a patch with less distance
      face myflag
      move
    ]
    [
      ;;move random if inside safe radius
      set heading random 360
      move
    ] 
  ]
  
  ;;DISPERSE
  ask flagdefenders with [behavior = "disperse"][
    let pos[ -90 90]
    left one-of pos
    move
  ]  
  
  ;;CONTRACTED
  ask flagdefenders with [behavior = "contracted" and patch-to-defend != nobody][
    let myteam team
    let mydmg dmg
    let myflag one-of flags with [team = myteam] 
    let mycaptain one-of captains with [team = myteam]
    
    let enemies []
    let front patch-ahead 1
    
    if distance patch-to-defend > 0[
      set heading towards patch-to-defend
      move
    ]
    
      set enemies turtles with [team != myteam and is-player = true] in-radius 2 
    
    ifelse any? enemies
    [face one-of enemies]
    [face myflag]
    
    
    if front != nobody [
      if (any? (turtles-on front) with [team != myteam and is-player = true])[
        ask (turtles-on front) with [team != myteam and is-player = true] [
          set color pink;;TODO:blink   
          set life life - mydmg
          update-hp-bar
          dead?;;check if turtles hp is empty and kill turtle if <= 0
          
        ]
      ]
    ]
    
  ]
  
  ;;DEFEND
  ask flagdefenders with [behavior = "defend"][
    ;show "enemy inside radius"
    let myteam team
    let mydmg dmg
    let myflag one-of flags with [team = myteam]  
    
    let enemies []
    ;;attack intruder
    
    let front patch-ahead 1
    ;let alternatives []
    
    if front != nobody [
      if (any? (turtles-on front) with [team != myteam and is-player = true])[
        ;;if  turtle one-of [who] of turtles-here team = 
        ask (turtles-on front) with [team != myteam and is-player = true] [
          ;show team
          ;show myteam
          ;if (team != myteam) [
          set color pink;;TODO:blink   
          set life life - mydmg
          update-hp-bar
          dead?;;check if turtles hp is empty and kill turtle if <= 0
               ;]
        ]
      ]
      ;    [ ]
    ]
    
    ask myflag [
      set enemies turtles with [team != myteam and is-player = true] in-radius 5 
    ]
    
    ifelse any? enemies[
      face one-of enemies
    ][
    face myflag
    ]
    
  ]
end


to update-flag-status
  ask flags[
    let myteam team
    
    if myteam = 1[
      if defense-strat-team1 = "patrol" [
        ifelse any? turtles with [team != myteam] in-radius 5 [
          ;show "enemy near"
          ask flagdefenders with [team = myteam ][
            set behavior "defend"
          ]
        ][
        ;;solo para pruebas, faltan considerar otros aspectos como cuando el capitan se roba la bandera
        ask flagdefenders with [team = myteam ][
          set behavior "patrol"
        ]
        ]
      ]
      
      if defense-strat-team1 = "box" and status = "in-base" [ 
        ;;CNET algorithm
        
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
        ;;TODO: tal vez colocarlos en otro orden para que no se estorben y luego si llenar por prioridad
        let positions (list p1 p2 p3 p4 p5 p6 p7); sort neighbors; p2 p3 p4 p5 p6 p7 p8 ]
                                                 ;;problem: flag needs to be covered from enemy captain
                                                 ;       show positions
                                                 ;       show contracted-list
                                                 ;;validate flag has jobs
                                                 ;       ;update-contracted-list
        let i 0
        let p nobody
        foreach contracted-list[
          
          set p item i positions
          if ?1 = nobody[
            let to-be-contracted one-of flagdefenders with [team =  myteam and behavior != "contracted" and behavior !="disperse"] with-min [distance p]
            
            if to-be-contracted != nobody[
              ask to-be-contracted
              [
                set patch-to-defend p
                set behavior "contracted"
;                set color cyan
                ;;agregar fd a contracted-list
              ]
              set contracted-list (replace-item i contracted-list to-be-contracted)
              
            ] 
          ] 
          set i i + 1
        ]
        
        ;;anouncement
        foreach positions[
          
        ]
        
        ifelse any? turtles with [team != myteam] in-radius 5 [
          ;show "enemy near"
          ask flagdefenders with [team =  myteam and behavior != "contracted" and patch-to-defend = nobody][
            set behavior "defend"
          ]
        ][
        ;;solo para pruebas, faltan considerar otros aspectos como cuando el capitan se roba la bandera
        ask flagdefenders with [team =  myteam and behavior != "contracted" and patch-to-defend = nobody][
          set behavior "patrol"
        ]
        
        
        ]
      ]
      
      if defense-strat-team1 = "box" and status = "captured" [ 
          ask flagdefenders with [team = myteam ][
          set behavior "defend"
        ]
      ]
    ]
    
    if myteam = 2[
      ifelse any? turtles with [team != myteam] in-radius 5 [
        ;show "enemy near"
        ask flagdefenders with [team = myteam ][
          set behavior "defend"
        ]
      ][
      ;;solo para pruebas, faltan considerar otros aspectos como cuando el capitan se roba la bandera
      ask flagdefenders with [team = myteam ][
        set behavior "patrol"
      ]
      ]
    ]
    
    
    if status = "in-base" [
      let basx 0
      let basy 15
      ifelse team = 1
      [set basy 15]
      [set basy -15] 
      
      set xcor basx
      set ycor basy
    ]
    
    if status = "captured"[
      
      ; setxy posxy (one-of captains with [team != myteam])
      set color orange
      if one-of captains with [team != myteam] != nobody [
        ask one-of captains with [team != myteam] [
          let basex 0
          let basey 15
          ifelse team = 1
          [set basey 15]
          [set basey -15]   
          ifelse any? patches with [pxcor = basex and pycor = basey] in-radius 1
          [
            set winner team
            write "Team" 
            write team
            print " WINS"
            repeat 3 [ beep ]
            set end-game true
          ]
          [set heading towardsxy basex basey]
        ]
      ]
    ]
    if one-of captains with [team = myteam] = nobody[
      ;ask turtles  with [team =  myteam and is-player and life > 0] [
      ask one-of flags with [team != myteam] [set  status "in-base"] 
      if any? turtles with [team =  myteam and is-player and life > 0][
      ask max-one-of turtles  with [team =  myteam and is-player and life > 0] with-min [distance (one-of flags with [team != myteam])] [life]  
        [set breed captains
          set contracted-list[nobody nobody nobody nobody nobody nobody nobody]
          set all-in-position true
          ask bodyguards with [team = myteam][
           set behavior "patrol" 
          ]
          make-halo
        ]
      ]
      
    ]  
    
  ]
  
  
  
end

;;validates no turtle is on the way to prevent duplicated positions
to validate-captain 
  let val patch-ahead 1
  if val != nobody [
    if not any? turtles-on val[
      fd 1 ;;validate here if carrying flag
    ]
  ]
end

to guard-captain
  
  ;follow captain in radius 3 with random movement in this area (patrolling)
  ;if enemy enters in radius 3, attack
  
  ;;PATROL
  ask bodyguards with [behavior = "patrol"][
    
    let myteam team
    let mycaptain one-of captains with [team = myteam]  
    
    ifelse ( mycaptain != nobody and distance mycaptain > 3) [
      ;set color white;;blink out of range turtles    
                     ;;move to a patch with less distance
      face mycaptain
      move
    ]
    [
      ;;move random if inside safe radius
      set heading random 360
     move
    ] 
  ]
  
    ;;CONTRACTED
  ask bodyguards with [behavior = "contracted" and patch-to-defend != nobody][
    let myteam team
    let mydmg dmg
    let myflag one-of flags with [team = myteam] 
    let mycaptain one-of captains with [team = myteam]
    
    let enemies []
    let front patch-ahead 1
    
    if distance patch-to-defend > 0[
      set heading towards patch-to-defend
      move
    ]
    
;    ask myflag [
      set enemies turtles with [team != myteam and is-player = true] in-radius 2 
;    ]
    
    ifelse any? enemies[
      face one-of enemies
    ][
    face mycaptain
    ]
    
    ;;attack enemy captain
    ;    if one-of captains with [team != myteam] != nobody[
    ;      face one-of captains with [team != myteam]
    ;    ]
    
    if front != nobody [
      if (any? (turtles-on front) with [team != myteam and is-player = true])[
        ask (turtles-on front) with [team != myteam and is-player = true] [
          set color pink;;TODO:blink   
          set life life - mydmg
          update-hp-bar
          dead?;;check if turtles hp is empty and kill turtle if <= 0
          
        ]
      ]
    ]
    
  ]
  
  
  ;;DEFEND
  ask bodyguards with [behavior = "defend"][
    ;show "enemy inside radius"
    let front patch-ahead 1
    let myteam team
    let mydmg dmg
    let mycaptain one-of captains with [team = myteam] 
    
    let enemies []
    
    ;;attack intruder
    if front != nobody [
      if (any? (turtles-on front) with [team != myteam and is-player = true])[
        ;;if  turtle one-of [who] of turtles-here team = 
        ask (turtles-on front) with [team != myteam and is-player = true] [
          ;show team
          ;show myteam
          ;if (team != myteam) [
          set color pink;;TODO:blink   
          set life life - mydmg
          update-hp-bar
          dead?;;check if turtles hp is empty and kill turtle if <= 0
               ; ]
        ]
      ]
      ;    [ ]
    ]
    if mycaptain != nobody[
      ask mycaptain [
        set enemies turtles with [team != myteam and is-player = true] in-radius 3 
      ]
      
      ifelse any? enemies[
        face one-of enemies
      ][
      face mycaptain
      ]
      
    ] 
  ]
end

to dead?
  if (life <= 0) [
    die-clean
    ;die ;;maybe use die-clean
  ]
end

;;TODO: Crear mas barras para ver mejor la vida
;;update hp-bar
to update-hp-bar
  ask self [
    if life > 75 and life <= 100 [
      ask hp-bars-here [
        set shape "hp bar"
      ]
    ]
    if life > 50 and life <= 75 [
      ask hp-bars-here [
        set shape "hp bar 3/4"
      ]
    ]
    if life > 25 and life <= 50 [
      ask hp-bars-here [
        set shape "hp bar 1/2"
      ]
    ]
    if life > 0 and life <= 25 [
      ask hp-bars-here [
        set shape "hp bar 1/4"
      ]
    ]  
  ]
  
end

;;removes also visual effects together with turtle and kill turtle
to die-clean
  ask self[
    if is-flagdefender? self and behavior = "contracted" [
      ;;buscar en lista y cambiar a nobody
      let i 0
      let p nobody
      ask flags[
        foreach contracted-list[
          
          if ?1 = patch-here[
            set contracted-list (replace-item i contracted-list nobody)
          ] 
        ] 
      ]
      set i i + 1
    ]
    
;    if is-captain? self [
;     show "captain [who] is dead" 
;    ]
    
        if is-bodyguard? self and behavior = "contracted" [
      ;;buscar en lista y cambiar a nobody
      let i 0
      let p nobody
      ask captains[
        foreach contracted-list[
          
          if ?1 = patch-here[
            set contracted-list (replace-item i contracted-list nobody)
          ] 
        ] 
      ]
      set i i + 1
    ]
        
    ask turtles-here with [is-eye-candy = true ] [
      die
    ]
    
    die
  ]
end

to normal-setup
  setup
end

to normal-start
  set-teamcolor
  update-flag-status
  update-captains
  guard-captain
  patrol-flag
  show-life
  ;move
  tick
  if (end-game = true)
  [stop ] 
end

to start
  clear-all
  set winred 0
  set wingreen 0
  if ciclos < 2
  [set ciclos 1]
  repeat ciclos [
    setup
    one-game
    do-plots
    if winner = 1 [set winred winred + 1]
    if winner = 2 [set wingreen wingreen + 1]
    reset-ticks 
  ]
end

to one-game
  set-teamcolor
  update-flag-status
  update-captains
  guard-captain
  patrol-flag
  show-life
  ;move
  tick
  ifelse (end-game = true)
  [stop ] 
  [one-game]
  
end

to do-plots
  set-current-plot "Sobrevivientes"
  set-current-plot-pen "Red"
  plot count turtles with [team = 1 and is-player = true]
  set-current-plot-pen "Green"
  plot count turtles with [team = 2 and is-player = true]
  set-current-plot "Tiempo de Juego"
  plot ticks
end
;;;;;;;;;;;;For visual effects

to make-halo  ;; runner procedure
  hatch-halos 1
  [ set size 1.5
    set is-eye-candy true
    set is-player false
    ;; Use an RGB color to make halo three fourths transparent
    set color lput 200 extract-rgb color
    ;; set thickness of halo to half a patch
    __set-line-thickness 0.1
    ;; We create an invisible directed link from the runner
    ;; to the halo.  Using tie means that whenever the
    ;; runner moves, the halo moves with it.
    create-link-from myself
    [ tie
      hide-link ] ]
end

to make-hp-bar  ;; runner procedure
  hatch-hp-bars 1
  [ set size 1
    set is-eye-candy true
    set is-player false
    ;; Use an RGB color to make halo three fourths transparent
    set color lput 125 extract-rgb color
    ;; set thickness of halo to half a patch
    __set-line-thickness 0.15
    ;; We create an invisible directed link from the runner
    ;; to the halo.  Using tie means that whenever the
    ;; runner moves, the halo moves with it.
    create-link-from myself
    [ tie
      hide-link ] ]
end
@#$#@#$#@
GRAPHICS-WINDOW
213
19
748
545
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
1
1
-1000

MONITOR
24
378
162
423
Red turtles (Team 1)
count turtles with [team = 1 and is-player = true]
17
1
11

MONITOR
20
437
168
482
Green turtles(Team 2)
count turtles with [team = 2 and is-player = true]
17
1
11

TEXTBOX
25
214
175
232
Team #1 Controls
14
0.0
1

CHOOSER
18
238
172
283
defense-strat-team1
defense-strat-team1
"patrol" "box"
1

CHOOSER
18
297
169
342
offense-strat-team1
offense-strat-team1
"patrol" "V"
1

INPUTBOX
21
28
176
88
ciclos
50
1
0
Number

BUTTON
79
117
142
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
Sobrevivientes
Juego
Sobrevivientes
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
928
448
Equipo Rojo
winred
17
1
11

MONITOR
947
404
1055
449
Equipo Verde
wingreen
17
1
11

TEXTBOX
896
368
1046
393
Victorias
20
0.0
1

PLOT
772
200
1176
350
Tiempo de Juego
Juego
Ticks
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

BUTTON
797
490
908
523
NIL
normal-start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
952
469
1069
502
NIL
normal-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

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
Polygon -1184463 true false 150 90 149 83 101 83 49 151 69 192 71 199 107 157 112 195 81 284 95 298 143 299 150 256 158 298 204 298 219 283 188 191 193 155 223 193 249 145 199 84 149 84
Circle -1184463 true false 105 0 90
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 210 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 195 90 240 150 225 180 165 105

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
