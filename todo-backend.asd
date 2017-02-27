;;;; todo-backend.asd

(asdf:defsystem #:todo-backend
  :description "Describe todo-backend here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:house #:fact-base #:yason)
  :serial t
  :components ((:file "package")
               (:file "todo-backend")))
