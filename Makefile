NAME = dockerbase/nginx
VERSION = 1.0

.PHONY: all build test tag_latest release ssh enter

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

test:
	docker run -it --rm $(NAME):$(VERSION) echo hello world!

run:
	mkdir -p /var/dockerbase/nginx
	chown 102 /var/dockerbase/nginx
	#docker run --name dockerbase-nginx --restart=always -t --cidfile cidfile -p 80:80 -v /var/dockerbase/nginx:/etc/nginx/sites-enabled -d $(NAME):$(VERSION) /sbin/runit
	docker run --name dockerbase-nginx --restart=always -t --cidfile cidfile -p 80:80 -d $(NAME):$(VERSION) /sbin/runit

start:
	docker start `cat cidfile`

log:
	docker logs `cat cidfile`

ls_volume:
	@ID=$$(docker ps | grep -F "$(NAME):$(VERSION)" | awk '{ print $$1 }') && \
                if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
                DIR=$$(docker inspect $$ID | python -c 'import json,sys; obj=json.load(sys.stdin); print obj[0]["Volumes"]["/etc/nginx/sites-enabled"]') && \
                echo "looking at $$DIR" && \
		ls -ls $$DIR

version:
	docker run -it --rm $(NAME):$(VERSION) sh -c ' git --version ; nginx -v; ' | tee COMPONENTS
	dos2unix COMPONENTS

stop:
	docker stop -t 10 `cat cidfile`

rm:
	docker rm `cat cidfile`
	rm -fr cidfile

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	#@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

ssh:
	chmod 600 build/insecure_key
	@ID=$$(docker ps | grep -F "$(NAME):$(VERSION)" | awk '{ print $$1 }') && \
		if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
		IP=$$(docker inspect $$ID | grep IPAddr | sed 's/.*: "//; s/".*//') && \
		echo "SSHing into $$IP" && \
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i build/insecure_key root@$$IP

enter:
	@ID=$$(docker ps | grep -F "$(NAME):$(VERSION)" | awk '{ print $$1 }') && \
		if test "$$ID" = ""; then echo "Container is not running."; exit 1; fi && \
		PID=$$(docker inspect --format {{.State.Pid}} $$ID) && \
		SHELL=/bin/bash sudo -E build/bin/nsenter --target $$PID --mount --uts --ipc --net --pid
