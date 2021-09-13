let C = ./common.dhall
let Prelude = C.Prelude
let XML = C.XML
let List/map = Prelude.List.map
let List/concat = Prelude.List.concat
let H = C.H
let mkDoc = C.mkDoc
let ahrefL = C.ahrefL
let ahref = C.ahref

let Project =
  { name : Text
  , link : Text
  , description : List XML
  }

let projectList =
	[
		{ name = "Tegola"
		, link = "https://github.com/go-spatial/tegola"
		, description =
			[ H.text ''
				This is the open source project I've worked most closely with.
				Some of my contributions have also been to the ''
			, ahref
				"https://github.com/go-spatial/geom"
				"underlying geometry package"
			, H.text ''
				. I like hacking on these software packages, which has lead to
				a couple interesting projects like a ''
			, ahref
				"https://github.com/apt4105/journal"
				"location journal"
			, H.text " and a "
			, ahrefL
				"graphics.html#glowglobe"
				"cool shader"
			, H.text "."
			]
		}
	]

let mkProject = \(p : Project) ->
	[ H.h2 H.noattr [ ahref p.link p.name ]
	, H.p H.noattr p.description
	]

let heading = H.h1 H.noattr [ H.text "projects" ]
let body = List/concat XML
	(List/map Project (List XML) mkProject projectList)

in mkDoc "~julio/projects.html" ( [ heading ] # body )

