;;;; ftp-client.lisp

(in-package #:ftp-client)

(defun list-files ()
  (ftp:with-ftp-connection (conn :hostname "ftp.dlptest.com"
                             ;; :port port
                             :username "dlpuser@dlptest.com"
                                 :password "eUj8GeW55SvYaswqUyDSm5v6N")
    (ftp:send-nlst-command conn t)))

(defvar *user* nil)
(defvar *password* nil)
(defvar *address* nil)
(defvar *files-list* nil)

(defun start-ui ()
  (with-nodgui (:title "FTP Client")
    (let* ((address-entry (make-instance 'entry
                                         :text "ftp.dlptest.com"))
           (address-label (make-instance 'label
                                         :text "FTP address:"))
           (user-entry (make-instance 'entry
                                      :text "dlpuser@dlptest.com"))
           (user-label (make-instance 'label
                                      :text "Username:"))
           (password-entry (make-instance 'entry
                                          :text "eUj8GeW55SvYaswqUyDSm5v6N"))
           (password-label (make-instance 'label
                                          :text "Password:"))
           (files-label (make-instance 'label
                                       :text "Files:"))
           (files-list (make-instance 'listbox))
           (connect-button (make-instance 'button
                                          :text    "Connect to server"
                                          :command (lambda ()
                                                     (setf *user* (text user-entry))
                                                     (setf *password* (text password-entry))
                                                     (setf *address* (text address-entry))
                                                     (connect-to-server))))
           )
      (setf *files-list* files-list)
      (grid address-label 0 0 :padx 5 :pady 5)
      (grid address-entry 0 1 :padx 5 :pady 5)
      (grid user-label 1 0 :padx 5 :pady 5)
      (grid user-entry 1 1 :padx 5 :pady 5)
      (grid password-label 2 0 :padx 5 :pady 5)
      (grid password-entry 2 1 :padx 5 :pady 5)
      (grid connect-button 3 1 :padx 5 :pady 5)
      (grid files-label 4 0 :padx 5 :sticky :w)
      (grid files-list 5 0 :padx 5 :pady 5 :columnspan 3 :sticky :we)
      (grid-columnconfigure *tk* :all :weight 1)
      (grid-rowconfigure    *tk* :all :weight 1)
)))

(defun connect-to-server ()
  (ftp:with-ftp-connection (conn :hostname *address*
                                 :username *user*
                                 :password *password*)
    (listbox-clear *files-list*)
    (format t "Cleared!~%")
    ;; If I use #\newline, then it splits on \n only and leaves all \r
    (let ((files (uiop:split-string (ftp:send-nlst-command conn nil)
                                    :separator '(#\return #\linefeed))))
      (mapcar (lambda (filename)
                (unless (or (string= filename "")
                            (string= filename ".")
                            (string= filename ".."))
                  (listbox-append *files-list* filename)))
              files)))
  (format t "Done!~%")
  (finish-output))

;; (nodgui:with-nodgui () (nodgui:message-box (format nil "meh") "info" :ok "info"))
