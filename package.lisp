;;;; package.lisp

(defpackage #:ftp-client
  (:nicknames :ftpc)
  (:use #:common-lisp #:nodgui)
  (:import-from :alexandria)
  (:import-from :uiop)
  ;; (:import-from :nodgui)
  (:import-from :ftp)
  (:export
   #:list-files
   #:start-ui))

(in-package #:ftp-client)
