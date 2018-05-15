import yaml
from slugify import slugify

f = open('staging.yml')
data = f.read()

config = yaml.load(data)

# dnsRecord: server.bigfort.hom.stefaniniinspiring.com.br
# backend: 127.0.0.1:8089
# path: /dl

# nginx template
# apiPort
# dnsRecord
# apiPath
# apiLocation

"""
{{ apiHost }}
{{ apiPort }}
{{ dnsRecord }}
{{ apiLocation }}
"""

template = open('./nginx-config.tpl').read()
for service in config['services']:
  nginxConfig = "./nginx-configs/%s.conf" % slugify(service['dnsRecord'])

  dnsRecord = service['dnsRecord']
  backendIP = service['backend'].split(':')[0]
  backendPort = service['backend'].split(':')[1]
  apiLocation =  service['path'] if 'path' in service.keys() else '/'

  configFile = template.replace('{{ dnsRecord }}', dnsRecord)
  configFile = configFile.replace('{{ apiHost }}', backendIP)
  configFile = configFile.replace('{{ apiPort }}', backendPort)
  configFile = configFile.replace('{{ apiLocation }}', apiLocation)

  output = open(nginxConfig, 'w')
  output.write(configFile)
  output.close()

