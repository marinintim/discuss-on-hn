(in-package :discuss-on-hn)

(defun canonify-url (url)
  (cl-ppcre:regex-replace-all "^https?://|[/?]$"
                          (cl-ppcre:regex-replace-all "([&|?](utm_campaign|utm_source|utm_medium)=[a-zA-Z0-9]+)"
                                                  url "") ""))


; 'equal because I use strings as keys.
(defvar *urls* (make-hash-table :test 'equal))

(defun get-cached-hn-id (url)
  (gethash url *urls*))

(defun get-hn-url (url)
  (let ((id (get-hn-id url)))
    (when id
      (values  (concatenate 'string "https://news.ycombinator.com/item?id=" id) t))))

(defun get-hn-id (url)
  (let ((canonified-url (canonify-url url)))
    (multiple-value-bind
          (id cachedp)
        (get-cached-hn-id canonified-url)
      (if cachedp
          id
          (get-hn-id-from-api canonified-url)))))

(defun get-hn-id-from-api (url)
  (multiple-value-bind (id foundp) (get-algolia-id url)
    (when foundp
      (setf (gethash url *urls*) id))))

(defun get-algolia-id (url)
  (let* ((req (make-request-to-algolia url))
         (string (babel:octets-to-string req))
         (json (yason:parse string))
         (hits-count (gethash "nbHits" json))
         (hits (gethash "hits" json)))
    (if (< 0 hits-count)
        (gethash "objectID" (first hits))
        (values nil nil))))

(defun construct-algolia-url (search)
  (concatenate 'string "http://hn.algolia.com/api/v1/search?query=" search "&restrictSearchableAttributes=url&tags=story"))

(defun make-request-to-algolia (search)
  (drakma:http-request (construct-algolia-url search)))
