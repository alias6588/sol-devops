sudo mkdir -p /srv/sol/nexus-data
# مالکیت Nexus داخل کانتینر uid=200 هست
sudo chown -R 200:200 /srv/sol/nexus-data

# اگر قبلاً Nexus را اجرا کردی، این را هم چک کن:
# خط‌هایی مثل karaf.data یا nexus-work اگر به مسیر قدیمی اشاره می‌کنند، درست‌شان کن یا حذف‌شان کن
if [ -f /srv/sol/nexus-data/etc/nexus.properties ]; then
  sudo sed -i 's#^\s*karaf\.data=.*#karaf.data=/nexus-data#' /srv/sol/nexus-data/etc/nexus.properties
  sudo sed -i 's#^\s*nexus-work=.*#nexus-work=/nexus-data#' /srv/sol/nexus-data/etc/nexus.properties
fi

# (اختیاری) بسازن، ولی Nexus خودش می‌سازه:
sudo mkdir -p /srv/sol/nexus-data/log
sudo chown -R 200:200 /srv/sol/nexus-data/log
