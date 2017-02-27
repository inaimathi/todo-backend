;;;; todo-backend.lisp
(in-package #:todo-backend)

(defparameter *base* (fact-base:base! #P"todo.base"))

(defun hash (&rest k/v-pairs)
  (let ((h (make-hash-table)))
    (loop for (k v) on k/v-pairs by #'cddr
       do (setf (gethash k h) v))
    h))

(defmethod yason:encode ((k symbol) &optional stream)
  (yason:encode (string-downcase (symbol-name k)) stream))

(define-handler (/ :content-type "application/json" :method :GET) ()
  (with-output-to-string (*standard-output*)
    (yason:encode
     (or (fact-base:for-all
          (and (?id :todo t) (?id :title ?title) (?id :completed ?completed)
               (not (?id :deleted t)))
          :in *base*
          :collect (hash :id ?id :title ?title :completed ?completed
                         :url (format nil "/todo/~a" ?id)))
         (make-array 0)))))

(define-handler (/ :content-type "application/json" :method :POST) ((title :string))
  (fact-base:multi-insert! *base* `((:todo t) (:title ,title) (:completed nil)))
  "\"ok\"")

(define-handler (/ :content-type "application/json" :method :DELETE) ()
  (fact-base:for-all
   (and (?id :todo t) (not (?id :deleted t))) :in *base*
   :do (fact-base:insert! *base* (list ?id :deleted t)))
  "\"ok\"")

(define-handler (todo/-id=integer :content-type "application/json" :method :GET) ()
  (fact-base:for-all
   (and (?id :todo t) (not (?id :deleted t)) (?id :title ?title) (?id :completed ?completed))
   :in *base* :collect (hash :id ?id :title ?title :completed ?completed
                             :url (format nil "/todo/~a" ?id))))

(define-handler (todo/-id=integer :content-type "application/json" :method :PATCH) ((title string))
  (fact-base:change! *base* (list id :title title))
  "\"ok\"")

(define-handler (todo/-id=integer :content-type "application/json" :method :DELETE) ()
  (fact-base:insert! *base* (list id :deleted t))
  "\"ok\"")
