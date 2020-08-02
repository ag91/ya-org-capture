;;; ya-org-capture.el --- Integrate YASnippet and Yankpad in your Org Capture workflow.

;; Copyright (C) 2020 Andrea Giugliano

;; Author: Andrea Giugliano <agiugliano@live.it>
;; Version: 0.1.1
;; Package-Version: 20200802.000
;; Keywords: org-mode org-capture yasnippet yankpad

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

;; Integrate YASnippet and Yankpad in your Org Capture workflow.
;;
;; You may want to capture templates for your org-mode notes using the
;; features of the yasnippet and yankpad marvellous template engines.
;; If you load this mode you can do this simply by adding the
;; following lines to your init:
;; <some lines>
;;
;; And defining your org-capture template like this:
;; <some line>
;;
;; See documentation on https://github.com/ag91/easy-org-ensime.el

;;; Code:

(defgroup ya-org-capture nil
  "Options specific to ya-org-capture."
  :tag "ya-org-capture"
  :group 'ya-org-capture)

(defcustom ya-org-capture/ya-prefix "YA-ORG-CAPTURE-PREFIX-- "
  "Prefix used to tag."
  :group 'ya-org-capture
  :type 'string)

(defcustom ya-org-capture/expand-snippet-functions (list 'yankpad-expand 'yas-expand)
  "Functions used to expand the snippet at point. Order is
  important: if the functions are able to expand a snippet with
  the same key, the first function of the list takes precedence
  over the second."
  :group 'ya-org-capture
  :type 'list)

(defun ya-org-capture/or-else (&rest fs)
  "Compose partial functions FS until one of them produces a result or there are no more FS available."
  `(lambda (i)
     (reduce
      (lambda (acc f) (or acc (funcall f i)))
      ',fs
      :initial-value nil)))

(defun ya-org-capture/org-capture-fill-template ()
  "Post-process `org-mode' snippet to expand `org-capture' syntax. This only works for YASnippet."
  (let ((template (buffer-substring-no-properties yas-snippet-beg yas-snippet-end)))
    (kill-region yas-snippet-beg yas-snippet-end)
    (insert (org-capture-fill-template template))))

(defun ya-org-capture/snippet-expand ()
  "Try to expand snippet at point with `yankdpad-expand' and then with `yas-expand'."
  (interactive)
  (funcall (apply 'ya-org-capture/or-else ya-org-capture/expand-snippet-functions) nil))

(defun ya-org-capture/support-org-syntax-for-yasnippets ()
  "Allow `org-capture' to expand its syntax for YASnippets."
  (add-hook 'yas-after-exit-snippet-hook 'ya-org-capture/org-capture-fill-template nil t))

(defun ya-org-capture/expand-snippets ()
  "Expand `ya-org-capture/ya-prefix'."
  (when (search-forward ya-org-capture/ya-prefix nil t)
    (replace-match "")
    (ya-org-capture/support-org-syntax-for-yasnippets)
    (end-of-line)
    (ya-org-capture/snippet-expand)))

;;;###autoload
(defun ya-org-capture/make-snippet (snippet-name &optional yp-category)
  "Concatenate prefix to SNIPPET-NAME for substitution in `org-capture' flow.
Optionally set `yankpad-category' to YP-CATEGORY."
  (if yp-category (yankpad-set-local-category yp-category))
  (concatenate 'string ya-org-capture/ya-prefix snippet-name "\n"))

(defun ya-org-capture/setup ()
  "Setup integration between org-capture and yasnippet/yankpad."
  (interactive)
  (add-hook 'org-capture-mode-hook 'ya-org-capture/expand-snippets))


(defun ya-org-capture/teardown ()
  "Teardown integration between org-capture and yasnippet/yankpad."
  (interactive)
  (remove-hook 'org-capture-mode-hook 'ya-org-capture/expand-snippets))

(provide 'ya-org-capture)
;;; ya-org-capture ends here

;; Local Variables:
;; time-stamp-pattern: "10/Version:\\\\?[ \t]+1.%02y%02m%02d\\\\?\n"
;; End:
