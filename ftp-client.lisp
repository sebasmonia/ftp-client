;;;; ftp-client.lisp

(in-package #:ftp-client)

(defun list-files ()
  (ftp:with-ftp-connection (conn :hostname "ftp.dlptest.com"
                             ;; :port port
                             :username "dlpuser@dlptest.com"
                                 :password "eUj8GeW55SvYaswqUyDSm5v6N")
    (ftp:send-nlst-command conn t)))

(defun start-ui ()
  (with-nodgui ()
    (let* ((connect-button (make-instance 'button
                                          :text    "Connect to server"
                                          :command #'connect-to-server))
           (address-entry (make-instance 'entry))
           (address-label (make-instance 'label
                                         :text "FTP address:"))
           )
      (grid address-label 0 0)
      (grid address-entry 0 1)
      (grid connect-button 1 1)
      (grid-columnconfigure *tk* :all :weight 1)
      (grid-rowconfigure    *tk* :all :weight 1))))
      )))

(defun connect-to-server ()
  (format *trace-output* "Called connect-to-server"))

;; (nodgui:with-nodgui () (nodgui:message-box (format nil "meh") "info" :ok "info"))
