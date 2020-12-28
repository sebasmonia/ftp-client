;;;; ftp-client.lisp

(in-package #:ftp-client)

(defun list-files ()
  (ftp:with-ftp-connection (conn :hostname "ftp.dlptest.com"
                             ;; :port port
                             :username "dlpuser@dlptest.com"
                                 :password "eUj8GeW55SvYaswqUyDSm5v6N")
    (ftp:send-nlst-command conn t)))


;; I know from tkinter that there's a way to setup a variable that is updated
;; with the content of the entry widgets (StringVar). Haven't figured out how
;; to do that with nodgui.
(defvar *user* nil "Username to login to the FTP server.")
(defvar *password* nil "Password to login to the FTP server.")
(defvar *address* nil "The FTP server's address.")
(defvar *files-list* nil "A reference to the listbox with the list of files.")

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
           ;; Should be a password-entry but, for ease of testing:
           (password-entry (make-instance 'entry
                                          :text "eUj8GeW55SvYaswqUyDSm5v6N"))
           (password-label (make-instance 'label
                                          :text "Password:"))
           (files-label (make-instance 'label
                                       :text "Files:"))
           (connect-button (make-instance 'button
                                          :text    "Connect to server"
                                          :command (lambda ()
                                                     (setf *user* (text user-entry))
                                                     (setf *password* (text password-entry))
                                                     (setf *address* (text address-entry))
                                                     (connect-to-server))))
           (download-button (make-instance 'button
                                           :text "Download selected file"
                                           :command #'download-selected-file)))
      (setf *files-list* (make-instance 'listbox))
      (grid address-label 0 0 :padx 5 :pady 5)
      (grid address-entry 0 1 :padx 5 :pady 5)
      (grid user-label 1 0 :padx 5 :pady 5)
      (grid user-entry 1 1 :padx 5 :pady 5)
      (grid password-label 2 0 :padx 5 :pady 5)
      (grid password-entry 2 1 :padx 5 :pady 5)
      (grid connect-button 3 1 :padx 5 :pady 5)
      (grid files-label 4 0 :padx 5 :sticky :w)
      (grid *files-list* 5 0 :padx 5 :pady 5 :columnspan 3 :sticky :we)
      (grid download-button 6 1 :padx 5 :pady 5)
      (grid-columnconfigure *tk* :all :weight 1)
      (grid-rowconfigure    *tk* :all :weight 1)
)))

(defun connect-to-server ()
  (ftp:with-ftp-connection (conn :hostname *address*
                                 :username *user*
                                 :password *password*)
    (listbox-delete *files-list*)
    (format t "Cleared file list. Getting new list...~%")
    ;; If I use #\newline, then it splits on \n only and leaves all \r
    (let ((files (uiop:split-string (ftp:send-nlst-command conn nil)
                                    :separator '(#\return #\linefeed))))
      (mapcar (lambda (filename)
                (unless (or (string= filename "")
                            (string= filename ".")
                            (string= filename ".."))
                  (listbox-append *files-list* filename)))
              files)))
  (format t "Updated file list.~%")
  (finish-output))

(defun download-selected-file ()
  (format t "Listbox selection: ~a ~%" (car (listbox-get-selection-value *files-list*)))
  (finish-output)
  (ftp:with-ftp-connection (conn :hostname *address*
                                 :username *user*
                                 :password *password*)
    (let* ((remote-file (car (listbox-get-selection-value *files-list*)))
           (local-file (uiop:native-namestring (concatenate 'string
                                                            "~/Dowloads/ftp-client/"
                                                            remote-file))))
      ;; TODO: figure out local path error
      (format t "Downloading remote file ~a to local file ~a ~%" remote-file local-file)
      (ftp:retrieve-file conn remote-file )
      (message-box (format nil "File downloaded to ~a." local-file) "Downloaded!" :ok "info"))))

;; (nodgui:with-nodgui () (nodgui:message-box (format nil "meh") "info" :ok "info"))
