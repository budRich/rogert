PREFIX  = /usr
DESTDIR =
INSTDIR = $(DESTDIR)$(PREFIX)
INSTBIN = $(INSTDIR)/bin

install:
	test -d $(INSTBIN) || mkdir -p $(INSTBIN)

	install -m 0755 rogert.sh  $(INSTBIN)/rogert
	install -m 0755 cliplog.py $(INSTBIN)/cliplog
.PHONY: install

uninstall:
	$(RM) $(INSTBIN)/rogert
	$(RM) $(INSTBIN)/cliplog
.PHONY: uninstall
