
pwd = $(shell pwd)

run:
	@python src/main.py --help
	@echo --------------------------
	@python src/main.py echo


install:
	@cp src/main.py /usr/bin/initmux

uninstall:
	@rm /usr/bin/initmux

link:
	@ln -s $(pwd)/src/main.py /usr/bin/initmux
