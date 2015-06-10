;;; company-racer-test.el --- company-racer: Unit test suite -*- lexical-binding: t -*-

;; Copyright (C) 2015 Mario Rodas <marsam@users.noreply.github.com>

;; Author: Mario Rodas <marsam@users.noreply.github.com>
;; URL: https://github.com/emacs-pe/company-racer
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24") (cl-lib "0.5"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The unit test suite of company-racer

;;; Code:

(require 'company-racer)
(require 'undercover nil t)

(when (fboundp 'undercover)
  (undercover "company-racer.el"))

(defvar company-racer-candidates-cases
  '((nil "")
    (nil "PREFIX 0,0,")
    ("SpannedIdent" "MATCH SpannedIdent,2,9,src.rs,Type,type SpannedIdent = Spanned<Ident>")
    ("collections" "MATCH collections,1,0,/src/rust/src/libstd/collections/mod.rs,Module,/src/rust/src/libstd/collections/mod.rs")))

(ert-deftest company-racer-candidates-test ()
  (cl-loop for (candidate line) in company-racer-candidates-cases
           for result = (company-racer-parse-candidate line)
           do (should (equal candidate result))))

(provide 'company-racer-test)

;;; company-racer-test.el ends here
