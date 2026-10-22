# Description

Application to test [sanitize] **Ruby** gem features.

[![Build Status](https://travis-ci.org/jatap/test-ror-sanitize.png)](https://travis-ci.org/jatap/test-ror-sanitize)

### Version

[sanitize] `~> 2.0.6`

### Personal assessments

> Great whitelist-based HTML sanitizer, very customizable.

| Rating   | Documentation | Usability |
| :-------:|:-------------:|:---------:|
| 10       | 10            | 10        |

### Wishlist

- [ ] None.

### Notes

Custom transformers can solve any extra use case.

## Author
This source code is written by [Julio Antúnez Tarín].

[Julio Antúnez Tarín]: http://twitter.com/jatap
[ruby]: https://www.ruby-lang.org/
[sanitize]: https://github.com/rgrove/sanitize

## Documentation lookup

fastri is unmaintained (last release 2008) and depends on the old RI API
(`rdoc/ri/ri_paths`, `ri_cache`) that RDoc removed, so its `fri`, `qri`,
`fastri-server` and `ri-emacs` executables no longer load; no maintained fork
exists, so it is no longer a dependency. Use plain `ri` instead (`ri
String#upcase`, or `ri -i` for interactive lookup); Emacs users can point
yari.el at `ri`. `yard server` is available for browsing the API docs.
