;;; apheleia-use-package.el --- Use-package integration for apheleia  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  VojtechStep

;; Author: VojtechStep
;; Created: 9 Aug 2021
;; Homepage: https://github.com/VojtechStep/apheleia-use-package.el
;; Keywords: tools
;; Package-Requires: ((emacs "27") (apheleia "1.1.2") (use-package "2.4.1"))
;; Version: 0.1pre

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides integration of apheleia and use-package,
;; allowing one to configure a formatter with the :apheleia keyword

;; Possible variations:

;; - Specification of a new formatter
;;   (use-package nix-mode
;;     :apheleia
;;     (nixpkgs-fmt . ("nixpkgs-fmt" file))
;;     nix-mode other-nix-mode)

;; - Adding an existing formatter to other modes
;;   (use-package graphql-mode
;;     :apheleia
;;     (prettier)
;;     graphql-mode)

;; - Short version of the above
;;   (use-package graphql-mode
;;     :apheleia
;;     prettier
;;     graphql-mode)

;;; Code:

(eval-when-compile
  (require 'cl-lib))

(defvar use-package-keywords)
(defvar apheleia-mode-alist)
(defvar apheleia-formatters)
(declare-function use-package-concat "use-package-core")
(declare-function use-package-process-keywords "use-package-core")

(push :apheleia use-package-keywords)

(defun apheleia-use-package--normalize (_name _keyword args)
  "Normalizer for `:apheleia' in `use-package' forms.
The parameter ARGS is explained in the `use-package' documentation."
  (let ((format-spec (car args))
        (modes (cdr args)))
    (when (symbolp format-spec)
      (setq format-spec (list format-spec)))
    (cons format-spec modes)))

(defun apheleia-use-package--handle (name _keyword args rest state)
  "Handler for `:apheleia' in `use-package' forms.
The parameters NAME, ARGS, REST and STATE are exmplained in the `use-package' documentation."
  (let ((format-spec (car args))
        (modes (cdr args))
        eval-form)
    (when (cdr format-spec)
      (push `(push ',format-spec apheleia-formatters) eval-form))
    (dolist (mode modes)
      (push `(push '(,mode . ,(car format-spec)) apheleia-mode-alist) eval-form))
    (use-package-concat
     (use-package-process-keywords name rest state)
     `((eval-after-load 'apheleia-core ',(macroexp-progn (nreverse eval-form)))))))

(defalias 'use-package-normalize/:apheleia #'apheleia-use-package--normalize)
(defalias 'use-package-handler/:apheleia #'apheleia-use-package--handle)

(provide 'apheleia-use-package)
;;; apheleia-use-package.el ends here
