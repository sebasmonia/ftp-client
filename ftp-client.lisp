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
    (let ((button-connect (make-instance 'button
                                         :text    "combo"
                                         :command #'connect-to-server))
          (text-address (make-instance 'entry)))
      (grid text-address 0 1  :sticky :nswe)
      (grid button-connect 1 1  :sticky :nswe))))

(defun connect-to-server ()
  (format *trace-output* "hehehe"))

;; (nodgui:with-nodgui () (nodgui:message-box (format nil "meh") "info" :ok "info"))

;; (uiop:getenv "HOME")
;; (uiop:run-program (list "firefox" "http:url")) - sync
;; (uiop:run-program "ls" :output *standard-output*) - print output
;; (uiop:run-program "ls" :output :string) - return as str
;; uiop:launch-program for async calls, see https://lispcookbook.github.io/cl-cookbook/os.html#asynchronously


;; set operations, over lists: intersection set-difference union set-exclusive-or
;; https://lispcookbook.github.io/cl-cookbook/data-structures.html#set
