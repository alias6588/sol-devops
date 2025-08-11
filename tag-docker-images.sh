#!/bin/bash

REGISTRY="repo.notavaa.com:5000"

# گرفتن لیست ایمیج‌ها به فرمت name:tag
docker image ls --format "{{.Repository}}:{{.Tag}}" | while read image; do
  # اگر ایمیج از قبل با آدرس ریجستری شروع شده، ردش کن
  if [[ "$image" == $REGISTRY* ]]; then
    echo "Skipping already tagged: $image"
    continue
  fi

  # ایمیج جدید با تگ ریجستری
  new_image="$REGISTRY/$image"

  echo "Tagging $image as $new_image"
  docker tag "$image" "$new_image"
  docker push "$new_image"
done

