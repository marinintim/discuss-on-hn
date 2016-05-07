(in-package :discuss-on-hn)

(defvar *server* (make-instance 'hunchentoot:easy-acceptor :port 4242))

(defvar main-page-html nil)
(setf main-page-html "
<style>body {padding:2em 0 2em 3em; max-width:40em;font:16pt/1.5 monospace;} h2 {margin-left:-1em;text-transform: uppercase;}</style>
<title>Discuss on HN</title>
<h1>Discuss on HN</h1>
<h2>Summary</h2>
<p>Button “Discuss on HN” as a Service -- gives you a link from page to its hn discussion.
 </p>
<h2>Usage</h2>
 <p>Link to <a href=\"https://discuss-on-hn/go\">//discuss-on-hn.xyz/go?u=your-page-url</a>. If you don't
pass <code>u</code> parameter, DoHN will try to use <code>Referer</code> header, but that's a bit unreliable.</p>
<h2>Author</h2>
<p>Built by <a href=\"http://marinin.xyz\">Marinin Tim</a>, source code is available <a href=\"https://github.com/marinintim/discuss-on-hn\">at Github</a></p>

")

(define-easy-handler (try-to-link :uri "/go") (u)
  (let ((url (or u (hunchentoot:referer))))
    (if url
        (multiple-value-bind (hn-url matchp) (get-hn-url url)
          (if matchp
              (hunchentoot:redirect hn-url)
            (progn
              (setf (hunchentoot:content-type*) "text/html")
              (format nil  "
<style>body {padding:2em 0 2em 3em; max-width:40em;font:16pt/1.5 monospace;} h2 {margin-left:-1em;text-transform: uppercase;}</style>
<title>No discussion -- Discuss on HN</title>
<h1>Sorry, I don't know</h1>
<p>DoHN doesn't know about discussion of ~a,
maybe you want to <a href=\"https://news.ycombinator.com/submitlink?u=~a\">to create one</a>?
</p>" (ppcre:regex-replace-all "<" url "&lt;") (ppcre:regex-replace-all "\"" url "\"")))))
      (progn
        (setf (hunchentoot:content-type*) "text/html")
        "
<style>body {padding:2em 0 2em 3em; max-width:40em;font:16pt/1.5 monospace;} h2 {margin-left:-1em;text-transform: uppercase;}</style>
<title>No suitable URL -- Discuss on HN</title>
<h1>Err, there is no suitable URL</h1>
<p>There was no <code>u</code> parameter and neither <code>Referer</code> header was set. I don't know
where to redirect you, try <a href=\"https://hn.algolia.com\">HN Algolia search</a>.
</p>
"))))

(define-easy-handler (h-index :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  (format nil main-page-html))

(hunchentoot:start *server*)
