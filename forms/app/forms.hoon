/-  *forms-states,
    *forms
/+  default-agent,
    dbug,
    fl=forms,
    rudder,
    upgrade
/~  pages-overview  (page:rudder state-1 action)  /app/forms/webui
|%
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-1
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-arvo
  |=  [wir=wire sig=sign-arvo]
  ^-  (quip card _this)
  ?:  =(wir /apps/forms/cast)  ::  handle the response from posting
    ?>  ?=([%iris %http-response %finished * ~ *] sig)
    =/  res=json  (need (de-json:html q.data.u.full-file.client-response.sig))
    ?>  ?=(%o -.res)
    =/  redirect-url  (~(got by p.res) %url)
    ?>  ?=(%s -.redirect-url)
    =/  wirr  [/http-response/[&2.wir]]~
    =/  =response-header:http
      ^-  response-header:http
      :-  200  ~
    :_  this
    :~  [%give %fact wirr %http-response-header !>(response-header)]
        [%give %fact wirr %http-response-data !>(~)]
        [%give %kick wirr ~]
    ==
  `this
++  on-fail   on-fail:def
++  on-leave  on-leave:def
++  on-init
  ^-  (quip card _this)
  :_  this(slug-store (~(put by slug-store) our.bowl *slugs))
  :~  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %1  `this(state old)
    %0  `this(state (convert-0-to-1:upgrade old our.bowl))
  ==
::
++  on-watch 
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
      [%http-response *]
    %-  (slog leaf+"Eyre subscribed to {(spud path)}." ~)
    [~ this]
    ::
      [%headers %all ~]
    :_  this
    ~[give+fact+`forms-cmd+!>(`cmd`(frond:enjs:format ['flag' s+'refresh']))]
    ::
      [%survey @ ~]
    =/  id=survey-id   (slav %ud i.t.path)
    =+  m=(got:header-orm:fl headers id)
    ?>  =(%public visibility.m)
    =+  s=(got:stuffing-orm:fl stuffing id)
    :_  this(subscribers (add-subs:fl subscribers id src.bowl))
    :~  :*
      %give  %fact   ~
      %forms-update  !>  `update`init+[m s]
    ==  ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
      [%x %headers ~]
    ``forms-json+!>(`frontend`header+headers)
      [%x %active @ @ ~]
    =+  g=(~(got by slug-store) (slav %p i.t.t.path))
    =+  id=(~(got by g) i.t.t.t.path)
    =+  m=(got:header-orm:fl headers id)
    =+  s=(got:stuffing-orm:fl stuffing id)
    =+  sb=(got:submissions-orm:fl submissions id)
    =+  d=sections:(got:responses-1-orm:fl sb %draft)
    ``forms-json+!>(`frontend`active+[id m s d])
      [%x %submissions @ ~]
    =+  id=`survey-id`(slav %ud i.t.t.path)
    =+  r=(got:submissions-orm:fl submissions id)
    ``forms-json+!>(`frontend`responses+r)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+  mark  (on-poke:def mark vase)
      %forms-action
    =^  cards  state
      (handle-action !<(action vase))
    [cards this]
    ::
      %forms-request
    =^  cards  state
      (handle-request !<(request vase))
    [cards this]
    ::
      %forms-edit
    =^  cards  state
      (handle-edit !<(edit vase))
    [cards this]
    ::
      %handle-http-request
    =;  out=(quip card _state)
      [-.out this(state +.out)]
    %.  [bowl !<(order:rudder vase) state]
    %-  (steer:rudder _state action)
    :^    pages-overview
        (point:rudder /[dap.bowl] & ~(key by pages-overview))
      (fours:rudder state)
    |=  axn=action
    ^-  $@  brief:rudder
        [brief:rudder (list card) _state]
    =^  caz  this
      (on-poke %forms-action !>(axn))
    ['Processed succesfully.' caz state]
  ==
  ++  handle-action
    |=  act=action
    ^-  (quip card _state)
    ?>  =(src our):bowl
    ?-  -.act
        %create
      =+  id=(make-survey-id:fl now.bowl our.bowl) 
      =,  enjs:format
      =+  sl=(~(got by slug-store) our.bowl)
      ?>  =(~ (~(get by sl) slug.act))
      =+  m=(create-metadata-1:fl act our.bowl now.bowl)
      =+  g=(~(put by sl) slug.act id)
      =+  gg=(~(put by slug-store) our.bowl g)
      =+  h=(put:header-orm:fl headers id m)
      =+  sc=(put:section-orm:fl *section 1 *question-1)
      =+  ss=(put:sections-orm:fl *sections 1 *section)
      =+  st=(put:stuffing-orm:fl stuffing id ss)
      =+  sb=(~(put by subscribers) id *ships)
      =+  rc=(put:section-orm:fl *section 1 *answer-1)
      =+  rp=(put:sections-orm:fl *sections 1 *section)
      =+  rs=(~(put by *responses-1) %draft [our.bowl rp])
      =+  sm=(put:submissions-orm:fl submissions id rs)
      :-  
      :~  :*
        %give  %fact  ~[/headers/all]
        %forms-cmd  !>
        `cmd`(pairs ~[['flag' s+'ask'] ['id' s+(scot %ud id)]])
      ==  ==
      state(headers h, slug-store gg, stuffing st, subscribers sb, submissions sm)
        ::
        %ask
      :_  state(pending (~(put in pending) [author.act slug.act]))
      :~  :*
        %pass   /slug
        %agent  [author.act %forms]
        %poke   %forms-request  !>  slug+slug.act
      ==  ==
        ::
        %delete
      =+  m=(got:header-orm:fl headers survey-id.act)
      =+  h=+:(del:header-orm:fl headers survey-id.act)
      =+  s=+:(del:stuffing-orm:fl stuffing survey-id.act)
      =+  sb=+:(del:submissions-orm:fl submissions survey-id.act)
      =+  sl=(~(got by slug-store) our.bowl)
      =+  g=(~(del by sl) slug.m)
      =+  gg=(~(put by slug-store) our.bowl g)
      ?.  =(our.bowl author.m)
        :_  state(headers h, stuffing s, submissions sb, slug-store gg)
        :~  :*
          %pass   /updates/(scot %ud survey-id.act)
          %agent  [author.m %forms]
          %leave  ~
        ==  ==
        =+  sr=(~(get by subscribers) survey-id.act)
        =+  sd=(~(del by subscribers) survey-id.act)
        ?~  sr
          `state(headers h, stuffing s, submissions sb, slug-store gg)
        =+  sn=~(tap in (need sr))
        ?~  sn
          `state(headers h, stuffing s, submissions sb, slug-store gg, subscribers sd)
        :_  state(headers h, stuffing s, submissions sb, slug-store gg, subscribers sd)
        (turn sn |=(a=@p [%give %kick ~[/survey/(scot %ud survey-id.act)] `a]))
        ::
        %editdraft
      =+  sb=(got:submissions-orm:fl submissions survey-id.act)
      =+  sd=(got:responses-1-orm:fl sb %draft)
      =+  sc=(get:sections-orm:fl sections.sd section-id.act)
      =+  x=?~(sc *section (need sc))
      =+  a=(put:section-orm:fl x question-id.act answer-1.act)
      =.  sections.sd
        (put:sections-orm:fl sections.sd section-id.act a)
      =+  se=(~(put by sb) %draft sd)
      =+  sn=(put:submissions-orm:fl submissions survey-id.act se)
      `state(submissions sn)
        %submit
      =+  st=(got:stuffing-orm:fl stuffing survey-id.act)
      =+  sb=(got:submissions-orm:fl submissions survey-id.act)
      =+  rs=(~(got by sb) %draft)
      =+  checked=(check-response:fl st +.rs)
      =+  [n=0 failed=0]
      |-
      ?:  (gte n (lent checked))
        ?<  (gth failed 0)
        =+  id=(make-response-id:fl now.bowl our.bowl survey-id.act) 
        =+  ss=(~(put by sb) id rs)
        =+  sn=(~(put by ss) %draft [our.bowl *sections])
        =+  survey-author=author:(got:header-orm:fl headers survey-id.act)
        :_  state(submissions (put:submissions-orm:fl submissions survey-id.act sn))
        :~  :*
          %pass   /submit
          %agent  [survey-author %forms]
          %poke   %forms-request  !>  response+[survey-id.act id rs]
        ==  ==
      =+  f=(lent failed:(snag n `(list [sec=@ud [failed=(list @ud) succeeded=(list @ud)]])`checked))
      $(failed (add f failed), n +(n))
        ::
        %delsubmission
      =+  sb=(got:submissions-orm:fl submissions survey-id.act)
      =+  se=+:(del:responses-1-orm:fl sb response-id.act)
      =+  sn=(put:submissions-orm:fl submissions survey-id.act se)
      `state(submissions sn)
    ==
    ++  handle-edit
    |=  ed=edit
    ^-  (quip card _state)
    ?>  =(src our):bowl
    =+  m=(got:header-orm:fl headers survey-id.ed)
    =.  updated.m
      now.bowl
    ?-  -.ed
        %addsection
      =+  so=(got:stuffing-orm:fl stuffing survey-id.ed)
      =+  sc=(put:sections-orm:fl so section-id.ed *section)
      =+  sn=(put:stuffing-orm:fl stuffing survey-id.ed sc)
      =.  s.size.m
        +(s.size.m)
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h, stuffing sn)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`secs+sc
      ==  ==
        ::
        %delsection
      =+  so=(got:stuffing-orm:fl stuffing survey-id.ed)
      =+  sid=section-id.ed
      ?<  (gth sid s.size.m)  
      =.  q.size.m
        (oust [(dec sid) 1] q.size.m)
      ?:  =(sid s.size.m)
        =+  st=+:(del:sections-orm:fl so sid)
        =.  s.size.m
          (dec sid)
        =+  sn=(put:stuffing-orm:fl stuffing survey-id.ed st)
        =+  h=(put:header-orm:fl headers survey-id.ed m)
        :_  state(stuffing sn, headers h)
        :~  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`meta+m
        ==  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`secs+st
        ==  ==
      |-
      ?.  (gte sid s.size.m)
        =+  st=(got:sections-orm:fl so +(sid))
        =+  sn=(put:sections-orm:fl so sid st) 
        $(so sn, sid +(sid))
      =+  st=+:(del:sections-orm:fl so sid)
      =.  s.size.m
        (dec sid)
      =+  sn=(put:stuffing-orm:fl stuffing survey-id.ed st)
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(stuffing sn, headers h)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`secs+st
      ==  ==
        ::
        %delquestion
      =+  so=(got:stuffing-orm:fl stuffing survey-id.ed)
      =+  sc=(got:sections-orm:fl so section-id.ed)
      =+  n=(lent (tap:section-orm:fl sc))
      =.  q.size.m
        (snap q.size.m (dec section-id.ed) (dec (snag (dec section-id.ed) q.size.m)))
      ?:  =(n question-id.ed)
        =+  sn=+:(del:section-orm:fl sc question-id.ed)
        =+  ss=(put:sections-orm:fl so section-id.ed sn)
        =+  st=(put:stuffing-orm:fl stuffing survey-id.ed ss)
        =+  h=(put:header-orm:fl headers survey-id.ed m)
        :_  state(headers h, stuffing st)
        :~  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`meta+m
        ==  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`secs+ss
        ==  ==
      =+  qid=question-id.ed
      |-
      ?.  =(qid n)
        =+  q=(got:section-orm:fl sc +(qid))
        =+  sn=(put:section-orm:fl sc qid q)
        $(sc sn, qid +(qid))
      =+  sn=+:(del:section-orm:fl sc qid)
      =+  ss=(put:sections-orm:fl so section-id.ed sn)
      =+  st=(put:stuffing-orm:fl stuffing survey-id.ed ss)
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h, stuffing st)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`secs+ss
      ==  ==
        ::
        %addquestion
      =+  s=(got:stuffing-orm:fl stuffing survey-id.ed)
      =+  sc=(got:sections-orm:fl s section-id.ed)
      =+  q=(get:section-orm:fl sc question-id.ed)
      =+  qn=(put:section-orm:fl sc question-id.ed question-1.ed)
      =+  sn=(put:sections-orm:fl s section-id.ed qn)
      =+  st=(put:stuffing-orm:fl stuffing survey-id.ed sn)
      ?~  q
        =.  q.size.m
          %^    snap 
              q.size.m
            (dec section-id.ed)
          +((lent (tap:section-orm:fl sc)))
        =+  h=(put:header-orm:fl headers survey-id.ed m)
        :_  state(headers h, stuffing st)
        :~  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`meta+m
        ==  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`secs+sn
        ==  ==
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h, stuffing st)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`secs+sn
      ==  ==
        ::
        %title
      =.  title.m
        title.ed
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  ==
        ::
        %description
      =.  description.m
        description.ed
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  ==
        ::
        %rlimit
      =.  rlimit.m
        rlimit.ed
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      :_  state(headers h)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  ==
        ::
        %slug
      =+  sl=(~(got by slug-store) our.bowl)
      =+  e=(~(del by sl) slug.m)
      =.  slug.m
        slug.ed
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      =+  g=(~(put by e) slug.ed survey-id.ed)
      =+  gg=(~(put by slug-store) our.bowl g)
      :_  state(headers h, slug-store gg)
      :~  :*
        %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
        %forms-update  !>  `update`meta+m
      ==  ==
        ::
        %visibility
      =.  visibility.m
        visibility.ed
      =+  h=(put:header-orm:fl headers survey-id.ed m)
      ?.  =(%private visibility.ed)
        :_  state(headers h)
        :~  :*
          %give  %fact  [/survey/(scot %ud survey-id.ed) ~]
          %forms-update  !>  `update`meta+m
        ==  ==
      =+  s=~(tap in (~(got by subscribers) survey-id.ed))
      =+  ns=(~(put by subscribers) survey-id.ed *ships)
      :_  state(headers h, subscribers ns)
      ?:  =(0 (lent s))  ~
      (turn s |=(a=@p [%give %kick ~[/survey/(scot %ud survey-id.ed)] `a]))
    ==
    ::
  ++  handle-request
    |=  req=request
    ^-  (quip card _state)
    ?-  -.req
        %slug
      =+  g=(~(got by slug-store) our.bowl)
      =+  id=(~(get by g) slug.req)
      :_  state
      :~  :*
        %pass   /slug
        %agent  [src.bowl %forms]
        %poke   %forms-request  !>
        ?~  id  
          fail+slug.req  
          ?:  =(%public visibility:(got:header-orm:fl headers (need id)))
            id+[slug.req (need id)]
          fail+slug.req  
        ==  ==
      ::
        %fail
      %-  (slog leaf+"forms doesn't exist!" ~)
      :-
      :~  :*
        %give  %fact  ~[/headers/all]
        %forms-cmd  !>
        `cmd`(pairs:enjs:format ~[['flag' s+'requested'] ['status' s+'fail']])
      ==  ==
      state(pending (~(del in pending) [src.bowl slug.req]))
      ::
        %id
      =+  p=(~(del in pending) [src.bowl slug.req])
      =+  g=(~(get by slug-store) src.bowl)
      =+  sl=?~(g *slugs (need g))
      =+  s=(~(put by sl) slug.req survey-id.req)
      =+  gg=(~(put by slug-store) src.bowl s)
      :_  state(pending p, slug-store gg)
      :~  :*
        %give  %fact  ~[/headers/all]
        %forms-cmd  !>
        =,  enjs:format
        ^-  cmd
        (pairs ~[['flag' s+'requested'] ['status' s+(scot %ud survey-id.req)]])
      ==  :*
        %pass   /updates/(scot %ud survey-id.req)
        %agent  [src.bowl %forms]
        %watch  /survey/(scot %ud survey-id.req)
      ==  ==
        %response
      =+  sb=(got:submissions-orm:fl submissions survey-id.req)
      =+  st=(got:stuffing-orm:fl stuffing survey-id.req)
      ?>  =(src.bowl -.response-1.req)
      =+  checked=(check-response:fl st +.response-1.req)
      =+  [n=0 failed=0]
      |-
      ?:  (gte n (lent checked))
        ?<  (gth failed 0)
        =+  sn=(~(put by sb) response-id.req response-1.req)
        `state(submissions (put:submissions-orm:fl submissions survey-id.req sn))
      =+  f=(lent failed:(snag n `(list [sec=@ud [failed=(list @ud) succeeded=(list @ud)]])`checked))
      $(failed (add f failed), n +(n))
    ==
  --
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
      [%slug ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  p.sign
      `this
    %-  %-  slog  ^-  tang  (need p.sign)  `this
      [%updates @ ~]
    ?+  -.sign  (on-agent:def wire sign)
      %watch-ack
      ?~  p.sign  (on-agent:def wire sign)
      %-  %-  slog  ^-  tang  (need p.sign)  `this
      ::
      %kick
      =+  id=(slav %ud i.t.wire)
      =+  m=(got:header-orm:fl headers id)
      =.  status.m  %archived
      =+  h=(put:header-orm:fl headers id m)
      `this(headers h)
      ::
      %fact
      ?+  p.cage.sign  (on-agent:def wire sign)
        %forms-update
        =/  id=survey-id  (slav %ud i.t.wire)
        =+  upd=!<(update q.cage.sign)
        ?-  -.upd
            %meta
            =+  h=(put:header-orm:fl headers id metadata.upd)
            `this(headers h)
          ::
            %secs
            =+  s=(put:stuffing-orm:fl stuffing id sections.upd)
            `this(stuffing s)
          ::
            %init
          =,  enjs:format
          =+  h=(put:header-orm:fl headers id metadata.upd)
          =+  s=(put:stuffing-orm:fl stuffing id sections.upd)
          =+  rc=(put:section-orm:fl *section 1 *answer-1)
          =+  rp=(put:sections-orm:fl *sections 1 *section)
          =+  rs=(~(put by *responses-1) %draft [our.bowl rp])
          =+  sm=(put:submissions-orm:fl submissions id rs)
          :_  this(headers h, stuffing s, submissions sm)
          :~  :*
            %give  %fact  ~[/headers/all]  %forms-cmd
            !>
            ^-  cmd
            %-  pairs
            :~
              ['flag' s+'requested']
              ['status' s+'summon']
              :-  'addr'
              :-  %s
              %-  crip
              :(weld (trip (scot %p author.metadata.upd)) "/" (trip slug.metadata.upd))
            ==
          ==  ==
        ==  :: forms-update
      ==  :: fact
    ==  :: sign
  ==  :: wire
--
