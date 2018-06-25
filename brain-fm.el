;;; brain-fm.el --- Play music from brain.fm         -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Daniel Kraus

;; Author: Daniel Kraus <daniel@kraus.my>
;; Version: 0.1
;; Package-Requires: ((request "0.3.0") (emacs "24.4"))
;; Keywords: multimedia
;; URL: https://github.com/dakra/brain-fm

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

;; Play music from brain.fm (https://brain.fm/)
;; This library needs a playback function that can stream music from URLs.
;; If you have `mpv' installed and use `emms' you can require emms-player-mpv
;; to add `mpv' as an external player capable of streaming.
;; Otherwise set `brain-fm-play-url' to whatever player you prefer.
;;
;; You have to set `brain-fm-email' and `brain-fm-password' to your
;; brain-fm credentials either by setting those variables directly
;; or by adding a line like the following to your `.authinfo' / `.authinfo.gpg'
;; "machine brain.fm login brainfm@example.com password brainfm-pass"

;;; Code:

(eval-when-compile (require 'cl))
(require 'request)

(defgroup brain-fm nil
  "brain-fm"
  :prefix "brain-fm-"
  :group 'multimedia)

(defcustom brain-fm-play-url-function 'emms-play-url
  "Function to use for streaming brain.fm music."
  :type 'function)

(defcustom brain-fm-station-id 35
  "Default brain-fm station to play."
  :type 'integer
  :safe #'integerp)

(defcustom brain-fm-email nil
  "Your brain.fm email.
When nil read email from authinfo."
  :type 'string)

(defcustom brain-fm-password nil
  "Your brain.fm password.
When nil read password from authinfo."
  :type 'string)

;;;###autoload
(defun brain-fm-login ()
  "Login to brain.fm."
  (interactive)
  (unless (and brain-fm-email brain-fm-password)
    (let ((brain-fm-auth (auth-source-user-and-password "brain.fm")))
      (setq brain-fm-email (car brain-fm-auth))
      (setq brain-fm-password (cadr brain-fm-auth))))
  (if (and brain-fm-email brain-fm-password)
      (request
       "https://www1.brain.fm/login"
       :type "POST"
       :data (json-encode `(("email" . ,brain-fm-email)
                            ("password" . ,brain-fm-password)
                            ("type" . "LOGIN")))
       :headers '(("User-Agent" . "Emacs brain.fm Client")
                  ("Accept" . "application/json")
                  ("Content-Type" . "application/json;charset=utf-8"))
       :parser 'json-read
       :success (cl-function
                 (lambda (&key data &allow-other-keys)
                   (let* ((login-message (assoc-default 'message data))
                          (login-email (assoc-default 'email (assoc-default 'user data))))
                     (message "%s: %s" login-email login-message))))
       :error (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                             (message "Got error %S while logging in" error-thrown))))
    (error "You have to set brain.fm email and password")))

;;;###autoload
(defun brain-fm-play (&optional station-id)
  "Start playing brain.fm station STATION-ID."
  (interactive "P")
  (message "Fetching brain.fm token")
  (request
   "https://www1.brain.fm/tokens"
   :type "POST"
   :data (json-encode `(("stationId" . ,(or station-id brain-fm-station-id))))
   :headers '(("User-Agent" . "Emacs brain.fm Client")
              ("Accept" . "application/json")
              ("Content-Type" . "application/json;charset=utf-8"))
   :parser 'json-read
   :success (cl-function
             (lambda (&key data &allow-other-keys)
               (let* ((brain-fm-token (cdr (assoc 'token (aref (assoc-default 'songs data) 0))))
                      (brain-fm-url (format "https://stream.brain.fm/?tkn=%s" brain-fm-token)))
                 (message "Start playing brain.fm station %s" (or station-id brain-fm-station-id))
                 (funcall brain-fm-play-url-function brain-fm-url))))
   :error (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                         (message "Got error %S while getting token" error-thrown)))))
(provide 'brain-fm)
;;; brain-fm.el ends here
