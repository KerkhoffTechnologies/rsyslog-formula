{# vi: set ft=jinja: #}
{% from "rsyslog/map.jinja" import rsyslog with context %}

rsyslog:
  pkg.installed:
    - name: {{ rsyslog.lookup.package }}
  file.managed:
    - name: {{ rsyslog.lookup.config }}
    - template: jinja
    - source: salt://rsyslog/templates/rsyslog.conf.jinja
    - context:
      config: {{ rsyslog.lookup|json }}
  service.running:
    - enable: True
    - name: {{ rsyslog.lookup.service }}
    - require:
      - pkg: {{ rsyslog.lookup.package }}
    - watch: 
      - file: {{ rsyslog.lookup.config }}

workdirectory:
  file.directory:
    - name: {{ rsyslog.lookup.workdirectory }}
    - user: {{ rsyslog.lookup.runuser }}
    - group: {{ rsyslog.lookup.rungroup }}
    - mode: 755
    - makedirs: True

{% for filename in rsyslog.custom %}
{% set basename = filename.split('/')|last %}
rsyslog_custom_{{basename}}:
  file.managed:
    - name: {{ rsyslog.lookup.custom_config_path }}/{{ basename|replace(".jinja", "") }}
    {% if basename != filename %}
    - source: {{ filename }}
    {% else %}
    - source: salt://rsyslog/files/{{ filename }}
    {% endif %}
    {% if filename.endswith('.jinja') %}
    - template: jinja
      config: {{ rsyslog.config|json }}
    {% endif %}
    - watch_in:
      - service: {{ rsyslog.lookup.service }}
{% endfor %}
