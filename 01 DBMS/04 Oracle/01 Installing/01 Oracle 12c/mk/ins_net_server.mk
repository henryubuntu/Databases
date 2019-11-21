# $Id: cus_net_server.mk /main/11 2016/05/11 10:24:24 bhmathur Exp $
#
# cus_net_server.mk - "make" command file to reload tnslsnr, lsnrctl
#
# Used to reload tnslsnr, lsnrctl, after changing network protocol adapter.
#
# NOTE: ORACLE_HOME must be either:
#   . set in the user's environment
#   . passed in on the command line
#   . defined in a modified version of this makefile
#
# MODIFIED  (MM/DD/YY)
# skramas    05/05/16  - Permissions for backup
# donlee     03/08/02  - cannot use $<
# donlee     02/27/02  - define/use macro covers for INSTALL_TARGS
# donlee     02/26/02  - use relevant LINKLINE macros
# donlee     02/08/01 -  rm unneeded macro defs
# donlee     02/08/01  - rm unnecessary def of ECHO
# mkrohan    10/12/00  - Switch from LINKEXSYSLIBS to LINKLDLIBS
# mkrohan    05/20/00  - Bug #1304913
#

include $(ORACLE_HOME)/network/lib/env_network.mk

INSTALL_TARGS=clean $(INSTALL_NET_SERVER_TARGS)

tnslsnr: $(S0NSGL) $(SNSGLP) $(NSGLPNP)
	$(SILENT)$(ECHO) " - Linking $(TNSLSNR)"
	$(RMF) $@
	$(TNSLSNR_LINKLINE) -lnnz12 -lons

itnslsnr: tnslsnr
	-$(MV) -f $(BINHOME)tnslsnr $(BINHOME)tnslsnr0
	-$(MV) tnslsnr $(BINHOME)tnslsnr
	-$(CHMOD) 751 $(BINHOME)tnslsnr
	-$(CHMOD) 600 $(BINHOME)tnslsnr0

lsnrctl: $(S0NSGLC)
	$(SILENT)$(ECHO) " - Linking $(LSNRCTL)"
	$(RMF) $@
	$(LSNRCTL_LINKLINE) -lnnz12 -lons

ilsnrctl: lsnrctl
	-$(MV) -f $(BINHOME)lsnrctl $(BINHOME)lsnrctl0
	-$(MV) lsnrctl $(BINHOME)lsnrctl
	-$(CHMOD) 751 $(BINHOME)lsnrctl
	-$(CHMOD) 600 $(BINHOME)lsnrctl0

preinstall:
	-$(CHMOD) 755 $(BINHOME)

install: preinstall $(INSTALL_TARGS)

clean:
