let B = https://raw.githubusercontent.com/ear7h/buildsys3/main/prelude.dhall

let Prelude =  https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/package.dhall
let List/map = Prelude.List.map

let BUILD_DIR = "build/"
let DHALL = "dhall"

let cmd = λ(cmd : Text) → λ(args : List Text) → { cmd, args } : B.Command
let bash = λ(script : Text) → cmd "bash" [ "-c", script ]
let dhallText
  = λ(input : Text) →
    λ(output : Text) →
      cmd "dhall" [ "text", "--file", input, "--output", BUILD_DIR ++  output ]

let mkMain
  = λ(p : Text) → B.generated
    { results = [ BUILD_DIR ++ p ++ ".html" ]
    , command = dhallText (p ++ ".dhall") (p ++ ".html")
    , prereqs =
      [ B.source "common.dhall"
      , B.source (p ++ ".dhall")
      ]
    }

let mainPages = List/map Text B.Item mkMain
	[ "posts", "index", "projects", "graphics", "me" ]


let blogPosts =
  let html = λ(p : Text) →
    let out = BUILD_DIR ++ "posts/" ++ p ++ ".html"
    let input = "posts/" ++ p
    in B.generated
      { results = [ out ]
      , command = bash ''
        echo "(./common.dhall).renderPost (./${input ++ ".dhall"})" | ${DHALL} text --output ${out}
        ''
      , prereqs =
        [ B.source (input ++ ".dhall")
        , B.source (input ++ ".content.html")
        ]
      }
  let md = λ(p : Text) →
    let out = BUILD_DIR ++ "posts/" ++ p ++ ".html"
    -- TODO: get rid of this intermidiary
    let tmp = "posts/" ++ p ++ ".content.md.html"
    let input = "posts/" ++ p
    in B.generated
      { results = [ out ]
      , command = bash ''
        pandoc -f gfm -t html ${input ++ ".md"} > ${tmp}
        echo "(./common.dhall).renderPost (./${input ++ ".dhall"})" | ${DHALL} text --output ${out}
        ''
      , prereqs =
        [ B.source (input ++ ".dhall")
        , B.source (input ++ ".md")
        ]
      }
  in
    [ html "2021-06-02-hello-world"
    , html "2021-06-07-algebra"
    , html "2021-06-07-slack-vs-discord"
    , md "2021-08-17-gsoc-final"
    ]

let buildDirs =
  let d = λ(p : Text) → B.generated
    { results = [ BUILD_DIR ++ p]
    , command = cmd "mkdir" [ BUILD_DIR ++ p]
    , prereqs = [] : List B.Item
    }
  in
    [ d ""
    , d "posts"
    ]

let resources =
  let cp = λ(p : Text) → B.generated
    { results = [ BUILD_DIR ++ p ]
    , command = cmd "cp" [ p, BUILD_DIR ++ p ]
    , prereqs = [ B.source p ]
    }
  in List/map Text B.Item cp
    [ "FaxNouveau-Regular.ttf"
    , "graph.gif"
    , "quine.go"
    , "style.css"
    ]

let all = B.generated
  { results = [] : List Text
  , command = cmd "echo" [ "done" ]
  , prereqs = buildDirs # blogPosts # mainPages # resources
  }

in { default = B.build all }
