let C = ./common.dhall
let ahrefL = C.ahrefL
let mkDoc = C.mkDoc
let H = C.H
let Prelude = C.Prelude
let List/map = Prelude.List.map
let XML = C.XML
let Text/lowerASCII = Prelude.Text.lowerASCII
let Post = C.Post

let postList = Prelude.List.reverse Post
	[ ./posts/2021-06-02-hello-world.dhall
	, ./posts/2021-06-07-algebra.dhall
	, ./posts/2021-06-07-slack-vs-discord.dhall
	, ./posts/2021-08-17-gsoc-final.dhall
	] : List Post

let mkPostLink = \(p : Post) ->
  let joinedTitle = Text/replace "." ""
	(Text/replace " " "-" (Text/lowerASCII p.title))
  let link = "posts/${p.date}-${joinedTitle}.html"
  in H.li H.noattr [ ahrefL link "${p.date} ${p.title}" ]


let page = mkDoc "~julio"
	[ H.h1 H.noattr [ H.text "posts" ]
	, H.ul H.noattr (List/map Post XML mkPostLink postList)
	]


in page
