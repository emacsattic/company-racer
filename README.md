# company-racer - Company integration for racer

*Author:* Mario Rodas <marsam@users.noreply.github.com><br>
*Version:* 0.1<br>

[![Travis build status](https://travis-ci.org/emacs-pe/company-racer.svg?branch=master)](https://travis-ci.org/emacs-pe/company-racer)

A company backend for [racer][].

## Setup

Install and configure [racer][]. And add to your `init.el`:

        (require 'company-racer)

        (with-eval-after-load 'company
          (add-to-list 'company-backends 'company-racer))

Check https://github.com/company-mode/company-mode for details.

### Troubleshooting

+ [racer][] requires to set the environment variable with
  `RUST_SRC_PATH` and needs to be an absolute path:

          (unless (getenv "RUST_SRC_PATH")
            (setenv "RUST_SRC_PATH" (expand-file-name "~/path/to/rust/src")))

## TODO

+ [ ] Add support for find-definition (maybe not in this package.)

[racer]: https://github.com/phildawes/racer
[rust-lang]: http://www.rust-lang.org/


---
Converted from `company-racer.el` by [*el2markdown*](https://github.com/Lindydancer/el2markdown).
