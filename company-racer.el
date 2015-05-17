;;; company-racer.el --- Company integration for racer -*- lexical-binding: t -*-

;; Copyright (C) 2015 Mario Rodas <marsam@users.noreply.github.com>

;; Author: Mario Rodas <marsam@users.noreply.github.com>
;; URL: https://github.com/emacs-pe/company-racer
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24") (cl-lib "0.5") (company "0.8.0") (concurrent "0.3.1") (rust-mode "0.2.0"))

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
;; [![Travis build status](https://travis-ci.org/emacs-pe/company-racer.svg?branch=master)](https://travis-ci.org/emacs-pe/company-racer)

;; A company backend for [racer][].
;;
;; Setup:
;;
;; Install and configure [racer][]. And add to your `init.el':
;;
;;     (require 'company-racer)
;;
;;     (with-eval-after-load 'company
;;       (add-to-list 'company-backends 'company-racer))
;;
;; Check https://github.com/company-mode/company-mode for details.
;;
;; Troubleshoting:
;;
;; + [racer][] requires to set the environment variable with
;;   `RUST_SRC_PATH' and needs to be an absolute path:
;;
;;       (unless (getenv "RUST_SRC_PATH")
;;         (setenv "RUST_SRC_PATH" (expand-file-name "~/path/to/rust/src")))

;; TODO:
;;
;; + [ ] Add support for find-definition (maybe not in this package.)
;;
;; [racer]: https://github.com/phildawes/racer
;; [rust-lang]: http://www.rust-lang.org/

;;; Code:
(eval-when-compile (require 'cl-lib))

(require 'company)
(require 'thingatpt)
(require 'concurrent)
(require 'rust-mode)

(defgroup company-racer nil
  "Company integration for rust-mode"
  :group 'company)

(defcustom company-racer-executable "racer"
  "Path to the racer binary."
  :type 'file
  :group 'company-racer)

(defcustom company-racer-rust-src (or (getenv "RUST_SRC_PATH")
                                      "/usr/local/src/rust/src")
  "Path to rust lang sources, needs to be an absolute path."
  :type 'directory
  :group 'company-racer)

(defcustom company-racer-skip-comment-completion t
  "Skip completion prompt when the point is at a comment."
  :type 'boolean
  :group 'company-racer)

(defcustom company-racer-skip-string-completion t
  "Skip completion prompt when the point is at a string."
  :type 'boolean
  :group 'company-racer)

;; TODO: is there a better way to do this?
(defconst company-racer-temp-file (make-temp-file "company-racer"))

(defvar company-racer-syntax-table
  (let ((table (make-syntax-table rust-mode-syntax-table)))
    (modify-syntax-entry ?: "_" table)
    table))

(defun company-racer-namespace-p (string)
  "Check if STRING match to a rust namespace."
  (string-match-p ":+" string))

(defun company-racer-prefix ()
  "Get a prefix from current position."
  (ignore-errors
    (with-syntax-table company-racer-syntax-table
      (and (eq major-mode 'rust-mode)
           (let ((face (get-text-property (point) 'face))
                 (bounds (or (bounds-of-thing-at-point 'symbol)
                             (and (eq (char-before) ?.)
                                  (cons (1- (point)) (point)))))
                 (thing 'stop))
             (and bounds
                  (if (and (eq face 'font-lock-comment-face)
                           company-racer-skip-comment-completion)
                      nil t)
                  (if (and (eq face 'font-lock-string-face)
                           company-racer-skip-string-completion)
                      nil t)
                  (setq thing (buffer-substring-no-properties (car bounds)
                                                              (cdr bounds))))
             thing)))))

;; TODO: use "prefix" to handle fully qualified names
(defun company-racer-complete-at-point (prefix)
  "Call racer complete for PREFIX, return a deferred object."
  (if (company-racer-namespace-p prefix)
      (deferred:process company-racer-executable "complete" prefix)
    (let ((line         (number-to-string (count-lines (point-min) (min (1+ (point)) (point-max)))))
          (column       (number-to-string (- (point) (line-beginning-position))))
          (source-path  company-racer-temp-file))
      (write-region nil nil company-racer-temp-file nil 0)
      (deferred:process company-racer-executable "complete" line column source-path))))

;; TODO: Use the rest of information
(defun company-racer-parse-candidate (line)
  "Return a completion candidate from a racer output LINE."
  (when (string-match "^MATCH \\([^,]+\\),\\([^,]+\\),\\([^,]+\\),\\([^,]+\\),\\([^,]+\\),\\(.+\\)$" line)
    (match-string 1 line)))

(defun company-racer-candidates (prefix callback)
  "Return candidates for PREFIX with CALLBACK."
  (deferred:nextc
    (company-racer-complete-at-point prefix)
    (lambda (output)
      (let ((candidates (cl-loop for line in (split-string output "\n")
                                 for candidate = (company-racer-parse-candidate line)
                                 unless (null candidate)
                                 collect (if (company-racer-namespace-p prefix)
                                             (concat prefix candidate)
                                           candidate))))
        (and candidates
             (funcall callback candidates))))))

;;;###autoload
(defun company-racer (command &optional arg &rest ignored)
  "`company-mode' completion back-end for racer."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-racer))
    (prefix (company-racer-prefix))
    (candidates (cons :async
                      (lambda (cb) (company-racer-candidates arg cb))))
    (meta nil)
    (doc-buffer nil)
    (duplicates t)
    (location nil)))

(provide 'company-racer)

;;; company-racer.el ends here
