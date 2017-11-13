{% set home = salt.environ.get('HOME') %}

{{ home }}/.git_template/hooks:
  file.directory:
    - makedirs: True

ctags hook file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/ctags
    - source: salt://git/git_template/hooks/ctags

post checkout file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/post-checkout
    - source: salt://git/git_template/hooks/post-checkout

post commit file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/post-commit
    - source: salt://git/git_template/hooks/post-commit

post merge file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/post-merge
    - source: salt://git/git_template/hooks/post-merge

post rewrite file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/post-rewrite
    - source: salt://git/git_template/hooks/post-rewrite

pre push file:
  file.managed:
    - name: {{ home }}/.git_template/hooks/pre-push
    - source: salt://git/git_template/hooks/pre-push

initiate git template dir:
  git.config_set:
    - name: init.templatedir
    - value: {{ home }}/.git_template
    - global: True
