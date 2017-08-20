{{ salt.environ.get('HOME') }}/.git_template/hooks:
  file.directory

ctags hook file:
  file.managed:
    - name: {{ salt.environ.get('HOME') }}/.git_template/hooks/ctags
    - source: salt://git/.git_template/hooks/ctags
