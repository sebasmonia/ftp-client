;;;; ftp-client.lisp

(in-package #:ftp-client)

(defun list-files ()
  (ftp:with-ftp-connection (conn :hostname "ftp.dlptest.com"
                             ;; :port port
                             :username "dlpuser@dlptest.com"
                                 :password "eUj8GeW55SvYaswqUyDSm5v6N")
    (ftp:send-nlst-command conn t)))

(defvar *user* nil "Username to login to the FTP server.")
(defvar *password* nil "Password to login to the FTP server.")
(defvar *address* nil "The FTP server's address.")
(defvar *files-list* nil "A reference to the listbox with the list of files.")
(defvar *buttons-to-toggle* nil "Reference to the buttons to disable while running lengthy operations.")

(defun disable-buttons ()
  (loop for button in *buttons-to-toggle*
        do (configure button :state :disabled)))

(defun enable-buttons ()
  (loop for button in *buttons-to-toggle*
        do (configure button :state :active)))

(defun start-ui ()
  (setf *buttons-to-toggle* nil) ;; I only need this to handle the constant reloading in the REPL
  (with-nodgui (:title "FTP Client")
    (let* ((address-entry (make-instance 'entry
                                         :text "ftp.dlptest.com"))
           (address-label (make-instance 'label
                                         :text "FTP address:"))
           (user-entry (make-instance 'entry
                                      :text "dlpuser"))
           (user-label (make-instance 'label
                                      :text "Username:"))
           ;; Should be a password-entry but, for ease of testing:
           (password-entry (make-instance 'entry
                                          :text "rNrKYTX9g7z3RgJRmxWuGHbeu"))
           (password-label (make-instance 'label
                                          :text "Password:"))
           (files-label (make-instance 'label
                                       :text "Files:"))
           (connect-button (make-instance 'button
                                          :text    "Connect to server"
                                          :command (lambda ()
                                                     (disable-buttons)
                                                     (setf *user* (text user-entry))
                                                     (setf *password* (text password-entry))
                                                     (setf *address* (text address-entry))
                                                     (connect-to-server))))
           (upload-button (make-instance 'button
                                         :text "Upload file"
                                         :state :disabled
                                         :command #'upload-file))
           (download-button (make-instance 'button
                                           :text "Download selected file"
                                           :state :disabled
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
      (grid upload-button 6 0 :padx 5 :pady 5)
      (grid download-button 6 1 :padx 5 :pady 5)
      (grid-columnconfigure *tk* :all :weight 1)
      (grid-rowconfigure    *tk* :all :weight 1)
      (push connect-button *buttons-to-toggle*)
      (push download-button *buttons-to-toggle*)
      (push upload-button *buttons-to-toggle*))))

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
  (finish-output)
  (enable-buttons))

(defun download-selected-file ()
  (disable-buttons)
  (format t "Listbox selection: ~a ~%" (car (listbox-get-selection-value *files-list*)))
  (finish-output)
  (let* ((remote-file (car (listbox-get-selection-value *files-list*))))
    (if remote-file
        (progn
          (let ((local-file (select-local-file remote-file)))
            (format t "Downloading remote file ~a to local file ~a ~%" remote-file local-file)
            (ftp:with-ftp-connection (conn :hostname *address*
                                           :username *user*
                                           :password *password*)
              (ftp:retrieve-file conn remote-file local-file)
              (message-box (format nil "File downloaded to ~a" local-file) "Downloaded!" :ok "info"))))
        (message-box (format nil "No file selected") "Error" :ok "error")))
  (enable-buttons))

(defun select-local-file (remote-file)
  (let ((directory (choose-directory :title "Download directory" :mustexist t)))
    (uiop:native-namestring (concatenate 'string
                                         directory
                                         "/"
                                         remote-file))))

(defun upload-file ()
  (disable-buttons)
  (let* ((file-to-upload (get-open-file :multiple nil :title "File upload"))
         (remote-name (file-namestring file-to-upload)))
    (ftp:with-ftp-connection (conn :hostname *address*
                                   :username *user*
                                   :password *password*)
      (ftp:store-file conn file-to-upload remote-name))
    (message-box (format nil "File \"~a\" uploaded!" remote-name) "Uploaded!" :ok "info"))
  (enable-buttons))
