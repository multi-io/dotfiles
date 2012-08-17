;; things XEmacs has, but GNU Emacs hasn't

(require 'cl)

(setq running-xemacs (string-match "XEmacs" emacs-version))

(unless (functionp 'gensym)
  (defvar gensym-counter 0 "internal counter for gensym")
  (defun gensym ()
    (setq gensym-counter (1+ gensym-counter))
    (make-symbol (concat "gensym" `(,gensym-counter)))))

(unless (functionp 'dolist)
  (defmacro dolist (varlist &rest body)  ;; structured lambda lists as in CL
    (let                                 ;; not supported by GNU Emacs' elisp
        ((var (car varlist))
         (list (cadr varlist))
         (ptr (gensym)))
      `(let
           ((,ptr ,list))
         (while (not (null ,ptr))
           (let ((,var (car ,ptr)))
             ,@body)
           (setq ,ptr (cdr ,ptr)))))))

(unless (functionp 'ignore-errors)
  (defmacro ignore-errors (&rest body)
    `(condition-case nil
         (progn ,@body)
       (error))))

;; helpers

(defmacro append-path-if-exists (path pathlist)
  `(when (and (file-exists-p ,path)
              (not (member ,path ,pathlist)))
     (setq ,pathlist (append
                      (list ,path)
                      ,pathlist))))

(defmacro initialize-lib (name load-paths &rest body)
  (let
      ((path (gensym)))
    `(progn
       (dolist (,path ,load-paths)
         (append-path-if-exists ,path load-path))

       (ignore-errors
         ,@body))))


;my own stuff overrides everything
(append-path-if-exists (expand-file-name "~/emacs-lisp")
                       load-path)

;load homebuilt Gnus on M-x gnus
(if running-xemacs
    (append-path-if-exists "/usr/local/lib/xemacs/site-packages/lisp/gnus"
                           load-path))

; show its documentation in info

;; set path as 2nd element of Info-directory-list, as the
;;  1st directory mentioned in Info-directory-list must
;;  contain the "dir" node
(when (and
       (file-exists-p "/usr/local/lib/xemacs/site-packages/info")
       (boundp 'Info-directory-list))
  (setf (cdr Info-directory-list)
        (cons "/usr/local/lib/xemacs/site-packages/info"
              (cdr Info-directory-list))))


(initialize-lib
 "nesl" '()

 (load-library "nesl")
 (load-library "nesl-mode")
 (setq inferior-nesl-program "/usr/local/nesl/neslrun.sh"))


(initialize-lib
 "pc-select" '()

 (require 'pc-select) ;;neat little mode for PC-like select/cut/copy/paste shortcuts
 (condition-case nil
     (pc-select-mode)
   (error (pc-selection-mode)))

 ;; (for GNU Emacs only) make "yank" paste the clipboard. middle-click
 ;; still doesn't paste the primary, as opposed to XEmacs, where it
 ;; does. So XEmacs is compliant to [1], GNU Emacs without the
 ;; following line isn't compliant to anything, GNU Emacs with the
 ;; following line is half-compliant to [1].
 ;;
 ;; [1] http://www.jwz.org/doc/x-cut-and-paste.html,
 ;;     http://freedesktop.org/wiki/Standards_2fClipboardsWiki
 (setq x-select-enable-clipboard t))

 

(setq scroll-step 1)    ;;no 'jump scrolling', pleaze
(setq scroll-conservatively 2)

(setq auto-mode-alist (append '(("\\.make\\'" . makefile-mode)
				("\\.sql\\'" . sql-mode)
				("\\.xml\\'" . xml-mode)
				("\\.wsdl\\'" . xml-mode)
				("\\.wsdd\\'" . xml-mode)
                                ("\\.rhtml\\'" . html-mode)
				("[/^]\\.gnus\\'" . emacs-lisp-mode))
			      auto-mode-alist))

(autoload 'cyclebuffer-forward "cycbuf2" "cycle forward" t)
(autoload 'cyclebuffer-backward "cycbuf2" "cycle backward" t)
;;(global-set-key "\M-n" 'cyclebuffer-forward)
;;(global-set-key "\M-p" 'cyclebuffer-backward)
(global-set-key [(alt n)] 'cyclebuffer-forward)
(global-set-key [(alt p)] 'cyclebuffer-backward)

(global-set-key [(f12)] 'call-last-kbd-macro)

(defun delete-char-down ()
  (delete-char 0)
  (next-line 1)
)

(global-set-key [(alt k)] 'delete-char-down)

(setq next-line-add-newlines nil)

;;(global-set-key [(alt n)] 'bury-buffer)
;;(global-set-key [(alt p)] 'select-previous-buffer) 

(global-set-key [(alt b)] 'buffer-menu)


(setq mark-ring-max 50)

(global-set-key [(meta n)] 'new-frame)
(global-set-key [(f6)] 'other-window)


;; avoid mysterious "iso-level3-shift not defined" error when pressing AltGr
;; see http://groups.google.com/groups?hl=en&lr=&threadm=bu3v5r%24g66%241%40knot.queensu.ca&rnum=4&prev=/groups%3Fas_q%3D%2522iso-level3-shift%2520not%2520defined%2522%26safe%3Dimages%26lr%3D%26hl%3Den
;; doesn't completely do away with the prob though:
;;   pressing AltGr still cancels the Isearch mode (use C-s ENTER <text> ENTER to work around that)
;; dunno why this (partially) works and whether or not it causes problems in other
;;  Emacsen/XEmacs versions/moon phases etc.
(define-key global-map [(iso-level3-shift)] #'ignore)
(define-key global-map [(dead-tilde)] #'ignore)


(if (string-match "XEmacs" emacs-version)
    (progn
      (setq font-lock-mode t)
      (setq font-lock-maximum-decoration t)
      (ignore-errors (font-lock-fontify-buffer))
      ;; Der letze Aufruf aktiviert anscheinend die Fontifikation auch fuer alle
      ;; zukuenftig geoeffneten Buffer. Komische Semantik... Dokumentation?
      )
  (global-font-lock-mode 1))
  

(setq initial-scratch-message (concat ";; -*- Lisp-Interaction -*-\n" initial-scratch-message))


;; "Edit with Emacs" (external editor extension in Chrome)
(initialize-lib
 "chrome-edit-server" '()
 (require 'edit-server)
 (edit-server-start))


;; gtags (Emacs-Interface zu global(1))
(initialize-lib
 "gtags" '()

 (load-library "gtags")
 ;; gtags-pop-stack so umdefinieren, dass der verlassene Buffer
 ;; nicht mehr geloescht wird
 (defun gtags-pop-stack ()
   "Move to previous point on the stack."
   (interactive)
   (let (context buffer)
     (if (and (not (equal gtags-current-buffer nil))
              (not (equal gtags-current-buffer (current-buffer))))
         (switch-to-buffer gtags-current-buffer)
       (setq context (gtags-pop-context))
       (if (not context)
           (message "The tags stack is empty.")
         (switch-to-buffer (nth 0 context))
         (setq gtags-current-buffer (current-buffer))
         (goto-char (nth 1 context)))))))

(ignore-errors (require 'filladapt))
        ;; more intelligent filling of comment paragraphs etc.
        ;; must be activated in each buffer using (turn-on-filladapt-mode)

(setq-default indent-tabs-mode nil)

(defun c-mode-setup ()
    (setq c-basic-offset 4)
    (setq indent-tabs-mode nil)
    (setq tab-width 4)
    (c-set-offset 'substatement-open 0)   ;;andere Einrueckungseinstellungen und sonstiges Syntaxzeugs ==> siehe C-h v c-offsets-alist
    (gtags-mode 1))  ;; gtags-(minor-)mode im C/C++/Java-Mode

(add-hook 'c-mode-common-hook 'c-mode-setup)


(defun cperl-mode-setup ()
    (setq cperl-indent-level 4)
    (setq cperl-continued-statement-offset 0)
    (setq indent-tabs-mode nil))

(add-hook 'cperl-mode-hook 'cperl-mode-setup)


(defun python-mode-setup ()
    (setq indent-tabs-mode nil)
    (setq py-smart-indentation nil))

(add-hook 'python-mode-hook 'python-mode-setup)

(initialize-lib
 "ruby" '()

 (load-library "inf-ruby")
 (add-hook 'ruby-mode-hook
           '(lambda ()
              (inf-ruby-keys)))

 (defun ruby-mode-setup ()
   (setq indent-tabs-mode nil)
   (turn-on-filladapt-mode))

 (add-hook 'ruby-mode-hook 'ruby-mode-setup)

 (load-library "rubydb3x")
 (require 'rubydb))


(initialize-lib
 "groovy" (list (expand-file-name "~/emacs-lisp"))

 ;; http://groovy.codehaus.org/Emacs+Plugin

 ;;; turn on syntax hilighting
 (global-font-lock-mode 1)

 ;;; use groovy-mode when file ends in .groovy or has #!/bin/groovy at start
 (autoload 'groovy-mode "groovy-mode" "Groovy editing mode." t)
 (add-to-list 'auto-mode-alist '("\.groovy$" . groovy-mode))
 (add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode)))

(initialize-lib
 "js2" '()

 (defun js2-mode-setup ()
   (setq js2-bounce-indent-p t)
   (setq js2-basic-offset 4))

 (add-hook 'js2-mode-hook 'js2-mode-setup))


(defun text-mode-setup ()
    (setq indent-tabs-mode nil)
    (auto-fill-mode 1))

(add-hook 'text-mode-hook 'text-mode-setup)


;; make scripts executable after saving
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)


;; automatic handling of DOSy CRLFs during load/save operations
;; shouldn't be necessary in a MULE-enabled (X)Emacs.
;; don't know what else this package can be used for
(ignore-errors (require 'crypt))


(defun turn-off-tabs-mode ()
    (setq indent-tabs-mode nil))

(add-hook 'sql-mode-hook 'turn-off-tabs-mode)
(add-hook 'emacs-lisp-mode-hook 'turn-off-tabs-mode)

;; increasing these values 100-fold to avoid certain errors when byte-compiling
(setq max-specpdl-size 100000)
(setq max-lisp-eval-depth 40000)

;; (pc-selection-mode)
;; (delete-key-deletes-forward)
(setq gdb-command-name "/home/olaf/bin/mygdb")
(global-set-key [(f5)] 'gdb-cont)
(global-set-key [(f9)] 'gdb-break)
(global-set-key [(f10)] 'gdb-next)
(global-set-key [(f11)] 'gdb-step)
;; (exec-to-string xterm)

(ignore-errors (paren-set-mode 'paren))
(ignore-errors (show-paren-mode))

;; Options Menu Settings
;; =====================
(cond
 ((and (string-match "XEmacs" emacs-version)
       (boundp 'emacs-major-version)
       (or (and
            (= emacs-major-version 19)
            (>= emacs-minor-version 14))
           (= emacs-major-version 20))
       (fboundp 'load-options-file))
  (load-options-file "/home/olaf/.xemacs-options")))
;; ============================
;; End of Options Menu Settings

(setq minibuffer-max-depth nil)

(autoload 'gnus-unplugged "gnus-agent" "Start Gnus unplugged." t nil)




;;; Druckunterstuetzung

(setq lpr-command "gtklp")
;(setq lpr-switches '("-Pbw717pap4"))

;;; obiges wird nur bei nicht-PS-Druck verwendet (z.B. von "print-buffer")
;;; Die Druck-Queues verstehen aber nur PS, deshalb funktioniert obiges nicht.
;;;
;;; pra/pra2 koennen nur Dateien verarbeiten, nicht stdin
;;; (TODO: entspr. umschreiben!)


;;; fuer PS-druck (z.B. ps-print-buffer)
(setq ps-lpr-command "gtklp")   ;; use lpr-command
;(setq ps-lpr-switches '("-Pbw717pap2"))




;;======speedbar=========

(initialize-lib
 "speedbar" '("/usr/local/src/speedbar")
 
 (autoload 'speedbar-frame-mode "speedbar" "Popup a speedbar frame" t)
 (autoload 'speedbar-get-focus "speedbar" "Jump to speedbar frame" t)

 (global-set-key [(f4)] 'speedbar-get-focus)

 ;; list RPM files
 (autoload 'rpm "sb-rpm" "Rpm package listing in speedbar.")
 ;; chapter listings
 (autoload 'Info-speedbar-buttons "sb-info" "Info specific speedbar button generator.")
 ;; folder listings
 (autoload 'rmail-speedbar-buttons "sb-rmail" "Rmail specific speedbar button generator.")
 ;; current stack display
 (autoload 'gud-speedbar-buttons "sb-gud" "GUD specific speedbar button generator."))


;;======semantic=========

(initialize-lib
 "semantic" '("/usr/local/src/semantic")

 (require 'semantic-c)		; for C code integration
 (require 'semantic-el)		; for Emacs Lisp code integration
 (require 'semantic-make)		; for Makefile integration
 (require 'semantic-imenu)		; if you use imenu or wich-function
 (add-hook 'speedbar-load-hook (lambda () (require 'semantic-sb)))
					; for speedbar integration  ;; TODO: wichtig: speedbar darf hier noch nicht geladen sein
 (autoload 'semantic-bnf-mode "semantic-bnf" "Mode for Bovine Normal Form." t)
 (add-to-list 'auto-mode-alist '("\\.bnf$" . semantic-bnf-mode))
					; for editing .bnf parser files.
 (autoload 'semantic-minor-mode "semantic-mode" "Mode managing semantic parsing." t)
					; for semantic-minor-mode
 )

;;======eieio=========

(initialize-lib
 "eieio" '("/usr/local/src/eieio"))


;;======elib=========
;;(load-path erweitert in /usr/local/share/emacs/site-lisp/default.el.
;; Stand so in der elib-Installationsanleitung) 


;;======url=========
(defun my-browse-url-x-www-browser (url &optional new-window)
  "Ask the x-www-browser to load URL.
Default to the URL around or before point.  The strings in variable
`browse-url-galeon-arguments' are also passed to Galeon.

When called interactively, if variable `browse-url-new-window-flag' is
non-nil, load the document in a new Galeon window, otherwise use a
random existing one.  A non-nil interactive prefix argument reverses
the effect of `browse-url-new-window-flag'.

When called non-interactively, optional second argument NEW-WINDOW is
used instead of `browse-url-new-window-flag'."
  (interactive (browse-url-interactive-arg "URL: "))
  ;; URL encode any `confusing' characters in the URL.  This needs to
  ;; include at least commas; presumably also close parens.
  (while (string-match "[,)]" url)
    (setq url (replace-match
	       (format "%%%x" (string-to-char (match-string 0 url))) t t url)))
  (let* ((process-environment (browse-url-process-environment))
         (process (apply 'start-process
			 (concat "x-www-browser " url) nil
			 "x-www-browser"
			 (append
			  nil
                          (if new-window '()
                           '())
                          (list url)))))
    (set-process-sentinel process
			  `(lambda (process change)
			     (my-browse-url-x-www-browser-sentinel process ,url)))))


(defun my-browse-url-x-www-browser-sentinel (process url)
  "Handle a change to the process communicating with x-www-browser."
  (or (eq (process-exit-status process) 0)
      (let* ((process-environment (browse-url-process-environment)))
	;; Galeon is not running - start it
	(message "Starting x-www-browser...")
	(apply 'start-process (concat "x-www-browser " url) nil
	       "x-www-browser"
               (append nil (list url))))))



(setq w3-configuration-directory (expand-file-name "~/w3")
      browse-url-new-window-flag t
      browse-url-browser-function 'my-browse-url-x-www-browser)



;;======JDE=========
;;nett, aber 10 Bugs/Stunde
;; z.B.: paren-highlighting wird kaputtet

;(setq load-path (append
;		 '("/usr/local/src/emacs-packages/jde/lisp")
;		 load-path))

;(require 'jde)


;; ======psgml-mode=========
;; manuell installierte Version in /usr/local/share/emacs/site-lisp/
;; in XEmacs-Distri enthaltene Version ist noch in /usr/lib/xemacs/xemacs-packages/lisp/psgml/
;; ==> /usr/local/share/emacs/site-lisp/ muss in load-path *vor* /usr/lib/xemacs/xemacs-packages/lisp/psgml/
;; stehen (ist im Moment der Fall)

(autoload 'sgml-mode "psgml" "Major mode to edit SGML files." t)
(autoload 'xml-mode "psgml" "Major mode to edit XML files." t)



(add-hook 'xml-mode-hook
          (lambda ()
            (setq sgml-indent-data t)))




;;;;======OO-Browser=========
;;
;;(setq load-path (append
;;		 '("/usr/local/share/emacs/site-lisp/oo-browser/"
;;		   "/usr/local/share/emacs/site-lisp/oo-browser/hypb/")
;;		 load-path))
;;(load "br-start")
;;(global-set-key "\C-c\C-o" 'oo-browser)

;;======AucTeX=========

(initialize-lib
 "AucTeX" '()
 (require 'tex-site))


;;======OPAL==========

(initialize-lib
 "OPAL" '()
 ;; include the following lines into your .emacs file
 ;; (where you may need to change /usr/ocs to point to
 ;; the actual installation place)
 ;; for customization uncomment and change variable settings

 (defun my-opal-hook()
   ;; (setq opal-alist-file nil) ; uncomment to not save import maps
   ;; (setq opal-diag-extended-flag nil) ; uncomment to not show extended help
   ;; (setq opal-use-frames nil) ; uncomment to inhibit usage of frames
   (setq indent-tabs-mode nil) ; uncomment to not expand TABs 
   ;; (setq auto-fill-mode nil) ; uncomment to not autobreak lines
   (opal-misc-indent-on) ; uncomment to switch on opal-indentation
   (opal-font-lock opal-font-lock-keywords-simple)  ; uncomment  
                                                      ; for fontlock-support

   (modify-syntax-entry ?/ "_" (standard-syntax-table))  ; "/" soll als Wort-Begrenzer erkannt werden
                                        ; (wird vom OPAL-Mode offenbar abgeschaltet)
   )

 (add-hook 'opal-mode-hook 'my-opal-hook)

; (setq opal-novice nil)   ;; uncomment to have all menus available
; (setq opal-pchecker t) ;; uncomment for proofchecker support (XEmacs only)
; (setq opal-diag-background "lightyellow") ;; change background of diagnostics
; (setq opal-diag-extended-flag t) ;; initial state for showing extended help
; (setq opal-toolbar-position 'right) ;; position of toolbar ('left or 'right)
                                      ;; XEmacs only
; (setq opal-import-fold nil) ;; if t, fold long ONLY imports to COMPLETELY

 (require 'opal-mode))



;;;======ilisp,CLtL2-Browser==========

;(initialize-lib
; "ilisp" '()
; (require 'ilisp)

; (setq *cltl2-local-file-pos* "/usr/share/doc/cltl/")
; (require 'ilisp-browse-cltl2 "browse-cltl2"))


;;;======SLIME==========

(initialize-lib
 "slime" '("/usr/local/src/slime")
 (setq inferior-lisp-program "clisp")
 ;(setq inferior-lisp-program "lisp")
 (require 'slime)
 (slime-setup))


;;;======Haskell==========

;(setq auto-mode-alist
;      (append auto-mode-alist
;              '(("\\.[hg]s$"  . haskell-mode)
;                ("\\.hi$"     . haskell-mode)
;                ("\\.l[hg]s$" . literate-haskell-mode))))

;(autoload 'haskell-mode "haskell-mode"
;  "Major mode for editing Haskell scripts." t)
;(autoload 'literate-haskell-mode "haskell-mode"
;  "Major mode for editing literate Haskell scripts." t)


;;   `haskell-font-lock', Graeme E Moss and Tommy Thorn
;;     Fontifies standard Haskell keywords, symbols, functions, etc.

;;   `haskell-decl-scan', Graeme E Moss
;;     Scans top-level declarations, and places them in a menu.

;;   `haskell-doc', Hans-Wolfgang Loidl
;;     Echoes types of functions or syntax of keywords when the cursor is idle.

;;   `haskell-indent', Guy Lapalme
;;     Intelligent semi-automatic indentation.

;;   `haskell-simple-indent', Graeme E Moss and Heribert Schuetz
;;     Simple indentation.

;;   `haskell-hugs', Guy Lapalme
;;     Interaction with Hugs interpreter.

;;; To turn any of the supported modules on for all buffers, add the
;;; appropriate line(s) to .emacs:
;;;


(defun haskell-mode-setup ()
  (turn-on-haskell-font-lock)
  (turn-on-haskell-decl-scan)
  (turn-on-haskell-doc-mode)
  (turn-on-haskell-indent)
;;  (turn-on-haskell-simple-indent)
;;  (add-hook 'haskell-mode-hook 'turn-on-haskell-hugs)
  (setq indent-tabs-mode nil)
  (setq delete-key-deletes-forward t)
  (turn-on-haskell-indent) ; remappt DEL auf backward-delete-char-untabify. Warum nur?
  (define-key haskell-mode-map [(delete)] 'backward-or-forward-delete-char)
             ;; these f*cking modes change everything..
  (setq tab-width 4)) ;; indeed

;; no highlighted parens in haskell-mode in spite of (eq paren-mode 'paren) :-(

(setq haskell-mode-hook nil) ;; get rid of all the super-funky Debilian(?) default settings

(add-hook 'haskell-mode-hook 'haskell-mode-setup) ;; and establish our own



;;;======OCaml==========

(initialize-lib
 "ocaml" '()
 (setq auto-mode-alist
       (cons '("\\.ml[iylp]?$" . caml-mode) auto-mode-alist))
 (autoload 'caml-mode "caml" "Major mode for editing Caml code." t)
 (autoload 'run-caml "inf-caml" "Run an inferior Caml process." t))




;;;
;;; Make sure the module files are also on the load-path.  Note that
;;; the two indentation modules are mutually exclusive: Use only one.
;;;
;;;
;;; Customisation:
;;;
;;; Set the value of `haskell-literate-default' to your preferred
;;; literate style: 'bird or 'latex, within .emacs as follows:
;;;
;(setq haskell-literate-default 'latex)


;;======BBDB=========
(initialize-lib
 "bbdb" '()

 (require 'bbdb)
 (setq bbdb-file "~/.bbdb")
 ;;(bbdb-initialize 'gnus 'message)
 (setq bbdb-electric-p nil))

;; kill-ring vorwaerts durchlaufen
(global-set-key [(alt y)] (lambda nil (interactive) (yank-pop -1)))


;; ispell-Kram

(initialize-lib
 "ispell" '()

; (setq ispell-local-dictionary-alist
;       '(("german-new" "[A-Za-z\"]" "[^A-Za-z\"]" "[']" nil ("-C" "-d" "ngerman") "~tex" iso-8859-1)
;         ("german-new8" "[A-Za-zÄÖÜäößü]" "[^A-Za-zÄÖÜäößü]" "[']" nil ("-C" "-d" "ngerman") "~latin1" iso-8859-1)
;         (nil "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-B") nil iso-8859-1)))
      
; (setq ispell-local-dictionary-alist
;       (append
;        '(("ngerman" "[a-zA-Z\"]" "[^a-zA-Z\"]" "[']" t ("-C" "-d" "german") "~tex" iso-8859-1)
;          ("ngerman8" "[a-zA-ZÄÖÜäößü]" "[^a-zA-ZÄÖÜäößü]" "[']" t ("-C" "-d" "german") "~latin1" iso-8859-1))
;        ispell-local-dictionary-alist))

; (setq ispell-dictionary "german-new8")
 )


(ignore-errors (require 'sawfish))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shift-(in|out)-region
;;
;; Region manuell ein- und ausruecken
;; hauptsaechlich fuer den python-mode
;; (in den anderen Modi ist insert-region brauchbar...) 

(defmacro at-beginnings-of-lines (start end &rest body)
  (let
      ((start-marker (gensym))
       (end-marker (gensym)))
    `(let
         ((,start-marker (make-marker))
          (,end-marker (make-marker)))
       (set-marker ,start-marker ,start)
       (set-marker ,end-marker ,end)
       (save-excursion
         (goto-char (marker-position ,start-marker))
         (beginning-of-line)
         (while (< (point) (marker-position ,end-marker))
           ,@body
           (forward-line 1)
           (beginning-of-line)))
       (set-marker ,start-marker nil)
       (set-marker ,end-marker nil))))


(defun shift-out-region (start end)
  "shift out current region by 1 character"
  (interactive "r")
  (at-beginnings-of-lines start end
                          (insert " "))
  ;(exchange-point-and-mark)
  ;(activate-region)   ;; also ineffective
  )

(defun shift-in-region (start end)
  "shift in current region by 1 character"
  (interactive "r")
  (at-beginnings-of-lines start end
                          (unless (equal "\n" (char-to-string (following-char)))
                            (delete-char 1)))
  ;(exchange-point-and-mark)
  ;(activate-region)   ;; also ineffective
  )

(global-set-key [(control alt right)] 'shift-out-region)
(global-set-key [(control alt left)] 'shift-in-region)

(global-set-key [(control meta right)] 'shift-out-region)
(global-set-key [(control meta left)] 'shift-in-region)


;;;; folgendes ist irgendwie cooler, aber funktioniert nur ein Mal,
;;;; weil replace-regexp die Region zerstoert:

;; (defun shift-out-region ()
;;   "shift out current region by 1 character"
;;   (interactive)
;;   (replace-regexp "^" " ")
;;   (activate-region))
;; 
;; (defun shift-in-region ()
;;   "shift in current region by 1 character"
;;   (interactive)
;;   (replace-regexp "^." "")
;;   (activate-region))
;; 

;; shift-(in|out)-region Ende
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; surround-with-tags

(defun surround-with-tags (start end tagname)
  "Surround region with <tag>...</tag>. When called interactively, the tag name is queried in the minibuffer."
  (interactive "r
sTag Name: ")
  (let*
      ((is-block
        (and (= 0 (column-number-at-pos start))
             (= 0 (column-number-at-pos start))
             (/= (line-number-at-pos start) (line-number-at-pos end))))
       (start-marker (make-marker))
       (end-marker (make-marker)))
    (set-marker start-marker start)
    (set-marker end-marker end)
    (save-excursion
      (goto-char (marker-position start-marker))
      (insert (concat "<" tagname ">"))
      (and is-block (newline))
      (goto-char (marker-position end-marker))
      (insert (concat "</" tagname ">"))
      (and is-block (newline)))
    (set-marker start-marker nil)
    (set-marker end-marker nil)))

(defun column-number-at-pos (&optional pos)
  "Return (narrowed) buffer column number at position POS.
If POS is nil, use current buffer location."
  (let ((opoint (or pos (point))) start)
    (save-excursion
      (goto-char opoint)
      (current-column))))

;; surround-with-tags ENDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; re-simple-search-(initial-)?(forward|backward)
;;
;; Einfache (nicht-inkrementelle) regexp-Textsuchfunktionen wie in Windoze-Editoren

(defun re-simple-search-initial-forward (regexp)
  "initiate another regexp search"
  (interactive "sSearch fwd. for RE: ")
  (setq re-simple-search-regexp regexp)
  (re-search-forward regexp))


(defun re-simple-search-initial-backward (regexp)
  "initiate another regexp search"
  (interactive "sSearch bckwd. for RE: ")
  (setq re-simple-search-regexp regexp)
  (re-search-backward regexp))


(defun re-simple-search-forward ()
  (interactive)
  (when (not (boundp 're-simple-search-regexp))
    (error "no initial simple search RE specified. Try M-x re-simple-search-initial."))
  (re-search-forward re-simple-search-regexp))


(defun re-simple-search-backward ()
  (interactive)
  (when (not (boundp 're-simple-search-regexp))
    (error "no initial simple search RE specified. Try M-x re-simple-search-initial."))
  (re-search-backward re-simple-search-regexp))



(global-set-key [(control f)] 're-simple-search-initial-forward)
(global-set-key [(control F)] 're-simple-search-initial-backward)
(global-set-key [(control n)] 're-simple-search-forward)
(global-set-key [(control N)] 're-simple-search-backward)

;; re-simple-search-(initial-(forward|backward)|forward|backward) Ende
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; M-x shell kann nicht mehr als eine Shell oeffnen
;; Deshalb:

(require 'shell) ;; damit die Variable `explicit-shell-file-name' existiert.
                 ;; TODO: Variable ggf. in `new-shell' nicht benutzen, um unabhaengig vom Modul `shell' zu sein.

(defun new-shell (shell-name)
  "create new buffer named \"*<shell-name>*\" (append \"-<number>\" if buffer already
exists) and run a new shell subprocess in it just like `M-x shell' does."
  (interactive "sshell name: ")
  ;; (interactive (list "huhu1" "huhu2" (read-string "3rd message: ")))  ;; so in etwa koennte es spaeter gemacht werden, wenn eine Completion oder sowas hinzukommen soll (siehe "using interactive" im ELisp-Manual)
  (let*
      ((bufname-num 1)
       bufname
       real-bufname)
    (while (member (concat "*"
			   shell-name
			   (if (= 1 bufname-num) "" (concat "-" (number-to-string bufname-num)))
			   "*")
		   (mapcar 'buffer-name (buffer-list)))
      (setq bufname-num (1+ bufname-num)))
    (setq bufname (concat shell-name
			  (if (= 1 bufname-num) "" (concat "-" (number-to-string bufname-num)))))
    (setq real-bufname (concat "*" bufname "*"))
    ;; die letzten beiden Befehle haette man auch mit oben in die while-Schleife
    ;; heineinpfriemeln koennen, dann waere die aber ziemlich komplett unlesbar
    ;; geworden.

    ;; das folgende ist aus shell.el geklaut (bis auf unten "bufname" statt ""shell"").
    (let* ((prog (or explicit-shell-file-name
		     (getenv "ESHELL")
		     (getenv "SHELL")
		     "/bin/sh"))
	   (name (file-name-nondirectory prog))
	   (startfile (concat "~/.emacs_" name))
	   (xargs-name (intern-soft (concat "explicit-" name "-args")))
	   (pop-up-windows nil)
	   shell-buffer)
      (save-excursion
	(set-buffer (apply 'make-comint bufname prog
			   (if (file-exists-p startfile) startfile)
			   (if (and xargs-name (boundp xargs-name))
			       (symbol-value xargs-name)
			     '("-i"))))
	(setq shell-buffer (current-buffer))
	(shell-mode))
      (pop-to-buffer shell-buffer))))

;; new-shell Ende
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mit Meta-S zwischen speedbar-frame und vorher
;;; aktiviertem Frame hin-und-herschalten
; nett was gelernt, aber gips schon: `speedbar-get-focus' :-|

;(defun toggle-select-speedbar-frame ()
;  (interactive)
;  (or (and (not (frame-live-p speedbar-frame))
;	   (progn
;	     (setq prev-non-speedbar-frame (selected-frame))
;	     (speedbar 1)
;	     t))
;      (if (eq (selected-frame) speedbar-frame)
;	  (progn
;	    (or (boundp 'prev-non-speedbar-frame) (setq prev-non-speedbar-frame
;							(elt (frame-list) (- (length (frame-list)) 1))))
;	    (progn (raise-frame prev-non-speedbar-frame) (select-frame prev-non-speedbar-frame)))
;	(progn
;	  (setq prev-non-speedbar-frame (selected-frame))
;	  (raise-frame speedbar-frame)
;	  (select-frame speedbar-frame)))))

;(global-set-key [(meta s)] 'toggle-select-speedbar-frame)

;;; Mit Meta-S zwischen speedbar-frame und vorher
;;; aktiviertem Frame hin-und-herschalten ENDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mausrad-Support fuer Arme
;;  (scrollt das aktive Fenster, nicht dasjenige unter dem Mauszeiger)

(global-set-key
 ;;(vector `(,mouse4))
 (if running-xemacs
     [(button4)]
   [(mouse-4)])
 (lambda () (interactive) (scroll-down 3)))

(global-set-key
 (if running-xemacs
     [(button5)]
   [(mouse-5)])
 (lambda () (interactive) (scroll-up 3)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; XML beautifying

(defun xml-beautify (start end)
  "Put each XML element in the current region on a separate line,
and indent it properly.
Useful for un-cluttering huge one-line XML files (esp. autogenerated ones)"
  (interactive "r")

  (let
      ((start-marker (make-marker))
       (end-marker (make-marker)))
    
    (set-marker start-marker start)
    (set-marker end-marker end)
    
    (save-excursion
      (goto-char (marker-position start-marker))
      (while (re-search-forward "> *<" nil t)
	(backward-char)
	(newline)
	(forward-line -1)
	(sgml-indent-or-tab)
	(forward-line 1)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; for editing file using a running Emacs instance,
;; *and* (alternatively) for connecting to a running Gnus
;; instance from the outside. See gnus.sh, man gnuserv.

(if (functionp 'gnuserv-start)

    (ignore-errors
      (gnuserv-start)
      (process-kill-without-query gnuserv-process)

      (add-hook 'kill-emacs-hook
                (lambda ()
                  (gnuserv-shutdown))))

  ;;GNU Emacs usually has server-start/emacsclient
  (ignore-errors
    (server-start)

    (add-hook 'kill-emacs-hook
              (lambda ()
                (server-start 1)))

    (setq server-window
          (lambda (buffer)
            (switch-to-buffer-other-frame buffer)))
    
    (add-hook 'server-done-hook 'delete-frame)))
