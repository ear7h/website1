# GSoC 2021 Work Product Submission

For Google Summer of Code 2021 I worked on the Dhall language, implementing
bidirectional conversion between Dhall and TOML. I was able to implement
the following features:
* conversion from Dhall to TOML, as a library function and CLI
* conversion from TOML to Dhall, as a library function and CLI
* documentation of packages

However, there are some missing features:
* Command line flags for the CLIs
* Date/Time support
* Schema inference in TOML to Dhall
* Alternative methods of handling unions.

For a list of commits, you can use this link:

https://github.com/search?q=committer-date%3A%3C2021-08-17+author%3Aear7h+org%3Adhall-lang&type=Commits

And to download a binary look for `dhall-toml` in this release page:

https://github.com/dhall-lang/dhall-haskell/releases/tag/1.40.0

## Dhall to TOML

I started with the Dhall to TOML conversion. The types in a, normalized, Dhall
abstract syntax tree (AST) are unambiguous and correct, thus can simply be
converted to TOML syntax (in contrast with TOML to Dhall, which I'll get to
later). The implementation revolves around the following function:

```hs
toToml :: TOML -> Key -> Expr Void Void -> Either CompileError TOML
```

This function takes a TOML object, a TOML key, a Dhall expression, and returns
either an error or a new TOML object. In imperative terms, this function
converts a Dhall expression to a TOML value and adds the the key-value pair to
a TOML object.

Primitive values, such as booleans and numbers are relatively simple to handle.
`tomland` has a function `Toml.TOML.insertKeyVal` to insert primitives into a
TOML object.

```hs
insertKeyVal :: Key -> Value a -> TOML -> TOML
```

Composite types like lists and objects are slightly more difficult. In
particular, they require that `toToml` is called recursively on all the child
nodes (list elements or object fields). This logic is a little complicated
in order to improve the output's readability. For example map keys are
compressed, so instead of:

```toml
[a] # bad
  [b]
    c = 1
```

we get:

```toml
[a.b] # good
  c = 1
```

Also, table arrays are created whenever possible, so instead of:

```toml
a = [1, 2, 3]
b = [{i = 1}, {i = 2}] # bad
```

we get:

```toml
a = [1, 2, 3]

[[b]] # good
i = 1

[[b]]
i = 2
```

## Toml to Dhall

As I mentioned above, TOML to Dhall conversion is a little more difficult,
since Dhall requires that all types are known in order to build an AST. One
approach is to naively infer types from the TOML AST. However, this approach
would fail in the relatively common case of a list of unions, which might be
represented as a heterogeneous list in TOML (ex. `[1, true]`). In order to
handle this, a non-trivial inference mechanism is needed.

Instead, we have the user provide a Dhall type to be used as a "schema" when
converting from TOML. This implemented with a function that looks *almost*
like:

```hs
toDhall :: Expr Src Void -> TOML -> Either CompileError (Expr Src Void)
```

This function takes a Dhall expression (the schema, types are also expressions
in Dhall) and a part of the TOML syntax tree to convert. It returns either an
error or the TOML AST converted into a Dhall AST.

The actual function is slightly different due to some quirks of the upstream
library, `tomland`. In particular it doesn't have a recursive structure,
instead it keeps lone pairs, tables, and table arrays stored separately. This
is difficult to work with so I created an intermediate object that can be
traversed easily:

```hs
data Object
    = Prim Toml.AnyValue.AnyValue
    | Array [Object]
    | Table (HashMap.HashMap Piece Object)
    | Invalid
```

So, `toDhall` is actually:

```hs
toDhall :: Expr Src Void -> Object -> Either CompileError (Expr Src Void)
```

And we have another function to convert a `TOML` to an `Object`:

```hs
tomlToObject :: TOML -> Object
```

`toDhall` is strucutured similarly to `toToml`: the primitive values are
trivial, while composite types require recursion. One major difference is
that bothe the `Expr` and the `Object` need to be compatible. So, pattern
matching happens on both arguments at the same time like:

```hs
toDhall exprType value = case (exprType, value) of
    (Core.Bool, Prim (AnyValue Value.Bool a)) -> ...
```

Otherwise, this function is simpler than `toDhall` with no special cases
for formatting since the Dhall already has pretty printing that can improve
a program's syntax without changing its semantics.

## Bugs and improvements

* Command line flags for the CLIs
* Date/Time support
* Schema inference in TOML to Dhall
* Alternative methods of handling unions.

I was not able to make a polished product that matched the other CLIs in the
`dhall-haskell` repository during the coding period. However, I do plan on
continuing to contribute to Dhall since I am genuinely interested in its
concepts. Here's a brief summary of future work that could be done:

* Command line flags for the CLIs
  * This is particularly important for usability, at least implementing a help
    message will provide a better experience to users who are less familiar
    with Dhall or Unix in general.
* Date/Time support
  * Dhall recently implemented native support for dates and time, particularly
    to support TOML.
* Schema inference in TOML to Dhall
  * This feature would improve the user experience allowing most arbitrary
    TOML files to be converted to Dhall without having write a schema.
* Alternative methods of handling unions.
  * In `dhall-to-toml` union values are converted to the underlying value
    or the name of the variant if it's bare (ex. given `<A : X | B>` it
    would be the `X` or `"B"`). Users may, instead, want a record with
    `type` and `value` fields which contain the alternative's name and value
    respectively.
  * In `toml-to-dhall` when a union is encountered in the schema, the first
    variant that can be successfully created from the TOML value is returned
    (if none are successful, an error is returned). We may want to support
    a converting from similar scheme as above where the TOML table has
    `type` and `value` fields which contain the alternative's name and value
    respectively.

There are also some limitations due to the upstream library, which have been
documented in the user facing documentation:
* heterogeneous arrays, which were added in the recent v1.0 release of the
  TOML spec (https://github.com/kowainik/tomland/issues/373)
* arrays of arrays of objects do not parse and are not representable in the
  TOML AST (https://github.com/kowainik/tomland/issues/385)

## Impact

TOML, stands for Tom's Obvious Minimal Language, and besides being obvious it
is also easily read by humans. However, at scale, nice syntax alone cannot solve
readability issues. Take for example this TOML file which configures the Tegola
vector tile server:

https://github.com/go-spatial/tegola-osm/blob/master/tegola-natural-earth.toml

At over 800 lines debugging and refactoring would be quite painful. Note that
many of the tables follow a pattern. To demonstrate the benefits of Dhall for
this task I created a Dhall file that generates a similar configuration for
Tegola in about 300 lines:

https://github.com/ear7h/dhall-natural-earth/blob/main/ne.dhall

Adding TOML support Dhall, not only expands the Dhall user base, but also
allows TOML-using services to be both beginner friendly at small scales and
maintainable at large scales.

## Conclusion

I'd like to thank my mentors Gabriella Gonzalez and Simon Jakobi for their
time and functional programming wisdom. Their welcoming environment has also
motivated me to contribute more to Dhall. I'm hoping to further
polish the `dhall-toml` package, adding some of the missing features mentioned
above. Thank you, again!


