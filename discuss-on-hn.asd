;;;; discuss-on-hn.asd

(asdf:defsystem #:discuss-on-hn
  :description "Describe discuss-on-hn here"
  :author "Marinin Tim <mt@marinin.xyz>"
  :license "MIT"
  :serial t
  :depends-on (#:hunchentoot
               #:cl-ppcre
               #:yason
               #:babel
               #:drakma)
  :components ((:file "package")
               (:file "url")
               (:file "web")
               (:file "discuss-on-hn")))
