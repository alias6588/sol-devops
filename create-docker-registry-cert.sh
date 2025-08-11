mkdir registry_certs
echo subjectAltName=DNS:*.notavaa.com > alt_names.txt
openssl req -new -newkey rsa:4096 -nodes -keyout registry_certs/domain.key -out registry_certs/domain.req -subj "/C=IR/ST=Tehran/L=tehran/O=BEHRAD/CN=repo.notavaa.com"
openssl x509 -req -extfile alt_names.txt -sha256 -days 365 -in registry_certs/domain.req -signkey registry_certs/domain.key  -out registry_certs/domain.cert