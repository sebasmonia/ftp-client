;;;; ftp-client.asd

(asdf:defsystem #:ftp-client
  :description "FTP client written in Common Lisp. Just a learning exercise :)"
  :author "Sebastián Monía <seb.hoagie@outlook.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria
               #:uiop
               #:ftp
               #:nodgui)
  :components ((:file "package")
               (:file "ftp-client")))
