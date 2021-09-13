let C = ./common.dhall
let Prelude = C.Prelude
let XML = C.XML
let H = C.H
let mkDoc = C.mkDoc
let ahref = C.ahref

let li = \(x : XML) -> H.li H.noattr [ x ]

in mkDoc "~julio/me.html"
	[ H.h1 H.noattr [ H.text "me" ]
	, H.ul H.noattr
		[ li ( H.text "My favorite color is orange" )
		, li ( H.text "I speak English and Portuguese" )
		, H.li H.noattr
			[ H.text ''
				In no particular order, my favorite programming
				languages are:''
			, H.ul H.noattr
				[ li (ahref
					"https://rust-lang.org/"
					"Rust")
				, li (ahref
					"https://haskell.org/"
					"Haskell")
				, li (ahref
					"https://golang.org/"
					"Go")
				, li (ahref
					"https://elm-lang.org/"
					"Elm")
				, li (ahref
					"https://dhall-lang.org/"
					"Dhall")
				, li (ahref
					"https://html.spec.whatwg.org/"
					"HTML")
				]
			]
		]
	, H.h2 H.noattr [ H.text "Contact" ]
	, H.ul H.noattr
		[ H.li H.noattr
			[ H.text "Email - julio (dot) grillo 98 (at) g mail (dot) com" ]
		, H.li H.noattr
			[ H.text "Matrix - "
			, ahref
				"https://matrix.to/#/@ear7h:matrix.org"
				"@ear7h:matrix.org"
			]
		, H.li H.noattr
			[ H.text "Github - "
			, ahref
				"https://github.com/ear7h"
				"@ear7h"
			]
		, H.li H.noattr
			[ H.text "Twitter - "
			, ahref
				"https://twitter.com/atear7h"
				"@atear7h"
			]
		]
	]
