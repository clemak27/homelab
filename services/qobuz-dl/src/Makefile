serve:
	poetry run uvicorn server:app --reload

VERSION = 0.0.1local

build:
	docker build --build-arg QOBUZ_PASSWORD=${QOBUZ_PASSWORD} --build-arg QOBUZ_EMAIL=${QOBUZ_EMAIL} -t qobuz-dl:$(VERSION) .
run:
	docker run --rm -it -p 8526:8526 --security-opt label=disable --volume /var/mnt/media/music/:/app/music qobuz-dl:$(VERSION)

