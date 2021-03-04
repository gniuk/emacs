;;; ede/make.el --- General information about "make"  -*- lexical-binding: t -*-

;;; Copyright (C) 2009-2021 Free Software Foundation, Inc.

;; Author: Eric M. Ludlam <zappo@gnu.org>

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file needs to choose the version of "make" it wants to use.
;; Whenever an executable "gmake" is available, we prefer that since
;; it usually means GNU Make.  If it doesn't exist, use "make".
;;
;; Run tests on make --version to be sure it is GNU make so that
;; logical error messages can be provided.

;;; Code:

(defsubst ede--find-executable (exec)
  "Return an expanded file name for a program EXEC on the exec path."
  (declare (obsolete locate-file "28.1"))
  (locate-file exec exec-path))

(defvar ede-make-min-version "3.0"
  "Minimum version of GNU make required.")

(defcustom ede-make-command (cond ((executable-find "gmake")
				   "gmake")
				  (t "make")) ;; What to do?
  "The MAKE command to use for EDE when compiling.
The makefile generated by EDE for C files uses syntax that depends on GNU Make,
so this should be set to something that can execute GNU Make files."
  :group 'ede
  :type 'string)

;;;###autoload
(defun ede-make-check-version (&optional noerror)
  "Check the version of GNU Make installed.
The check passes if the MAKE version is no high enough, or if it
is not GNU make.
If NOERROR is non-nil, return t for success, nil for failure.
If NOERROR is nil, then throw an error on failure.  Return t otherwise."
  (interactive)
  (let ((b (get-buffer-create "*EDE Make Version*"))
	(cd default-directory)
	(rev nil)
        (ans nil))
    (with-current-buffer b
      ;; Setup, and execute make.
      (setq default-directory cd)
      (erase-buffer)
      (call-process ede-make-command nil b nil
		    "--version")
      ;; Check the buffer for the string
      (goto-char (point-min))
      (when (looking-at "GNU Make\\(?: version\\)? \\([0-9][^,[:space:]]+\\),?")
	(setq rev (match-string 1))
        (setq ans (not (version< rev ede-make-min-version))))

      ;; Answer reporting.
      (when (and (called-interactively-p 'interactive) ans)
	(message "GNU Make version %s.  Good enough for CEDET." rev))

      (when (and (not noerror) (not ans))
        (error "EDE requires GNU Make version %s or later (found %s).  Configure `ede-make-command' to fix"
               ede-make-min-version
               rev))
      ans)))

(provide 'ede/make)

;; Local variables:
;; generated-autoload-file: "loaddefs.el"
;; generated-autoload-load-name: "ede/make"
;; End:

;;; ede/make.el ends here
