;;; bardock.el --- dock a dock bar (e.g., a doc bar) to your source code
;; Copyright (C) 2012  Daniel Brockman <@dbrock>

(defcustom bardock-comment-prefix "┃"
  "Prefix inserted at the start of dock bar comments.")

(global-set-key (kbd "M-RET") 'bardock-indent)

(defun bardock-indent ()
  (interactive)
  (or (ignore-errors
        (save-excursion
          (bardock-go-to-top)
          (bardock-indent-to (current-column)))
        (bardock-go-to-comment-content))
      (bardock-insert-comment)))

(defun bardock-insert-comment ()
  (interactive)
  (comment-indent)
  (insert bardock-comment-prefix)
  (bardock-go-to-comment-content))

(defun bardock-go-to-comment-content ()
  (bardock-go-to-comment)
  (forward-char (length (concat comment-start bardock-comment-prefix)))
  (skip-chars-forward " "))

(defun bardock-go-to-top ()
  (ignore-errors
    (while (bardock-has-comment-p)
      (previous-line))
    ;; If we didn’t hit the top, back down one line.
    (forward-line))
  (bardock-go-to-comment))

(defun bardock-indent-to (column)
  (save-excursion
    (while (bardock-has-comment-p)
      (bardock-go-to-comment)
      (while (looking-back "  ")
        (delete-char -1))
      (dotimes (i (max 0 (- column (current-column))))
        (insert " "))
      (forward-line))))

(defun bardock-has-comment-p ()
  (ignore-errors
    (save-excursion (bardock-go-to-comment))))

(defun bardock-go-to-comment ()
  (beginning-of-line)
  (re-search-forward (bardock-comment-start) (line-end-position))
  (goto-char (match-beginning 0)))

(defun bardock-comment-start ()
  (or bardock-comment-start (bardock-default-comment-start)))

(defvar bardock-comment-start nil)
(make-variable-buffer-local 'bardock-comment-start)

(defun bardock-default-comment-start ()
  (concat (regexp-quote (bardock-remove-trailing-space comment-start))
          bardock-comment-prefix))

(defun bardock-remove-trailing-space (string)
  (replace-regexp-in-string " $" "" string))

(provide 'bardock)
