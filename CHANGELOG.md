## 0.1.0

* Merged lookup map for each language is now built once and cached (instead of being rebuilt on every `.translate` call).
* `Messenx.initialize` can be called multiple times without duplicating registered catalogs; catalogs registered after `load` are also propagated to `Intl`.
* `Messenx.load` supports full regional locales: regional files (e.g. `pt_AO`) are merged on top of base language files (`pt`).
* Added `translateWith({...})` for `{name}` placeholders and `plural(count, args: ...)` using `intl` CLDR plural rules (`_zero`, `_one`, `_two`, `_few`, `_many`, `_other`).
* Removed unused `flutter_web_plugins` dependency and upgraded to `flutter_lints` 6.

## 0.0.1

* Initial release: combine multiple translation files per language into a single lookup map with `overrides` support.
