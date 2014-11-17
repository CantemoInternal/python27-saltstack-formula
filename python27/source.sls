{% set python27 = pillar.get('python27', {}) -%}
{% set version = python27.get('version', '2.7.8') -%}
{% set checksum = python27.get('checksum', 'md5=d235bdfa75b8396942e360a70487ee00') -%}
{% set source = python27.get('source_root', '/usr/src') -%}
{% set python27_package = '{0}/Python-{1}.tar.xz'.format(source, version) -%}

{% from "python27/devmap.jinja" import linux_dev_pkgs with context %}

linux-dev-pkgs:
  pkg.installed:
    - pkgs: {{ linux_dev_pkgs.pkgs|json }}

get-python27:
  file.managed:
    - name: {{ python27_package }}
    - source: http://python.org/ftp/python/{{ version }}/Python-{{ version }}.tar.xz
    - source_hash: {{ checksum }}
  cmd.wait:
    - cwd: {{ source }}
    - name: tar xf {{ python27_package }}
    - watch:
      - file: get-python27
      - pkg: linux-dev-pkgs

python27:
  cmd.wait:
    - cwd: {{ source }}/Python-{{ version }}
    - names:
      - ./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
      - make && make install
    - watch:
      - cmd: get-python27
    - require:
      - cmd: get-python27

get-ez:
  file.managed:
    - name: {{ source }}/ez_setup.py
    - source: salt://python27/files/ez_setup.py
  cmd.wait:
    - cwd: {{ source }}
    - name: /usr/local/python /bin/activate && python ez_setup_setup.py
    - watch:
      - file: get-ez

get-pip:
  cmd.wait:
    - cwd: {{ source }}
    - name: /usr/local/python /bin/activate && eazy_install pip
    - required:
      - file: get-ez

get-virtualenv:
  cmd.wait:
    - cwd: {{ source }}
    - name: pip install virtualenv
    - required:
      - file: get-pip
