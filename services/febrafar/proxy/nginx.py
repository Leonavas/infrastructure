import yaml

f = open('staging.yml')
data = f.read()

config = yaml.load(data)

# dnsRecord: server.bigfort.hom.stefaniniinspiring.com.br
# backend: 127.0.0.1:8089
# path: /dl
