;; Use this for blockquotes.
(global-set-key (kbd "C-c h")
                (lambda () (interactive)
                  (shell-command-on-region
                   (region-beginning) (region-end)
                   "text2html --paras --urls --blockquotes --email --bullets --numbers --tables --bold --underline"
                   (current-buffer) t)))

;; And this for blockcode.
(global-set-key (kbd "C-c j")
                (lambda () (interactive)
                  (shell-command-on-region
                   (region-beginning) (region-end)
                   "text2html --paras --urls --blockcode --email --bullets --numbers --tables --bold --underline"
                   (current-buffer) t)))
