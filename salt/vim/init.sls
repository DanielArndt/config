{% set home = salt.environ.get('HOME') %}
{% set user = salt.environ.get('CONFIG_USER') %}

{{ home }}/.vim_runtime:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

checkout vim config:
  git.latest:
    - name: https://github.com/DanielArndt/vim-config.git
    - target: {{ home }}/.vim_runtime
    - submodules: True
    - user: {{ user }}

vimrc:
  file.managed:
    - name: {{ home }}/.vimrc
    - source: salt://vim/vimrc

install vim:
  pkg.installed:
    - name: vim

vim default editor:
  alternatives.set:
    - name: editor
    - path: /usr/bin/vim.basic
