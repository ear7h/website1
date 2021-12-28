let B = https://raw.githubusercontent.com/ear7h/buildsys3/main/prelude.dhall
let L = ./common.dhall

let Prelude =  https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/package.dhall
let List/map = Prelude.List.map

let BUILD_DIR = env:BUILD_DIR as Text ? "build/"
let CACHE_DIR = "cache/"
let DHALL = "dhall"

let cmd = λ(cmd : Text) → λ(args : List Text) → { cmd, args } : B.Command
let bash = λ(script : Text) → cmd "bash" [ "-c", script ]

let mkMain
  = λ(p : Text) → B.generated
    { results = [ BUILD_DIR ++ p ++ ".html" ]
    , command = cmd DHALL
      [ "text"
      , "--file", (p ++ ".dhall")
      , "--output", (BUILD_DIR ++ p ++ ".html")
      ]
    , prereqs =
      [ B.source "common.dhall"
      , B.source (p ++ ".dhall")
      ]
    }

let mainPages = List/map Text B.Item mkMain
  [ "index", "projects", "graphics", "me", "404" ]

let blogPosts =
  let html = λ(x : { date : Text, linkTitle : Text} ) →
    let p = x.date ++ "-" ++ x.linkTitle
    let out = BUILD_DIR ++ "posts/" ++ p ++ ".html"
    let input = "posts/" ++ p ++ ".html"
    in B.generated
      { results = [ out ]
      , command = bash
        ''
        ${DHALL} text --output ${out} <<EOF
          (./common.dhall).renderPost
            { date = "${x.date}"
            , title = "${x.linkTitle}"
            , content = (./${input} as Text)
            }
        EOF
        ''
      , prereqs =
        [ B.source "common.dhall"
        , B.source input
        ]
      }

  let md = λ(x : { date : Text, linkTitle : Text} ) →
    let p = x.date ++ "-" ++ x.linkTitle
    let out = BUILD_DIR ++ "posts/" ++ p ++ ".html"
    let contentHtml = CACHE_DIR ++ "posts/" ++ p ++ ".html"
    let input = "posts/" ++ p ++ ".md"
    in B.generated
      { results = [ out ]
      -- TODO: use created and modified date
      -- git log --format=%aD ${input} | tail
      -- git log --format=%aD ${input} | head
      , command = bash
        ''
        ${DHALL} text --output ${out} << EOF
          (./common.dhall).renderPost
            { date = "${x.date}"
            , title = "${x.linkTitle}"
            , content = (./${contentHtml} as Text)
            }
        EOF
        ''
      , prereqs =
        [ B.source "common.dhall"
        , B.generated
          { results = [ contentHtml ]
          , command = cmd "pandoc"
            [ "-f", "gfm"
            , "-t", "html"
            , "-o", contentHtml
            , input
            ]
          , prereqs = [ B.source input ]
          }
        ]
      }
  let f = λ(p : L.Post) →
    let arg = { date = p.date, linkTitle = p.linkTitle }
    in merge { html = html arg, md = md arg} p.format

  in List/map L.Post B.Item f (./posts.dhall).list

let posts = B.generated
  { results = [ BUILD_DIR ++ "posts.html" ]
  , command = bash
    ''
    ${DHALL} text --output ${BUILD_DIR ++ "posts.html"} <<EOF
      (./posts.dhall).page
    EOF
    ''
  , prereqs = blogPosts # [ B.source "posts.dhall" ]
  }

let extraDirs =
  let f = λ(prefix : Text) → λ(p : Text) → B.generated
    { results = [ prefix ++ p]
    , command = cmd "mkdir" [ prefix ++ p]
    , prereqs = [] : List B.Item
    }
  let build = f BUILD_DIR
  let cache = f CACHE_DIR
  in
    [ build ""
    , build "posts"
    , cache ""
    , cache "posts"
    ]

let mkdir = \(p : Text) -> 
  { item = B.generated
    { results = [ BUILD_DIR ++ p]
    , command = cmd "mkdir" [ BUILD_DIR ++ p]
    , prereqs = [] : List B.Item
    }
  , path = BUILD_DIR ++ p
  }

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

let uncategorized =
  let dir = mkdir "uncategorized/"
  let f = \(p : Text) -> 
    let input = "uncategorized/" ++ p
    let output = dir.path ++ p
    in B.generated
      { results = [ output ]
      , command = cmd "cp" [ input, output ]
      , prereqs = [ B.source input ]
      }
  in [ dir.item ] # (List/map Text B.Item f
    [ "cgs100a-zine.pdf"
    ])

let all = B.generated
  { results = [] : List Text
  , command = cmd "echo" [ "done" ]
  , prereqs = extraDirs # [ posts ] # mainPages # resources # uncategorized
  }

in
  { default = B.build all
  , server = B.build (B.generated
    { results = [] : List Text
    , command = bash
      ''
      python3 -m http.server -d ${BUILD_DIR}
      ''
    , prereqs = [ all ]
    })
  , clean = B.build (B.generated
    { results = [] : List Text
    , command = cmd "rm" [ "-rf", BUILD_DIR, CACHE_DIR ]
    , prereqs = [] : List B.Item
    })
  }

