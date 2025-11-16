ART_HOME=/srv/sol/artifactory-data

sudo mkdir -p "$ART_HOME"
sudo chown -R 1030:1030 "$ART_HOME"
sudo chmod -R u+rwX,g+rwX "$ART_HOME"

