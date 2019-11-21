# Entering SRCHOME/plsql/install/cus_plsql.mk
include $(ORACLE_HOME)/plsql/lib/env_plsql.mk

INSTALL_TARGS=iwrap
ALL_EXECS=$(WRAP)
PLSQLBIN=

default: wrap

preinstall:
	-chmod 755 $(ORACLE_HOME)/bin

install: preinstall $(INSTALL_TARGS)

clean:
	-rm -f $(ALL_EXECS) 

iwrap: wrap
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/wrap || (\
	   mv -f $(ORACLE_HOME)/bin/wrap $(ORACLE_HOME)/bin/wrapO &&\
	   chmod 600 $(ORACLE_HOME)/bin/wrapO )
	-mv $(ORACLE_HOME)/plsql/lib/$(WRAP) $(ORACLE_HOME)/bin/wrap
	-chmod 751 $(ORACLE_HOME)/bin/wrap

mk_softlinks:
	$(LNS) $(OHLIBPLS) $(LOC_LIBPLSSH)
	$(LNS) $(LOC_SHLIBPLSSH) $(LIBPLSSH)
	$(LNS) $(OHLIBPLP) $(LOC_LIBPLPSH)
	$(LNS) $(LOC_SHLIBPLPSH) $(LIBPLPSH)
# Exiting SRCHOME/plsql/install/cus_plsql.mk
# Entering link.mk

$(WRAP):  $(WRAP_MAIN) $(PLSQLLIBS) $(PLS_PRIVATE_LIBS)
	$(RMF) $@
	@$(ECHO) "Linking wrap"
	$(WRAP_LINKLINE)

# Exiting link.mk
