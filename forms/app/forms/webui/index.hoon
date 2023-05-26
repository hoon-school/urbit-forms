/-  *forms-states,
    *forms
/+  fl=forms,
    rudder
::
^-  (page:rudder state-1 action)
::
|_  [=bowl:gall order:rudder state=state-1]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  =/  args=(map @t @t)
    ?~(body ~ (frisk:rudder q.u.body))
  ?~  what=(~(get by args) 'what')
    ~
  ?:  =('edit' u.what)  !!
  ?:  =('delete' u.what)
    =/  survey-id  (need (slaw %ud (~(got by args) 'survey-id')))
    `action`[%delete survey-id]
  ::+$  create  [%create =title =description =visibility =slug =rlimit]
  ?:  =('create' u.what)
    =/  title        (~(got by args) 'title')
    =/  description  (~(got by args) 'description')
    =/  viz          (~(got by args) 'visibility')
    =/  visibility   ?:(=('on' viz) %public %private)
    =/  slug         (scot %da now:bowl)
    =/  rlimit       (need (slaw %ud (~(got by args) 'rlimit')))
    `action`[%create title description visibility slug rlimit]
  !!
::
++  final  (alert:rudder url.request build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ::
  |^  [%page page]
  ::
  ++  icon-color  "black"
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }

    p { max-width: 50em; }

    form { margin: 0; padding: 0; }

    .red { font-weight: bold; color: #dd2222; }
    .green { font-weight: bold; color: #229922; }

    a {
      display: inline-block;
      color: inherit;
      padding: 0;
      margin-top: 0;
    }

    .class-filter a {
      background-color: #ccc;
      border-radius: 3px;
      padding: 0.1em;
    }

    .class-filter.all .all,
    .class-filter.mutual .mutual,
    .class-filter.target .target,
    .class-filter.leeche .leeche {
      border: 1px solid red;
    }

    .label-filter a {
        background-color: #ddd;
        border-radius: 3px;
        padding: 0.1em;
    }

    .label-filter a.yes {
      border: 1px solid blue;
    }

    .class-filter .all::before,
    .class-filter .mutual::before,
    .class-filter .target::before,
    .class-filter .leeche::before,
    .label-filter a::before {
      content: '☐ '
    }

    .class-filter.all .all::before,
    .class-filter.mutual .mutual::before,
    .class-filter.target .target::before,
    .class-filter.leeche .leeche::before,
    .label-filter a.yes::before {
      content: '☒ '
    }

    table#pals tr td:nth-child(2) {
      padding: 0 0.5em;
    }

    .sigil {
      display: inline-block;
      vertical-align: middle;
      margin: 0 0.5em 0 0;
      padding: 0.2em;
      border-radius: 0.2em;
    }

    .sigil * {
      margin: 0;
      padding: 0;
    }

    .label {
      display: inline-block;
      background-color: #ccc;
      border-radius: 3px;
      margin-right: 0.5em;
      padding: 0.1em;
    }
    .label input[type="text"] {
      max-width: 100px;
    }
    .label span {
      margin: 0 0 0 0.2em;
    }

    button {
      padding: 0.2em 0.5em;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%forms"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==  :: head
      ;body
        ;h2:"Urbit Forms"

        The following surveys are available:

        ;table#surveys
          ;form(method "post")
            ;tr(style "font-weight: bold")
              ;td:"Form ID"
              ;td:"Title"
              ;td:"Description"
              ;td:"Source"
              ;td:"Edit"
              ;td:"Delete"
            ==
            ;*  local-surveys
            ;*  alien-surveys
          ==
        ==

        Create a new form:

        ;form(method "post")
          ;input(type "text", name "title", placeholder "Form title");
          ;input(type "text", name "description", placeholder "Description");
          ;input(type "checkbox", name "visibility", placeholder "Visibility");
          ;input(type "number", name "rlimit", placeholder "Number of respondents");
          ;button(type "submit", name "what", value "create"):"Create a new survey"
        ==
      ==  :: body
    ==  :: html
  ::
  ++  local-surveys
    ^-  (list manx)
    =/  slugs=slugs  (~(got by slug-store:state) our.bowl)
    =/  survey-ids=(list survey-id)  ~(val by slugs)
    =/  local-survey-ids  (sort survey-ids gth)
    %+  turn  local-survey-ids
    |=  =survey-id
    ^-  manx
    =/  hdr=metadata-1  (got:header-orm:fl headers:state survey-id)
    ;tr
      ;td: {(a-co:co survey-id)}
      ;td: {(trip title:hdr)}
      ;td: {(trip description:hdr)}
      ;td: {<author:hdr>}
      ;td
        ;+  (edit-button survey-id)
      ==
      ;td
        ;+  (delete-button survey-id)
      ==
    ==
  ::
  ++  alien-surveys
    ^-  (list manx)
    =/  alien-surveys=(map ship slugs)  (~(del by slug-store:state) our.bowl)
    =/  slugs=slugs  (roll ~(val by alien-surveys) |=([p=slugs q=slugs] (~(uni by p) q)))
    =/  survey-ids=(list survey-id)  ~(val by slugs)
    =/  all-survey-ids  (sort survey-ids gth)
    %+  turn  all-survey-ids
    |=  =survey-id
    ^-  manx
    =/  hdr=metadata-1  (got:header-orm:fl headers:state survey-id)
    ;tr
      ;td: {(a-co:co survey-id)}
      ;td: {(trip title:hdr)}
      ;td: {(trip description:hdr)}
      ;td: {<author:hdr>}
      ;td:""
      ;td
        ;+  (delete-button survey-id)
      ==
    ==
  ::
  ++  edit-button
    |=  =survey-id
    ^-  manx
    ;form(method "post")
      ;input(type "hidden", name "survey-id", value "{(scow %ud survey-id)}");
      ;button(type "submit", name "what", value "edit"):"✍️"
    ==
  ::
  ++  delete-button
    |=  =survey-id
    ^-  manx
    ;form(method "post")
      ;input(type "hidden", name "survey-id", value "{(scow %ud survey-id)}");
      ;button(type "submit", name "what", value "delete"):"❌"
    ==
  --
--
