PODMAN := /usr/bin/flatpak-spawn --host podman

.PHONY: ignition
ignition:
	$(PODMAN) run --interactive --rm --security-opt label=disable \
       --volume ${PWD}:/pwd --workdir /pwd quay.io/coreos/butane:release \
       --pretty --strict test.bu > test.ign

.PHONY: serve
serve:
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

.PHONY: clean
clean:
	rm install.sh
	rm test.ign

install/vm: ignition
	echo "sudo coreos-installer install /dev/vda --ignition-url http://10.0.2.2:8000/test.ign --insecure-ignition" > install.sh
	echo "systemctl reboot" >> install.sh
	chmod +x install.sh
	echo "serving install.sh"
	make serve
	make clean

default: ignition
