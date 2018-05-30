
pwd = $(shell pwd)
install:
	@cp src/main.py /usr/bin/initmux

uninstall:
	@rm /usr/bin/initmux

link:
	@ln -s $(pwd)/src/main.py /usr/bin/initmux
