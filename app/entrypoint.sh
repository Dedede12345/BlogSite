#!/bin/bash
# Author: Gleb Denisov
# Description: This entrypoint runs Django setup commands and waits for database.

# Waiting for database

# Django setup commands
#python3 manage.py flush --no-input
python manage.py migrate

# Collect static files
STATIC_DIR="/usr/src/app/staticfiles"

if [ -d "$STATIC_DIR" ] && [ "$(ls -A $STATIC_DIR)" ]; then
    echo "[*] Static files present"
else
    echo "[*] Collecting static files"
    python manage.py collectstatic --noinput
fi


# Create superuser if it doesn't exist
echo "[*] Creating superuser"
DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME:-admin}
DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-admin@example.com}
DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD:-adminpass}

python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="$DJANGO_SUPERUSER_USERNAME").exists():
    User.objects.create_superuser("$DJANGO_SUPERUSER_USERNAME", "$DJANGO_SUPERUSER_EMAIL", "$DJANGO_SUPERUSER_PASSWORD")
END

# CMD
exec "$@"