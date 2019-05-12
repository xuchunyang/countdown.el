;;; countdown.el --- 10, 9, 8, 7, 6...  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; Keywords: tools

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

;; countdown.el is inspired by countty (https://uninformativ.de/git/countty)

;;; Code:

(defconst countdown--font
  '((?0 #x3C #x42 #x42 #x00 #x42 #x42 #x3C)
    (?1 #x00 #x02 #x02 #x00 #x02 #x02 #x00)
    (?2 #x3C #x02 #x02 #x3C #x40 #x40 #x3C)
    (?3 #x3C #x02 #x02 #x3C #x02 #x02 #x3C)
    (?4 #x00 #x42 #x42 #x3C #x02 #x02 #x00)
    (?5 #x3C #x40 #x40 #x3C #x02 #x02 #x3C)
    (?6 #x3C #x40 #x40 #x3C #x42 #x42 #x3C)
    (?7 #x3C #x02 #x02 #x00 #x02 #x02 #x00)
    (?8 #x3C #x42 #x42 #x3C #x42 #x42 #x3C)
    (?9 #x3C #x42 #x42 #x3C #x02 #x02 #x3C)
    (?d #x00 #x02 #x02 #x3C #x42 #x42 #x3C)
    (?y #x00 #x00 #x42 #x3C #x02 #x02 #x0C)
    (?: #x00 #x00 #x18 #x00 #x18 #x00 #x00)
    (?  #x00 #x00 #x00 #x00 #x00 #x00 #x00)))

(defconst countdown--masks
  '(#b10000000 #b1000000 #b100000 #b10000 #b1000 #b100 #b10 #b1))

(defconst countdown--chars
  (mapcar
   (lambda (char)
     (cons char (countdown--render-char char)))
   (mapcar #'car countdown--font)))

(defun countdown--render-char (char)
  (mapcar
   (lambda (n)
     (mapconcat
      (lambda (mask)
        (if (zerop (logand n mask))
            " "
          (propertize " " 'face '(:background "white"))))
      countdown--masks ""))
   (alist-get char countdown--font)))

(defun countdown--render-string (string)
  (apply #'seq-mapn
         #'concat
         (mapcar
          (lambda (char)
            (alist-get char countdown--chars))
          string)))

(defun countdown--insert (string)
  (let ((lines (countdown--render-string string)))
    (dotimes (_ (floor (/ (- (window-height) 7) 2)))
      (insert ?\n))
    (let* ((prefix-length (floor (/ (- (window-width) (length (car lines))) 2)))
           (prefix (make-string prefix-length ?\s)))
      (dolist (line lines)
        (insert prefix line ?\n)))))

(defun countdown--format-seconds (seconds)
  (let* ((hours (/ seconds 3600))
         (seconds (- seconds (* 3600 hours)))
         (minutes (/ seconds 60))
         (seconds (- seconds (* 60 minutes))))
    (mapconcat
     (lambda (n)
       (format "%02d" n))
     (append (seq-drop-while #'zerop (list hours minutes))
             (list seconds))
     ":")))

;;;###autoload
(defun countdown (seconds)
  (interactive (list (read-number "Countdown Seconds: ")))
  (with-current-buffer (get-buffer-create "*Countdown*")
    (switch-to-buffer (current-buffer))
    (setq cursor-type nil)
    (buffer-disable-undo)
    (seq-doseq (i (if (> seconds 0)
                      (stream-range seconds 0 -1)
                    (stream-range 0)))
      (erase-buffer)
      (countdown--insert (countdown--format-seconds i))
      (sit-for 1))
    (message "Countdown done!")))

(provide 'countdown)
;;; countdown.el ends here
