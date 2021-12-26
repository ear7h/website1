let C = ./common.dhall
let ahrefL = C.ahrefL
let mkDoc = C.mkDoc
let H = C.H
let Prelude = C.Prelude
let List/map = Prelude.List.map
let XML = C.XML
let Post = C.Post

let mkPostLink = \(p : C.Post) ->
  let humanTitle = Text/replace "-" " " p.linkTitle
  let link = "posts/${p.date}-${p.linkTitle}.html"
  in H.li H.noattr [ ahrefL link "${p.date} ${humanTitle}" ]

let F = C.PostFormat
let list =
  [
    { date = "2021-08-17"
    , linkTitle = "gsoc-final"
    , format = F.md
    }
  ,
    { date = "2021-06-07"
    , linkTitle = "slack-vs-discord"
    , format = F.html
    }
  ,
    { date = "2021-06-07"
    , linkTitle = "algebra"
    , format = F.html
    }
  ,
    { date = "2021-06-02"
    , linkTitle = "hello-world"
    , format = F.html
    }
  ]

let page = \(postList : List Post) -> mkDoc "~julio"
	[ H.h1 H.noattr [ H.text "posts" ]
	, H.ul H.noattr (List/map Post XML mkPostLink postList)
	, H.p H.noattr [ H.text "note: the website is currently a work in progress, links may break in the future" ]
	]

in { page = page list, list }

