let Prelude = https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.2.0/Prelude/package.dhall
-- let XML = Prelude.XML.Type
let XML = https://raw.githubusercontent.com/ear7h/dhall-lang/issue-1224-raw-xml/Prelude/XML/package.dhall
let XML = XML.Type
let H = https://raw.githubusercontent.com/ear7h/dhall-html/main/html.dhall
let List/map = Prelude.List.map
let root = env:ROOT as Text

let ahref = \(link : Text) ->
	\(body : Text) -> H.a
		(toMap { href = link })
		[ H.text body ]

let ahrefL = \(link : Text) ->
	\(body : Text) -> H.a
		(toMap { href = "${root}/${link}" })
		[ H.text body ]

let navItem = \(page : Text) -> H.li H.noattr
	[ ahrefL "${page}.html" page ]

let navItems =
	[ H.li H.noattr [ ahrefL "index.html" "~julio" ] ]
	# (List/map Text XML navItem
		[ "projects"
		, "posts"
		, "graphics"
		, "me"
		])
let nav =
	[ H.nav H.noattr [ H.ul H.noattr navItems ]
	]
let mkDoc = \(title : Text) ->
	\(body : List XML) -> H.render (H.html H.noattr
		[ H.head H.noattr
			[ H.meta (toMap { charset = "utf-8" })
			, H.title H.noattr [ H.text title ]
			, H.link (toMap
				{ rel = "stylesheet"
				, type = "text/css"
				, href = "${root}/style.css"
				})
			]
		, H.body H.noattr (nav # body)
		])

let Post =
	{ date : Text
	, title : Text
	, content : List XML
	}

let renderPost = \(p : Post) -> mkDoc p.title
  ([ H.h1 H.noattr [ H.text p.title ]
  , H.p H.noattr [ H.text ("created: " ++ p.date) ]
  ] # p.content)

in
  { Prelude
  , XML
  , H
  , mkDoc
  , ahref
  , ahrefL

  , root

  , Post
  , renderPost
  }
