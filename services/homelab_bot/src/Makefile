bin/golangci-lint:
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.49.0

build:
	go build .

test:
	go test ./...

test_coverage:
	go test ./... -coverprofile=coverage.out

dep:
	go mod download

lint: bin/golangci-lint
	./bin/golangci-lint run

fix: bin/golangci-lint
	./bin/golangci-lint run --fix

clean:
	go clean
	rm -rf ./bin

docker_image_name=homelab_bot
docker_image_tag=0.1.10

docker/deploy: docker/clean docker/build docker/run
	sleep 10
	curl -X POST -H "Content-Type: application/json" -d '{"title": "home_bot", "text": "Deployed version $(docker_image_tag)"}' --url localhost:8525/message

docker/clean:
	docker container stop $(docker_image_name)
	docker container rm $(docker_image_name)

docker/build:
	docker build . --build-arg TELEGRAM_CHAT=${TELEGRAM_CHAT} --build-arg TELEGRAM_URL=${TELEGRAM_URL} -t $(docker_image_name):$(docker_image_tag)

docker/run:
	docker run -d --restart=always -p 8525:8525 --name $(docker_image_name) $(docker_image_name):$(docker_image_tag)
