# Entering SRCHOME/rdbms/install/cus_rdbms.mk
include $(ORACLE_HOME)/rdbms/lib/env_rdbms.mk

MAKEFILE=$(RDBMSLIB)ins_rdbms.mk
RDBMSBIN=$(ORACLE_HOME)/rdbms/lib/
OSNTABST= `if [ -f $(ORACLE_HOME)/lib/osntabst.o ]; then \
		echo '$(ORACLE_HOME)/lib/osntabst.o'; \
	   else \
		echo '$(ORACLE_HOME)/network/lib/osntabst.o'; \
	   fi `

PATCHSET_OPT=
patchset_opt:
	if $(ARPRINT) ${LIBKNLOPT} | grep $(PATCHSET_OPT); \
        then \
                echo "$(PATCHSET_OPT) found ${LIBKNLOPT} "; \
                $(ARREPLACE) ${LIBKNLOPT} $(PATCHSET_OPT) ; \
        else \
                echo "$(PATCHSET_OPT) not found ${LIBKNLOPT} "; \
        fi;

patchset_opt_all:
	$(CD) $(RDBMSLIB);\
	$(ARREPLACE) $(LIBKNLOPT) `$(ARPRINT) $(LIBKNLOPT)` ; 

patch_odmlib:
	if [ -f $(RDBMSLIB)odm/$(LIB_PREFIX)nfsodm$(RDBMS_VERSION).$(SO_EXT) ]; \
	then \
	$(RMF) $(RDBMSLIB)odm/$(LIB_PREFIX)nfsodm$(RDBMS_VERSION).$(SO_EXT) ; \
	$(CPODM_DNFS) ; \
	fi 

$(RDBMSLIB)ksms.s:
	$(GENKSMS) > $(RDBMSLIB)ksms.s

ksms.o $(KSMS): $(RDBMSLIB)ksms.s
	$(SILENT)$(CD) $(RDBMSLIB); \
	$(AS) $(NOKPIC_ASFLAGS) -o ksms.o ksms.s; \
	$(AR) r $(LIBSERVER) ksms.o

$(CONFIG):
	$(SILENT)$(CD) $(RDBMSLIB); \
	$(CONFIG_COMPILE_LINE); \
	$(AR) r $(LIBSERVER) $(CONFIG)

update_patchrep: 
	$(MVF) $(LIBASMCLNTSH) $(LIBASMCLNTSH).bak
	$(ASSEMBLE_SKGFPMI_LINE)
	$(ARREPLACE) $(LIBASMCLNT) $(RDBMSLIB)skgfpmi.$(OBJ_EXT)
	$(ARREPLACE) $(LIBHOME)$(LIB_PREFIX)$(LIBASMCLNTSHNAME).$(LIB_EXT) $(RDBMSLIB)skgfpmi.$(OBJ_EXT)
	$(RMF) $(RDBMSLIB)skgfpmi.$(OBJ_EXT)
	$(RMF) $(RDBMSLIB)skgfpmi.$(AS_EXT)
	$(MAKE) $(LIBASMCLNTSH) -f $(MAKEFILE)

client_sharedlib:
	$(GENCLNTSH)
	$(REMOVE_COMPATIBILITY_LINKS)
	$(CREATE_COMPATIBILITY_LINKS)
	$(GENOCCISH)
	$(GENAGTSH) $(LIBAGTSH) 1.0

default: $(ORACLE)

test: clean $(ITEST)

utilities:	$(IUTILITIES)

svr_tool:	$(ISVR_TOOL)
  
parropt: rac_on
no_parropt: rac_off

sdopt: sdo_on
no_sdopt: sdo_off

ipc_none:
	-$(RMF) $(LIBSKGXP)
	$(CP) $(LIBHOME)/libskgxpd.$(SKGXP_EXT) $(LIBSKGXP)

ipc_g:
	-$(RMF) $(LIBSKGXP)
	$(CP) $(LIBHOME)/libskgxpg.$(SKGXP_EXT) $(LIBSKGXP)

ipc_rds:
	-$(RMF) $(LIBSKGXP)
	$(CP) $(LIBHOME)/libskgxpr.$(SKGXP_EXT) $(LIBSKGXP)

ipc_relink:
	(if $(ORACLE_HOME)/bin/skgxpinfo | grep rds;\
	then \
	$(MAKE) -f  $(MAKEFILE) ipc_rds; \
	else \
	$(MAKE) -f  $(MAKEFILE) ipc_g; \
	fi)


nm_auto:
	$(GENNMLIB)

nm_none:
	-$(RMF) $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)
	$(CP) $(LIBHOME)/libskgxns.$(SKGXN_EXT) \
	      $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)

nm_ref:
	-$(RMF) $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)
	$(CP) $(LIBHOME)/libskgxnr.$(SKGXN_EXT) \
	      $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)

nm_ext:
	-$(RMF) $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)
	$(CP) $(LIBSKGXN) $(LIBHOME)lib$(LIBSKGXNNAME).$(SKGXN_EXT)

ioracle: preinstall $(ORACLE)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/oracle || (\
	   mv -f $(ORACLE_HOME)/bin/oracle $(ORACLE_HOME)/bin/oracleO &&\
	   chmod 600 $(ORACLE_HOME)/bin/oracleO )
	-mv $(ORACLE_HOME)/rdbms/lib/oracle $(ORACLE_HOME)/bin/oracle
	-chmod 6751 $(ORACLE_HOME)/bin/oracle

idbv: $(DBVERIFY)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/dbv || (\
	   mv -f $(ORACLE_HOME)/bin/dbv $(ORACLE_HOME)/bin/dbvO &&\
	   chmod 600 $(ORACLE_HOME)/bin/dbvO )
	-mv $(ORACLE_HOME)/rdbms/lib/dbv $(ORACLE_HOME)/bin/dbv
	-chmod 751 $(ORACLE_HOME)/bin/dbv

idbfs_client: $(DBFS_CLIENT)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/dbfs_client || (\
	   mv -f $(ORACLE_HOME)/bin/dbfs_client $(ORACLE_HOME)/bin/dbfs_clientO &&\
	   chmod 600 $(ORACLE_HOME)/bin/dbfs_clientO )
	-mv $(ORACLE_HOME)/rdbms/lib/dbfs_client $(ORACLE_HOME)/bin/dbfs_client
	-chmod 751 $(ORACLE_HOME)/bin/dbfs_client
  
itstshm: $(TSTSHM)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/tstshm || (\
	   mv -f $(ORACLE_HOME)/bin/tstshm $(ORACLE_HOME)/bin/tstshmO &&\
	   chmod 600 $(ORACLE_HOME)/bin/tstshmO )
	-mv $(ORACLE_HOME)/rdbms/lib/tstshm $(ORACLE_HOME)/bin/tstshm
	-chmod 751 $(ORACLE_HOME)/bin/tstshm

imaxmem: $(MAXMEM)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/maxmem || (\
	   mv -f $(ORACLE_HOME)/bin/maxmem $(ORACLE_HOME)/bin/maxmemO &&\
	   chmod 600 $(ORACLE_HOME)/bin/maxmemO )
	-mv $(ORACLE_HOME)/rdbms/lib/maxmem $(ORACLE_HOME)/bin/maxmem
	-chmod 751 $(ORACLE_HOME)/bin/maxmem

iorapwd: $(ORAPWD)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/orapwd || (\
	   mv -f $(ORACLE_HOME)/bin/orapwd $(ORACLE_HOME)/bin/orapwdO &&\
	   chmod 600 $(ORACLE_HOME)/bin/orapwdO )
	-mv $(ORACLE_HOME)/rdbms/lib/orapwd $(ORACLE_HOME)/bin/orapwd
	-chmod 751 $(ORACLE_HOME)/bin/orapwd

idbfsize: $(DBFSIZE)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/dbfsize || (\
	   mv -f $(ORACLE_HOME)/bin/dbfsize $(ORACLE_HOME)/bin/dbfsizeO &&\
	   chmod 600 $(ORACLE_HOME)/bin/dbfsizeO )
	-mv $(ORACLE_HOME)/rdbms/lib/dbfsize $(ORACLE_HOME)/bin/dbfsize
	-chmod 751 $(ORACLE_HOME)/bin/dbfsize

icursize: $(CURSIZE)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/cursize || (\
	   mv -f $(ORACLE_HOME)/bin/cursize $(ORACLE_HOME)/bin/cursizeO &&\
	   chmod 600 $(ORACLE_HOME)/bin/cursizeO )
	-mv $(ORACLE_HOME)/rdbms/lib/cursize $(ORACLE_HOME)/bin/cursize
	-chmod 751 $(ORACLE_HOME)/bin/cursize

itdscomp: $(TDSCOMP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/tdscomp || (\
	   mv -f $(ORACLE_HOME)/bin/tdscomp $(ORACLE_HOME)/bin/tdscompO &&\
	   chmod 600 $(ORACLE_HOME)/bin/tdscompO )
	-mv $(ORACLE_HOME)/rdbms/lib/tdscomp $(ORACLE_HOME)/bin/tdscomp
	-chmod 751 $(ORACLE_HOME)/bin/tdscomp

iextproc: $(EXTPROC)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/extproc || (\
	   mv -f $(ORACLE_HOME)/bin/extproc $(ORACLE_HOME)/bin/extprocO &&\
	   chmod 600 $(ORACLE_HOME)/bin/extprocO )
	-mv $(ORACLE_HOME)/rdbms/lib/extproc $(ORACLE_HOME)/bin/extproc
	-chmod 751 $(ORACLE_HOME)/bin/extproc

iextproc32: extproc32
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/extproc32 || (\
	   mv -f $(ORACLE_HOME)/bin/extproc32 $(ORACLE_HOME)/bin/extproc32O &&\
	   chmod 600 $(ORACLE_HOME)/bin/extproc32O )
	-mv $(ORACLE_HOME)/rdbms/lib/extproc32 $(ORACLE_HOME)/bin/extproc32
	-chmod 751 $(ORACLE_HOME)/bin/extproc32

iagtctl: $(AGTCTL)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/agtctl || (\
	   mv -f $(ORACLE_HOME)/bin/agtctl $(ORACLE_HOME)/bin/agtctlO &&\
	   chmod 600 $(ORACLE_HOME)/bin/agtctlO )
	-mv $(ORACLE_HOME)/rdbms/lib/agtctl $(ORACLE_HOME)/bin/agtctl
	-chmod 751 $(ORACLE_HOME)/bin/agtctl

idg4pwd itg4pwd: $(TG4PWD)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)pwd || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)pwd $(ORACLE_HOME)/bin/$(TG4DG4)pwdO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)pwdO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)pwd $(ORACLE_HOME)/bin/$(TG4DG4)pwd
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)pwd

ihsalloci: $(HSALLOCI)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/hsalloci || (\
	   mv -f $(ORACLE_HOME)/bin/hsalloci $(ORACLE_HOME)/bin/hsallociO &&\
	   chmod 600 $(ORACLE_HOME)/bin/hsallociO )
	-mv $(ORACLE_HOME)/rdbms/lib/hsalloci $(ORACLE_HOME)/bin/hsalloci
	-chmod 751 $(ORACLE_HOME)/bin/hsalloci

ihsots: $(HSOTS)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/hsots || (\
	   mv -f $(ORACLE_HOME)/bin/hsots $(ORACLE_HOME)/bin/hsotsO &&\
	   chmod 600 $(ORACLE_HOME)/bin/hsotsO )
	-mv $(ORACLE_HOME)/rdbms/lib/hsots $(ORACLE_HOME)/bin/hsots
	-chmod 751 $(ORACLE_HOME)/bin/hsots

ihsdepxa: $(HSDEPXA)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/hsdepxa || (\
	   mv -f $(ORACLE_HOME)/bin/hsdepxa $(ORACLE_HOME)/bin/hsdepxaO &&\
	   chmod 600 $(ORACLE_HOME)/bin/hsdepxaO )
	-mv $(ORACLE_HOME)/rdbms/lib/hsdepxa $(ORACLE_HOME)/bin/hsdepxa
	-chmod 751 $(ORACLE_HOME)/bin/hsdepxa

idg4odbc ihsodbc: $(S_HSODBC)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(HSDG4)odbc || (\
	   mv -f $(ORACLE_HOME)/bin/$(HSDG4)odbc $(ORACLE_HOME)/bin/$(HSDG4)odbcO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(HSDG4)odbcO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(HSDG4)odbc $(ORACLE_HOME)/bin/$(HSDG4)odbc
	-chmod 751 $(ORACLE_HOME)/bin/$(HSDG4)odbc

idg4adbs itg4adbs: $(S_TG4ADBS)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)adbs || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)adbs $(ORACLE_HOME)/bin/$(TG4DG4)adbsO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)adbsO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)adbs $(ORACLE_HOME)/bin/$(TG4DG4)adbs
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)adbs

idg4db2 itg4db2: $(S_TG4DB2)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)db2 || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)db2 $(ORACLE_HOME)/bin/$(TG4DG4)db2O &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)db2O )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)db2 $(ORACLE_HOME)/bin/$(TG4DG4)db2
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)db2

idg4ifmx itg4ifmx: $(S_TG4IFMX)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)ifmx || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)ifmx $(ORACLE_HOME)/bin/$(TG4DG4)ifmxO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)ifmxO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)ifmx $(ORACLE_HOME)/bin/$(TG4DG4)ifmx
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)ifmx

idg4ims itg4ims: $(S_TG4IMS)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)ims || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)ims $(ORACLE_HOME)/bin/$(TG4DG4)imsO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)imsO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)ims $(ORACLE_HOME)/bin/$(TG4DG4)ims
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)ims

itg4ingr: $(S_TG4INGR)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/tg4ingr || (\
	   mv -f $(ORACLE_HOME)/bin/tg4ingr $(ORACLE_HOME)/bin/tg4ingrO &&\
	   chmod 600 $(ORACLE_HOME)/bin/tg4ingrO )
	-mv $(ORACLE_HOME)/rdbms/lib/tg4ingr $(ORACLE_HOME)/bin/tg4ingr
	-chmod 751 $(ORACLE_HOME)/bin/tg4ingr

idg4msql itg4msql: $(S_TG4MSQL)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)msql || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)msql $(ORACLE_HOME)/bin/$(TG4DG4)msqlO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)msqlO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)msql $(ORACLE_HOME)/bin/$(TG4DG4)msql
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)msql

idg4sybs itg4sybs: $(S_TG4SYBS)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)sybs || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)sybs $(ORACLE_HOME)/bin/$(TG4DG4)sybsO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)sybsO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)sybs $(ORACLE_HOME)/bin/$(TG4DG4)sybs
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)sybs

idg4tera itg4tera: $(S_TG4TERA)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)tera || (\
	   mv -f $(ORACLE_HOME)/bin/$(TG4DG4)tera $(ORACLE_HOME)/bin/$(TG4DG4)teraO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)teraO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)tera $(ORACLE_HOME)/bin/$(TG4DG4)tera
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)tera

idg4vsam itg4vsam: $(S_TG4VSAM)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/$(TG4DG4)vsam || (\
	  mv -f $(ORACLE_HOME)/bin/$(TG4DG4)vsam $(ORACLE_HOME)/bin/$(TG4DG4)vsamO &&\
	   chmod 600 $(ORACLE_HOME)/bin/$(TG4DG4)vsamO )
	-mv $(ORACLE_HOME)/rdbms/lib/$(TG4DG4)vsam $(ORACLE_HOME)/bin/$(TG4DG4)vsam
	-chmod 751 $(ORACLE_HOME)/bin/$(TG4DG4)vsam

iarchmon: $(ARCHMON)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/archmon || (\
	   mv -f $(ORACLE_HOME)/bin/archmon $(ORACLE_HOME)/bin/archmonO &&\
	   chmod 600 $(ORACLE_HOME)/bin/archmonO )
	-mv $(ORACLE_HOME)/rdbms/lib/archmon $(ORACLE_HOME)/bin/archmon
	-chmod 751 $(ORACLE_HOME)/bin/archmon

iosh: $(OSH)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/osh || (\
	   mv -f $(ORACLE_HOME)/bin/osh $(ORACLE_HOME)/bin/oshO &&\
	   chmod 600 $(ORACLE_HOME)/bin/oshO )
	-mv $(ORACLE_HOME)/rdbms/lib/osh $(ORACLE_HOME)/bin/osh
	-chmod 751 $(ORACLE_HOME)/bin/osh

isbttest: $(SBTTEST)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/sbttest || (\
	   mv -f $(ORACLE_HOME)/bin/sbttest $(ORACLE_HOME)/bin/sbttestO &&\
	   chmod 600 $(ORACLE_HOME)/bin/sbttestO )
	-mv $(ORACLE_HOME)/rdbms/lib/sbttest $(ORACLE_HOME)/bin/sbttest
	-chmod 751 $(ORACLE_HOME)/bin/sbttest

iexp: $(EXP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/exp || (\
	   mv -f $(ORACLE_HOME)/bin/exp $(ORACLE_HOME)/bin/expO &&\
	   chmod 600 $(ORACLE_HOME)/bin/expO )
	-mv $(ORACLE_HOME)/rdbms/lib/exp $(ORACLE_HOME)/bin/exp
	-chmod 751 $(ORACLE_HOME)/bin/exp

iimp: $(IMP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/imp || (\
	   mv -f $(ORACLE_HOME)/bin/imp  $(ORACLE_HOME)/bin/impO &&\
	   chmod 600 $(ORACLE_HOME)/bin/impO )
	-mv $(ORACLE_HOME)/rdbms/lib/imp $(ORACLE_HOME)/bin/imp
	-chmod 751 $(ORACLE_HOME)/bin/imp

iexpdp: $(EXPDP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/expdp || (\
	   mv -f $(ORACLE_HOME)/bin/expdp $(ORACLE_HOME)/bin/expdpO &&\
	   chmod 600 $(ORACLE_HOME)/bin/expdpO )
	-mv $(ORACLE_HOME)/rdbms/lib/expdp $(ORACLE_HOME)/bin/expdp
	-chmod 751 $(ORACLE_HOME)/bin/expdp

iimpdp: $(IMPDP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/impdp || (\
	   mv -f $(ORACLE_HOME)/bin/impdp  $(ORACLE_HOME)/bin/impdpO &&\
	   chmod 600 $(ORACLE_HOME)/bin/impdpO )
	-mv $(ORACLE_HOME)/rdbms/lib/impdp $(ORACLE_HOME)/bin/impdp
	-chmod 751 $(ORACLE_HOME)/bin/impdp

isqlldr: $(SQLLDR)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/sqlldr || (\
	   mv -f $(ORACLE_HOME)/bin/sqlldr $(ORACLE_HOME)/bin/sqlldrO &&\
	   chmod 600 $(ORACLE_HOME)/bin/sqlldrO )
	-mv $(ORACLE_HOME)/rdbms/lib/sqlldr $(ORACLE_HOME)/bin/sqlldr
	-chmod 751 $(ORACLE_HOME)/bin/sqlldr

itkprof: $(TKPROF)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/tkprof || (\
	   mv -f $(ORACLE_HOME)/bin/tkprof $(ORACLE_HOME)/bin/tkprofO &&\
	   chmod 600 $(ORACLE_HOME)/bin/tkprofO )
	-mv $(ORACLE_HOME)/rdbms/lib/tkprof $(ORACLE_HOME)/bin/tkprof
	-chmod 751 $(ORACLE_HOME)/bin/tkprof

iplshprof: $(PLSHPROF)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/plshprof || (\
	   mv -f $(ORACLE_HOME)/bin/plshprof $(ORACLE_HOME)/bin/plshprofO &&\
	   chmod 600 $(ORACLE_HOME)/bin/plshprofO )
	-mv $(ORACLE_HOME)/rdbms/lib/plshprof $(ORACLE_HOME)/bin/plshprof
	-chmod 751 $(ORACLE_HOME)/bin/plshprof

irman: $(RMAN)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/rman || (\
	   mv -f $(ORACLE_HOME)/bin/rman $(ORACLE_HOME)/bin/rmanO &&\
	   chmod 600 $(ORACLE_HOME)/bin/rmanO )
	-mv $(ORACLE_HOME)/rdbms/lib/rman $(ORACLE_HOME)/bin/rman
	-chmod 751 $(ORACLE_HOME)/bin/rman

iorion: $(ORION)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/orion || (\
	   mv -f $(ORACLE_HOME)/bin/orion $(ORACLE_HOME)/bin/orionO &&\
	   chmod 600 $(ORACLE_HOME)/bin/orionO )
	-mv $(ORACLE_HOME)/rdbms/lib/orion $(ORACLE_HOME)/bin/orion
	-chmod 751 $(ORACLE_HOME)/bin/orion

idumpsga: $(DUMPSGA)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/dumpsga || (\
	   mv -f $(ORACLE_HOME)/bin/dumpsga $(ORACLE_HOME)/bin/dumpsga0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/dumpsga0 )
	-mv $(ORACLE_HOME)/rdbms/lib/dumpsga $(ORACLE_HOME)/bin/dumpsga
	-chmod 751 $(ORACLE_HOME)/bin/dumpsga

imapsga: $(MAPSGA)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/mapsga || (\
	   mv -f $(ORACLE_HOME)/bin/mapsga $(ORACLE_HOME)/bin/mapsga0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/mapsga0 )
	-mv $(ORACLE_HOME)/rdbms/lib/mapsga $(ORACLE_HOME)/bin/mapsga
	-chmod 751 $(ORACLE_HOME)/bin/mapsga

isysresv: $(SYSRESVER)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/sysresv || (\
	   mv -f $(ORACLE_HOME)/bin/sysresv $(ORACLE_HOME)/bin/sysresv0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/sysresv0 )
	-mv $(ORACLE_HOME)/rdbms/lib/sysresv $(ORACLE_HOME)/bin/sysresv
	-chmod 751 $(ORACLE_HOME)/bin/sysresv
     
ikgmgr: $(KGMGR)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/kgmgr || (\
	   mv -f $(ORACLE_HOME)/bin/kgmgr $(ORACLE_HOME)/bin/kgmgrO &&\
	   chmod 600 $(ORACLE_HOME)/bin/kgmgrO )
	-mv $(ORACLE_HOME)/rdbms/lib/kgmgr $(ORACLE_HOME)/bin/kgmgr
	-chmod 751 $(ORACLE_HOME)/bin/kgmgr

iloadpsp: $(LOADPSP)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/loadpsp || (\
	   mv -f $(ORACLE_HOME)/bin/loadpsp $(ORACLE_HOME)/bin/loadpspO &&\
	   chmod 600 $(ORACLE_HOME)/bin/loadpspO )
	-mv $(ORACLE_HOME)/rdbms/lib/loadpsp $(ORACLE_HOME)/bin/loadpsp
	-chmod 751 $(ORACLE_HOME)/bin/loadpsp

inid: $(NID)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/nid || (\
	   mv -f $(ORACLE_HOME)/bin/nid $(ORACLE_HOME)/bin/nidO &&\
	   chmod 600 $(ORACLE_HOME)/bin/nidO )
	-mv $(ORACLE_HOME)/rdbms/lib/nid $(ORACLE_HOME)/bin/nid
	-chmod 751 $(ORACLE_HOME)/bin/nid

igenezi: $(GENEZI)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF) || (\
	   mv -f $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF) $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF)O &&\
	   chmod 600 $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF)O )
	-mv $(ORACLE_HOME)/rdbms/lib/genezi $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF)
	-chmod 751 $(ORACLE_HOME)/bin/genezi$(HYBRID_IC_SUF)

igenlibociei:	$(LIBOCIEI)
	-$(NOT_EXIST) $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) || (\
	   mv -f $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) \
$(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)O &&\
	  chmod 600 $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)O )
	-mv $(ORACLE_HOME)/rdbms/install/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)
	-rm -f $(WRC)
	-rm -f $(ADRCI)

igenlibociicus:	$(LIBLIGHTOCIEI)
	-$(NOT_EXIST) $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) || (\
	   mv -f $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)O &&\
	   chmod 600 $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)O )
	-mv $(ORACLE_HOME)/rdbms/install/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)
	-rm -f $(WRC)
	-rm -f $(ADRCI)

igenliboci:	$(LIBOCIEI) $(LIBLIGHTOCIEI) 
	-$(NOT_EXIST) $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) || (\
	   mv -f $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)O &&\
	   chmod 600 $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)O )
	-mv $(ORACLE_HOME)/rdbms/install/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/light/libociicus.$(SO_EXT)
	-$(NOT_EXIST) $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) || (\
	   mv -f $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)O &&\
	   chmod 600 $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)O )
	-mv $(ORACLE_HOME)/rdbms/install/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT) \
	     $(ORACLE_HOME)/instantclient$(HYBRID_IC_SUF)/libociei.$(SO_EXT)
	-rm -f $(WRC)
	-rm -f $(ADRCI)

ic_basic_zip:  $(PACKAGE_BASIC)

ic_basiclite_zip:  $(PACKAGE_BASICLITE)

ic_jdbc_zip:  $(PACKAGE_JDBC)

ic_odbc_zip:  $(PACKAGE_ODBC)

ic_sqlplus_zip:  $(PACKAGE_SQLPLUS)

ic_tools_zip:  $(PACKAGE_TOOLS)

ic_all_zip:	ic_basic_zip ic_basiclite_zip ic_jdbc_zip ic_odbc_zip \
	ic_sqlplus_zip ic_tools_zip

ilibociei:	ic_all_zip

singletask: iimpst isqlldrst

iexpst: expst
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/expst || (\
	   mv -f $(ORACLE_HOME)/bin/expst $(ORACLE_HOME)/bin/expstO &&\
	   chmod 600 $(ORACLE_HOME)/bin/expstO )
	-mv $(ORACLE_HOME)/rdbms/lib/expst $(ORACLE_HOME)/bin/expst
	-chmod 751 $(ORACLE_HOME)/bin/expst

iimpst: impst
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/impst || (\
	   mv -f $(ORACLE_HOME)/bin/impst $(ORACLE_HOME)/bin/impstO &&\
	   chmod 600 $(ORACLE_HOME)/bin/impstO )
	-mv $(ORACLE_HOME)/rdbms/lib/impst $(ORACLE_HOME)/bin/impst
	-chmod 751 $(ORACLE_HOME)/bin/impst

isqlldrst: sqlldrst
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/sqlldrst || (\
	   mv -f $(ORACLE_HOME)/bin/sqlldrst $(ORACLE_HOME)/bin/sqlldrstO &&\
	   chmod 600 $(ORACLE_HOME)/bin/sqlldrstO )
	-mv $(ORACLE_HOME)/rdbms/lib/sqlldrst $(ORACLE_HOME)/bin/sqlldrst
	-chmod 751 $(ORACLE_HOME)/bin/sqlldrst

expst: $(EXPMAI) $(DEF_OPT) $(SSDBED)
	$(SILENT)$(ECHO) " - Linking Singletask Export utility (exp)"
	$(LINK) $(EXPMAI) $(SSDBED) $(DEF_OPT) $(LLIBDBTOOLS) $(LINKSTLIBS)

impst: $(IMPMAI) $(DEF_OPT) $(SSDBED)
	$(SILENT)$(ECHO) " - Linking Singletask Import utility (imp)"
	$(LINK) $(IMPMAI) $(SSDBED) $(DEF_OPT) $(LLIBDBTOOLS) $(LINKSTLIBS)

sqlldrst: $(LDRMAI) $(DEF_OPT) $(SSDBED)
	$(SILENT)$(ECHO) " - Linking Singletask SQL*Loader utility (sqlldr)"
	$(LINK) $(LDRMAI) $(SSDBED) $(DEF_OPT) \
	$(RDBMSLIB)$(LIL_OFF) $(LLIBDBTOOLS) $(LINKSTLIBS)

idgmgrl: $(RFSMGRL)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/dgmgrl || (\
	   mv -f $(ORACLE_HOME)/bin/dgmgrl $(ORACLE_HOME)/bin/dgmgrlO &&\
	   chmod 600 $(ORACLE_HOME)/bin/dgmgrlO )
	-mv $(ORACLE_HOME)/rdbms/lib/dgmgrl $(ORACLE_HOME)/bin/dgmgrl
	-chmod 751 $(ORACLE_HOME)/bin/dgmgrl

iextjobo: $(EXTJOBO)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/extjobo || (\
	   mv -f $(ORACLE_HOME)/bin/extjobo $(ORACLE_HOME)/bin/extjoboO &&\
	   chmod 600 $(ORACLE_HOME)/bin/extjoboO )
	-mv $(ORACLE_HOME)/rdbms/lib/extjobo $(ORACLE_HOME)/bin/extjobo
	-chmod 700 $(ORACLE_HOME)/bin/extjobo

iextjob: $(EXTJOB)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/extjob || (\
	   mv -f $(ORACLE_HOME)/bin/extjob $(ORACLE_HOME)/bin/extjobO &&\
	   chmod 600 $(ORACLE_HOME)/bin/extjobO )
	-mv $(ORACLE_HOME)/rdbms/lib/extjob $(ORACLE_HOME)/bin/extjob

ijssu: $(JSSU)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/jssu || (\
	   mv -f $(ORACLE_HOME)/bin/jssu $(ORACLE_HOME)/bin/jssuO &&\
	   chmod 600 $(ORACLE_HOME)/bin/jssuO )
	-mv $(ORACLE_HOME)/rdbms/lib/jssu $(ORACLE_HOME)/bin/jssu

ikfod: $(KFOD)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/kfod.bin || (\
	   mv -f $(ORACLE_HOME)/bin/kfod.bin $(ORACLE_HOME)/bin/kfodO &&\
	   chmod 600 $(ORACLE_HOME)/bin/kfodO )
	-mv $(ORACLE_HOME)/rdbms/lib/kfod $(ORACLE_HOME)/bin/kfod.bin
	-chmod 751 $(ORACLE_HOME)/bin/kfod.bin

ikfed: $(KFED)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/kfed || (\
	   mv -f $(ORACLE_HOME)/bin/kfed $(ORACLE_HOME)/bin/kfedO &&\
	   chmod 600 $(ORACLE_HOME)/bin/kfedO )
	-mv $(ORACLE_HOME)/rdbms/lib/kfed $(ORACLE_HOME)/bin/kfed
	-chmod 751 $(ORACLE_HOME)/bin/kfed

iamdu: $(AMDU)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/amdu || (\
	   mv -f $(ORACLE_HOME)/bin/amdu $(ORACLE_HOME)/bin/amduO &&\
	   chmod 600 $(ORACLE_HOME)/bin/amduO )
	-mv $(ORACLE_HOME)/rdbms/lib/amdu $(ORACLE_HOME)/bin/amdu
	-chmod 751 $(ORACLE_HOME)/bin/amdu

isetasmgid: $(SETASMGID)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/setasmgid || (\
	   mv -f $(ORACLE_HOME)/bin/setasmgid $(ORACLE_HOME)/bin/setasmgid0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/setasmgid0 )
	-mv $(ORACLE_HOME)/rdbms/lib/setasmgid $(ORACLE_HOME)/bin/setasmgid
	-chmod 751 $(ORACLE_HOME)/bin/setasmgid

irenamedg: $(KFNDG)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/renamedg || (\
	   mv -f $(ORACLE_HOME)/bin/renamedg $(ORACLE_HOME)/bin/renamedg0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/renamedg0 )
	-mv $(ORACLE_HOME)/rdbms/lib/renamedg $(ORACLE_HOME)/bin/renamedg
	-chmod 751 $(ORACLE_HOME)/bin/renamedg


iwrc: $(WRC)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/wrc || (\
	   mv -f $(ORACLE_HOME)/bin/wrc $(ORACLE_HOME)/bin/wrcO &&\
	   chmod 600 $(ORACLE_HOME)/bin/wrcO )
	-mv $(ORACLE_HOME)/rdbms/lib/wrc $(ORACLE_HOME)/bin/wrc
	-chmod 751 $(ORACLE_HOME)/bin/wrc

iadrci: $(ADRCI)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/adrci || (\
	   mv -f $(ORACLE_HOME)/bin/adrci $(ORACLE_HOME)/bin/adrciO &&\
	   chmod 600 $(ORACLE_HOME)/bin/adrciO )
	-mv $(ORACLE_HOME)/rdbms/lib/adrci $(ORACLE_HOME)/bin/adrci
	-chmod 751 $(ORACLE_HOME)/bin/adrci

iuidrvci: $(UIDRVCI)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/uidrvci || (\
	   mv -f $(ORACLE_HOME)/bin/uidrvci $(ORACLE_HOME)/bin/uidrvciO &&\
	   chmod 600 $(ORACLE_HOME)/bin/uidrvciO )
	-mv $(ORACLE_HOME)/rdbms/lib/uidrvci $(ORACLE_HOME)/bin/uidrvci
	-chmod 751 $(ORACLE_HOME)/bin/uidrvci

imkpatch: $(MKPATCH)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/mkpatch || (\
	   mv -f $(ORACLE_HOME)/bin/mkpatch $(ORACLE_HOME)/bin/mkpatchO &&\
	   chmod 600 $(ORACLE_HOME)/bin/mkpatchO )
	-mv $(ORACLE_HOME)/rdbms/lib/mkpatch $(ORACLE_HOME)/bin/mkpatch
	-chmod 751 $(ORACLE_HOME)/bin/mkpatch

ioputil: $(OPUTIL)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/oputil || (\
	  mv -f $(ORACLE_HOME)/bin/oputil $(ORACLE_HOME)/bin/oputilO &&\
	   chmod 600 $(ORACLE_HOME)/bin/oputilO )
	-mv $(ORACLE_HOME)/rdbms/lib/oputil $(ORACLE_HOME)/bin/oputil
	-chmod 751 $(ORACLE_HOME)/bin/oputil

iskgxpinfo: $(SKGXPINFO)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/skgxpinfo || (\
	   mv -f $(ORACLE_HOME)/bin/skgxpinfo $(ORACLE_HOME)/bin/skgxpinfoO &&\
	   chmod 600 $(ORACLE_HOME)/bin/skgxpinfoO )
	-mv $(ORACLE_HOME)/rdbms/lib/skgxpinfo $(ORACLE_HOME)/bin/skgxpinfo
	-chmod 751 $(ORACLE_HOME)/bin/skgxpinfo

itrcldr: $(TRCLDR)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/trcldr || (\
	   mv -f $(ORACLE_HOME)/bin/trcldr $(ORACLE_HOME)/bin/trcldr0 &&\
	   chmod 600 $(ORACLE_HOME)/bin/trcldr0 )
	-mv $(ORACLE_HOME)/rdbms/lib/trcldr $(ORACLE_HOME)/bin/trcldr
	-chmod 751 $(ORACLE_HOME)/bin/trcldr

idrdactl: $(DPSADCTL)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/drdactl || (\
	   mv -f $(ORACLE_HOME)/bin/drdactl $(ORACLE_HOME)/bin/drdactlO &&\
	   chmod 600 $(ORACLE_HOME)/bin/drdactlO )
	-mv $(ORACLE_HOME)/rdbms/lib/drdactl $(ORACLE_HOME)/bin/drdactl
	-chmod 751 $(ORACLE_HOME)/bin/drdactl

idrdalsnr: $(DPSADLSNR)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/drdalsnr || (\
	   mv -f $(ORACLE_HOME)/bin/drdalsnr $(ORACLE_HOME)/bin/drdalsnrO &&\
	   chmod 600 $(ORACLE_HOME)/bin/drdalsnrO )
	-mv $(ORACLE_HOME)/rdbms/lib/drdalsnr $(ORACLE_HOME)/bin/drdalsnr
	-chmod 751 $(ORACLE_HOME)/bin/drdalsnr

idrdaproc: $(DPSADPROC)
	-$(NOT_EXIST) $(ORACLE_HOME)/bin/drdaproc || (\
	   mv -f $(ORACLE_HOME)/bin/drdaproc $(ORACLE_HOME)/bin/drdaprocO &&\
	   chmod 600 $(ORACLE_HOME)/bin/drdaprocO )
	-mv $(ORACLE_HOME)/rdbms/lib/drdaproc $(ORACLE_HOME)/bin/drdaproc
	-chmod 751 $(ORACLE_HOME)/bin/drdaproc

ioratop: $(ORATOP)
	-$(NOT_EXIST) $(ORACLE_HOME)/suptools/oratop/oratop || (\
	   mv -f $(ORACLE_HOME)/suptools/oratop/oratop \
	     $(ORACLE_HOME)/suptools/oratop/oratopO &&\
	   chmod 600 $(ORACLE_HOME)/suptools/oratop/oratopO )
	-mv $(ORACLE_HOME)/rdbms/lib/oratop \
	$(ORACLE_HOME)/suptools/oratop/oratop
	-chmod 751 $(ORACLE_HOME)/suptools/oratop/oratop

preinstall:
	-chmod 755 $(ORACLE_HOME)/bin

install_srvm: $(CONFIG)
	$(CD) $(ORACLE_HOME)/srvm/lib; \
	$(MAKE) -f $(ORACLE_HOME)/srvm/lib/ins_srvm.mk install_srvm

install: preinstall $(INSTALL_TARGS) ioracle

crs_install: $(CRS_INSTALL_TARGS)

all_no_orcl: preinstall $(INSTALL_TARGS)

clean:
	-rm -f $(ALL_EXECS) $(RDBMSLIB)ksms.s $(RDBMSLIB)ksms.o

mk_softlinks:
	$(LNS) $(LIBCLIENT) $(LOC_LIBCLIENTSH)
	$(LNS) $(LIBCOMMON) $(LOC_LIBCOMMONSH)
	$(LNS) $(LIBGENERIC) $(LOC_LIBGENERICSH)
	$(LNS) $(LIBMM) $(LOC_LIBMMSH)
	$(LNS) $(LIBVSN) $(LOC_LIBVSNSH)
	$(LNS) $(LIBNNET) $(LOC_LIBNNETSH)
	$(LNS) $(LOC_SHLIBCLIENTSH) $(LIBCLIENTSH)
	$(LNS) $(LOC_SHLIBCOMMONSH) $(LIBCOMMONSH)
	$(LNS) $(LOC_SHLIBGENERICSH) $(LIBGENERICSH)
	$(LNS) $(LOC_SHLIBMMSH) $(LIBMMSH)
	$(LNS) $(LOC_SHLIBVSNSH) $(LIBVSNSH)
	$(LNS) $(LOC_SHLIBNNETSH) $(LIBNNETSH)

javavm_setup_default_jdk:
	perl $(ORACLE_HOME)/javavm/install/update_javavm_binaries.pl -install

javavm_refresh:
	perl $(ORACLE_HOME)/javavm/install/update_javavm_binaries.pl -refresh

libshpk:
	$(MAKE) -f $(MAKEFILE) $(LIBSHPK_OHSO)

ver_update:
	$(SILENT)$(ECHO) "Compatibility Target Only - Nothing to be done here"
ver_update_dbcs:
	$(SILENT)$(ECHO) "Compatibility Target Only - Nothing to be done here"

edition_corestandard:
	$(SILENT)$(ECHO) "Deploying Oracle Database Core Standard Edition"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNCSE) $(LIBVSN)
edition_coreenterprise:
	$(SILENT)$(ECHO) "Deploying Oracle Database Core Enterprise Edition"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNCEE) $(LIBVSN)
edition_standard:
	$(SILENT)$(ECHO) "Deploying Oracle Database Standard Edition"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNSE) $(LIBVSN)
edition_enterprise:
	$(SILENT)$(ECHO) "Deploying Oracle Database Enterprise Edition"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNEE) $(LIBVSN)
edition_highperf:
	$(SILENT)$(ECHO) "Deploying Oracle Database Enterprise Edition High Performance"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNHP) $(LIBVSN)
edition_extremeperf:
	$(SILENT)$(ECHO) "Deploying Oracle Database Enterprise Edition Extreme Performance"
	$(SILENT)$(ECHODO) $(MVF) $(LIBVSN) $(LIBVSNBACKUP)
	$(SILENT)$(ECHODO) $(CP) $(LIBVSNXP) $(LIBVSN)

# Exiting SRCHOME/rdbms/install/cus_rdbms.mk
# Entering link.mk

rac_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(RAC_ON) $(SKGXP_RAC_ON) $(SKGXN_RAC_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(RAC_OFF) > /dev/null ; \
  then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(RAC_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(RAC_ON) $(RANLIBL)

rac_off: rac_off_$(S_RAC_OFF) 

rac_off_:$(KNLOPT_LOCAL) $(RDBMSLIB)$(RAC_OFF) $(SKGXP_DEFAULT) $(SKGXN_DEFAULT) 
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(RAC_ON) > /dev/null ; \
  then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(RAC_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(RAC_OFF) $(RANLIBL)

asm_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(ASM_ON) 
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(ASM_OFF) > /dev/null ; \
  then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(ASM_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(ASM_ON) $(RANLIBL)

asm_off: asm_off_$(S_ASM_OFF)

asm_off_:$(KNLOPT_LOCAL) $(RDBMSLIB)$(ASM_OFF) 
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(ASM_ON) > /dev/null ; \
  then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(ASM_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(ASM_OFF) $(RANLIBL)


ops_on: rac_on

ops_off:rac_off

dnfs_on:
	$(SILENT)if [ ! -f $(RDBMSLIB)odm ]; \
    then \
      $(MKDIRP) $(RDBMSLIB)odm; \
	fi
	$(RMF) $(RDBMSLIB)odm/$(LIB_PREFIX)nfsodm$(RDBMS_VERSION).$(SO_EXT); \
    $(CPODM_DNFS)

dnfs_off:
	$(RMF)  $(RDBMSLIB)odm/$(LIB_PREFIX)nfsodm$(RDBMS_VERSION).$(SO_EXT)
    

sage_on:
	$(SILENT)$(ECHO) "sage_on is no longer needed"

sage_off:
	$(SILENT)$(ECHO) "sage_off is no longer needed"

sdo_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(SDO_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(SDO_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(SDO_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(SDO_ON) $(RANLIBL)

lbac_on:
	$(SILENT)$(ECHO) "lbac_on has been deprecated"

lbac_off:
	$(SILENT)$(ECHO) "lbac_off has been deprecated"

dv_on:
	$(SILENT)$(ECHO) "dv_on has been deprecated"

dv_off:
	$(SILENT)$(ECHO) "dv_off has been deprecated"

uniaud_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(UNIAUD_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(UNIAUD_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(UNIAUD_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(UNIAUD_ON) $(RANLIBL)

uniaud_off: $(KNLOPT_LOCAL) $(RDBMSLIB)$(UNIAUD_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(UNIAUD_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(UNIAUD_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(UNIAUD_OFF) $(RANLIBL)


sdo_off: sdo_warn sdo_on
sdo_warn:
	$(SILENT)$(ECHO) Warning: sdo is always turned on. sdo_off is disabled.

sdo_off_real:  $(KNLOPT_LOCAL) $(RDBMSLIB)$(SDO_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(SDO_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(SDO_ON) ; \
        fi
	 $(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(SDO_OFF) $(RANLIBL)

ctx_on:	$(KNLOPT_LOCAL) $(RDBMSLIB)$(CTX_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(CTX_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(CTX_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(CTX_ON) $(RANLIBL)

ctx_off:
	$(SILENT)$(ECHO) Warning: ctx is always turned on. ctx_off is disabled.

olap_on:	$(KNLOPT_LOCAL) $(RDBMSLIB)$(OLAP_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(OLAP_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(OLAP_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(OLAP_ON) $(RANLIBL)

olap_off: $(KNLOPT_LOCAL) $(RDBMSLIB)$(OLAP_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(OLAP_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(OLAP_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(OLAP_OFF) $(RANLIBL)	

part_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(PART_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(PART_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(PART_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(PART_ON) $(RANLIBL)

part_off: part_off_$(S_PART_OFF) 

part_off_: $(KNLOPT_LOCAL) $(RDBMSLIB)$(PART_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(PART_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(PART_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(PART_OFF) $(RANLIBL)

dm_on:	$(KNLOPT_LOCAL) $(RDBMSLIB)$(DM_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(DM_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(DM_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(DM_ON) $(RANLIBL)

dm_off: $(KNLOPT_LOCAL) $(RDBMSLIB)$(DM_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(DM_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(DM_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(DM_OFF) $(RANLIBL)

rat_on:	$(KNLOPT_LOCAL) $(RDBMSLIB)$(RAT_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(RAT_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(RAT_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(RAT_ON) $(RANLIBL)

rat_off: rat_off_$(S_RAT_OFF) 

rat_off_: $(KNLOPT_LOCAL) $(RDBMSLIB)$(RAT_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(RAT_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(RAT_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(RAT_OFF) $(RANLIBL)

jox_on: $(JOX_ON_ACTUAL)

jox_on_static: $(KNLOPT_LOCAL) $(RDBMSLIB)$(JOX_OFILE)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(JOXOFF_OFILE) > /dev/null; then \
               $(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(JOXOFF_OFILE) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(JOX_OFILE) $(RANLIBL)

jox_off: $(JOX_OFF_ACTUAL)

jox_off_static: $(KNLOPT_LOCAL) $(RDBMSLIB)$(JOXOFF_OFILE)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(JOX_OFILE) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(JOX_OFILE) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(JOXOFF_OFILE) $(RANLIBL)

cloud_on: $(KNLOPT_LOCAL) $(RDBMSLIB)$(CLOUD_ON)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(CLOUD_OFF) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(CLOUD_OFF) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(CLOUD_ON) $(RANLIBL)

cloud_off: $(KNLOPT_LOCAL) $(RDBMSLIB)$(CLOUD_OFF)
	$(SILENT)if $(ARPRINT) $(LIBKNLOPT) | $(GREP) '^'$(CLOUD_ON) > /dev/null ; then \
		$(ECHODO) $(ARDELETE) $(LIBKNLOPT) $(CLOUD_ON) ; \
	fi
	$(ARCREATE) $(LIBKNLOPT) $(RDBMSLIB)$(CLOUD_OFF) $(RANLIBL)




$(ORACLE): $(ALWAYS) $(ORACLE_DEPS) $(INS_CONFIG) $(RDBMS_COLLECT) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle "
	$(RMF) $@
	$(ORACLE_LINKLINE)

$(IMP) : $(ALWAYS) $(IMP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Import utility (imp)"
	$(RMF) $@
	$(IMP_LINKLINE)

$(EXP) : $(ALWAYS) $(EXP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Export utility (exp)"
	$(RMF) $@
	$(EXP_LINKLINE)

$(EXPDP) : $(ALWAYS) $(EXPDP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Datapump Export utility (expdp)"
	$(RMF) $@
	$(EXPDP_LINKLINE)

$(DBFS_CLIENT) : $(ALWAYS) $(CDF_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking dbfs_client"
	$(RMF) $@
	$(CDF_LINKLINE)

$(IMPDP) : $(ALWAYS) $(IMPDP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Datapump Import utility (impdp)"
	$(RMF) $@
	$(IMPDP_LINKLINE)

$(SQLLDR) : $(ALWAYS) $(SQLLDR_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking SQL*Loader utility (sqlldr)"
	$(RMF) $@
	$(LDR_LINKLINE)

$(SQLLDR_LIL) : $(ALWAYS) $(SQLLIL_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking SQL*Loader utility (sqlldr)"
	$(RMF) $@
	$(LIL_LINKLINE)

$(MIG) : $(ALWAYS) $(MIG_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking Migration utility (mig)"
	$(RMF) $@
	$(MIG_LINKLINE)

$(DBVERIFY) : $(ALWAYS) $(DBVERIFY_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking DB*Verify utility (dbv)"
	$(RMF) $@
	$(DBV_LINKLINE)

$(DISKMON) : $(ALWAYS) $(DISKMON_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking I/O fencing daemon (diskmon)"
	$(RMF) $@
	$(DISKMON_LINKLINE)

$(DBGRMTD) : $(ALWAYS) $(DBGRMTD_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking dbgrmtd (AMS Test Driver)"
	$(RMF) $@
	$(DBGRMTD_LINKLINE)

$(ORION) : $(ALWAYS) $(ORION_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking ORacle IO Numbers benchmark (orion)"
	$(RMF) $@
	$(ORION_LINKLINE)

$(TSTSHM) : $(ALWAYS) $(TSTSHM_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking shared memory test utility (tstshm)"
	$(RMF) $@
	$(TSTSHM_LINKLINE)

$(MAXMEM) : $(ALWAYS) $(MAXMEM_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking max memory test utility (maxmem)"
	$(RMF) $@
	$(MAXMEM_LINKLINE)

$(ORAPWD) : $(ALWAYS) $(ORAPWD_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking password utility (orapwd)"
	$(RMF) $@
	$(ORAPWD_LINKLINE) -lnnz12

$(TKPROF) : $(ALWAYS) $(TKPROF_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking performance trace utility (tkprof)"
	$(RMF) $@
	$(TKPROF_LINKLINE)

$(SYSRESVER) : $(ALWAYS) $(SYSRESVER_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking System Resource Verifier (sysresv)"
	$(RMF) $@
	$(SYSRESVER_LINKLINE)

$(PLSHPROF) : $(ALWAYS) $(PLSHPROF_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking hierarchical profiler utility (plshprof)"
	$(RMF) $@
	$(PLSHPROF_LINKLINE) -lons

$(DBFSIZE) : $(ALWAYS) $(DBFSIZE_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking database file size utility (dbfsize)"
	$(RMF) $@
	$(DBFSIZE_LINKLINE)

$(CURSIZE) : $(ALWAYS) $(CURSIZE_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking cursor size utility (cursize)"
	$(RMF) $@
	$(CURSIZE_LINKLINE)

$(RMAN) : $(ALWAYS) $(RMAN_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking recovery manager (rman)"
	$(RMF) $@
	$(RMAN_LINKLINE)


$(TDSCOMP) : $(ALWAYS) $(TDSCOMP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking TDS compiler (tdscomp)"
	$(RMF) $@
	$(TDSCOMP_LINKLINE)

$(EXTPROC): $(ALWAYS) $(EXTPROC_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking external procedure agent ($@)"
	$(RMF) $@
	$(EXTPROC_LINKLINE) -lagtsh

extproc32:
	$(MAKE) -f $(LINKMAKEFILE) $(EXTPROC32) EXTPROC=$(EXTPROC32) $(REDEFINES32)

$(AGTCTL): $(ALWAYS) $(AGTCTL_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Agent Control Utility"
	$(RMF) $@
	$(AGTCTL_LINKLINE)

$(HSALLOCI): $(ALWAYS) $(HSALLOCI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking HS ORACLE/OCI agent"
	$(RMF) $@
	$(HSALLOCI_LINKLINE)

$(HSDEPXA) : $(ALWAYS) $(HSDEPXA_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking HS Distributed External Procedure agent"
	$(RMF) $@
	$(HSDEPXA_LINKLINE)

$(HSOTS) : $(ALWAYS) $(HSOTS_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking HS OTS agent"
	$(RMF) $@
	$(HSOTS_LINKLINE) -lagtsh

$(HSODBC) : $(ALWAYS) $(HSODBC_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(HSDG4)odbc agent"
	$(RMF) $@
	$(HSODBC_LINKLINE)

dg4odbc32 hsodbc32:
	$(MAKE) -f $(LINKMAKEFILE) $(HSODBC) $(REDEFINES32)

$(TG4DB2) : $(ALWAYS) $(TG4DB2_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)db2 (DB2) agent"
	$(RMF) $@
	$(TG4DB2_LINKLINE)

dg4db232 tg4db232:
	$(MAKE) -f $(LINKMAKEFILE) $(TG4DB2) $(REDEFINES32)

$(TG4IFMX) : $(ALWAYS) $(TG4IFMX_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)ifmx (Informix) agent"
	$(RMF) $@
	$(TG4IFMX_LINKLINE)

dg4ifmx32 tg4ifmx32:
	$(MAKE) -f $(LINKMAKEFILE) $(TG4IFMX) $(REDEFINES32)

$(TG4MSQL) : $(ALWAYS) $(TG4MSQL_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)msql (Microsoft SQL Server) agent"
	$(RMF) $@
	$(TG4MSQL_LINKLINE)

dg4msql32 tg4msql32:
	$(MAKE) -f $(LINKMAKEFILE) $(TG4MSQL) $(REDEFINES32)

$(TG4SYBS) : $(ALWAYS) $(TG4SYBS_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)sybs (Sybase) agent"
	$(RMF) $@
	$(TG4SYBS_LINKLINE)

dg4sybs32 tg4sybs32:
	$(MAKE) -f $(LINKMAKEFILE) $(TG4SYBS) $(REDEFINES32)

$(TG4TERA) : $(ALWAYS) $(TG4TERA_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)tera (Teradata) agent"
	$(RMF) $@
	$(TG4TERA_LINKLINE)

dg4tera32 tg4tera32:
	$(MAKE) -f $(LINKMAKEFILE) $(TG4TERA) $(REDEFINES32)

$(TG4PWD) : $(ALWAYS) $(TG4PWD_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking $(TG4DG4)pwd utility"
	$(RMF) $@
	$(TG4PWD_LINKLINE) -lnnz12

$(HGOHSCC) : $(ALWAYS) $(HGOHSCC_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking hgohscc utility"
	$(RMF) $@
	$(HGOHSCC_LINKLINE)

libhgotrace32:
	$(MAKE) -f $(LINKMAKEFILE) $(LIBHGOTRACE) $(REDEFINES32)

$(ARCHMON) : $(ALWAYS) $(ARCHMON_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking archmon utility (archmon)"
	$(RMF) $@
	$(ARCHMON_LINKLINE)

$(OSH) : $(ALWAYS) $(OSH_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking osh utility (osh)"	
	$(RMF) $@
	$(OSH_LINKLINE)

$(BBED): $(ALWAYS) $(BBED_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking BBED utility (bbed)"
	$(RMF) $@
	$(BBED_LINKLINE)

$(SBTTEST): $(ALWAYS) $(SBTTEST_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking SBTTEST utility (sbttest)"
	$(RMF) $@
	$(SBTTEST_LINKLINE)

$(KGMGR): $(ALWAYS) $(KGMGR_DEPS)
	$(SILENT)$(RMF) $@
	$(SILENT)$(ECHO) "Linking KGMGR (kgmgr)"
	$(KGMGR_LINKLINE)

$(LOADPSP): $(ALWAYS) $(LOADPSP_DEPS)
	$(SILENT)$(RMF) $@
	$(SILENT)$(ECHO) " - Linking PSP Loader utility (loadpsp)"
	$(LOADPSP_LINKLINE)

$(RFSMGRL): $(ALWAYS) $(RFSMGRL_DEPS)
	$(SILENT)$(RMF) $@
	$(SILENT)$(ECHO) " - Linking Data Guard Broker CLI (DGMGRL)"
	$(RFSMGRL_LINKLINE)

$(NID) : $(ALWAYS) $(NID_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking DB*Newid utility (nid)"
	$(RMF) $@
	$(NID_LINKLINE)

$(KFED): $(ALWAYS) $(KFED_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking KFED utility (kfed)"
	$(RMF) $@
	$(KFED_LINKLINE)

$(KFOD): $(ALWAYS) $(KFOD_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking OSM Discovery  utility (kfod)"
	$(RMF) $@
	$(KFOD_LINKLINE)

$(AMDU): $(ALWAYS) $(AMDU_DEPS) $(DEF_OPT)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking Dump ASM Metadata utility (amdu)"
	$(RMF) $@
	$(AMDU_LINKLINE)

$(SETASMGID): $(ALWAYS) $(SETASMGID_DEPS) $(CONFIG)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking ASM OS Group Setgid utility (setasmgid)"
	$(RMF) $@
	$(SETASMGID_LINKLINE)

$(KFNDG): $(ALWAYS) $(KFNDG_DEPS) $(DEF_OPT)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking ASM diskgroup renaming utility"
	$(RMF) $@
	$(KFNDG_LINKLINE)


$(ORATNT): $(ALWAYS) $(ORATNT_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking TNT parser (oratnt)"
	$(RMF) $@
	$(ORATNT_LINKLINE)

$(TRCLDR) : $(ALWAYS) $(TRCLDR_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linkg Trace Loader utility (trcldr)"
	$(RMF) $@
	$(TRCLDR_LINKLINE)

$(DUMPSGA) : $(ALWAYS) $(DUMPSGA_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking SGA Dump Utility (dumpsga)"
	$(RMF) $@
	$(MAYBE_ARX_KSMS)
	$(DUMPSGA_LINKLINE)

$(SYSCONF) : $(ALWAYS) $(SYSCONF_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking System Configuration Utility (sysconf) "
	$(RMF) $@
	$(SYSCONF_LINKLINE)

$(MAPSGA) : $(ALWAYS) $(MAPSGA_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking SGA Dump Utility (mapsga)"
	$(RMF) $@
	$(MAYBE_ARX_KSMS)
	$(MAPSGA_LINKLINE)

$(EXTJOB): $(ALWAYS) $(EXTJOB_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking external job exec ($@)"
	$(RMF) $@
	$(EXTJOB_LINKLINE)

$(EXTJOBO): $(ALWAYS) $(EXTJOBO_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking external oracle job exec ($@)"
	$(RMF) $@
	$(EXTJOBO_LINKLINE)

$(JSSU): $(ALWAYS) $(JSSU_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking job scheduler switch user exec ($@)"
	$(RMF) $@
	$(JSSU_LINKLINE)

$(GENEZI): $(ALWAYS) $(GENEZI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking OCI EZ-install Generator ($@)"
	$(RMF) $@
	$(GENEZI_LINKLINE)

$(ADRCI) : $(ALWAYS) $(ADRCI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linkg ADR viewer utility (adrci)"
	$(RMF) $@
	$(ADRCI_LINKLINE)

$(UIDRVCI) : $(ALWAYS) $(UIDRVCI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Diagfw EM UIDrv utility (uidrvci)"
	$(RMF) $@
	$(UIDRVCI_LINKLINE)

$(WRC): $(ALWAYS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking workload replay client (wrc)"
	$(RMF) $@
	$(WRC_LINKLINE)

$(MKPATCH) : $(ALWAYS) $(MKPATCH_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Online Patching utility (mkpatch)"
	$(RMF) $@
	$(MKPATCH_LINKLINE)

$(OPUTIL) : $(ALWAYS) $(OPUTIL_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Online Patching utility (oputil)"
	$(RMF) $@
	$(OPUTIL_LINKLINE)

$(DUMPPCH) : $(ALWAYS) $(DUMPPCH_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking hot patch dumping utility (dumppch)"
	$(RMF) $@
	$(DUMPPCH_LINKLINE)

$(ORABCP) : $(ALWAYS) $(ORABCP_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking binary compare utility (orabcp)"
	$(RMF) $@
	$(ORABCP_LINKLINE)

$(ODUMPOBJ) : $(ALWAYS) $(ODUMPOBJ_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Object Dump Utility (odumpobj)"
	$(RMF) $@
	$(ODUMPOBJ_LINKLINE)

$(ORADNFS) : $(ALWAYS) $(ORADNFS_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Direct NFS utility (oradnfs)"
	$(RMF) $@
	$(ORADNFS_LINKLINE)

$(DNFSTEST) : $(ALWAYS) $(DNFSTEST_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Direct NFS utility (dnfstest)"
	$(RMF) $@
	$(DNFSTEST_LINKLINE)

$(DNFSTEST_UT) : $(ALWAYS) $(DNFSTEST_UT_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Direct NFS utility (dnfstest_ut)"
	$(RMF) $@
	$(DNFSTEST_UT_LINKLINE)

$(DNFSTEST_THRDS) : $(ALWAYS) $(DNFSTEST_THRDS_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Direct NFS utility (dnfstest_thrds)"
	$(RMF) $@
	$(DNFSTEST_THRDS_LINKLINE)

$(SKGXPINFO) : $(ALWAYS) $(SKGXPINFO_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking SKGXP diagnostics utility (skgxpinfo)"
	$(RMF) $@
	$(SKGXPINFO_LINKLINE)

$(DPSADCTL): $(ALWAYS) $(DPSADCTL_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking DPS DRDA AS Control Utility ($@)"
	$(RMF) $@
	$(DPSADCTL_LINKLINE)

$(DPSADLSNR): $(ALWAYS) $(DPSADLSNR_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking DPS DRDA AS Listener ($@)"
	$(RMF) $@
	$(DPSADLSNR_LINKLINE)

$(DPSADPROC): $(ALWAYS) $(DPSADPROC_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking DPS DRDA AS Protocol Processor ($@)"
	$(RMF) $@
	$(DPSADPROC_LINKLINE)

$(DPSADDC): $(ALWAYS) $(DPSADDC_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking DPS DRDA AS DDM Compiler ($@)"
	$(RMF) $@
	$(DPSADDC_LINKLINE)

$(DPSADDFD): $(ALWAYS) $(DPSADDFD_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) "Linking DPS DRDA Data Flow Decoder ($@)"
	$(RMF) $@
	$(DPSADDFD_LINKLINE)

$(OCIEIMAI): $(OCIEISRC)
$(OCIEILIGHTMAI): $(OCIEILIGHTSRC)

$(OCIEISRC): $(FORCE_OCIEI)
	$(RMF) $(OCIEISRC)
	$(CD) $(ORACLE_HOME); \
	$(EXEC_GENEZI) -c "$(GENEZI_DIRS)" "$(GENEZI_PATS)" > $(OCIEISRC)

$(OCIEILIGHTSRC): $(FORCE_OCIEI)
	$(RMF) $(OCIEILIGHTSRC)
	$(CD) $(ORACLE_HOME); \
	$(EXEC_GENEZI) -c "$(GENEZI_LIGHT_DIRS)" "$(GENEZI_LIGHT_PATS)" "$(LIBLIGHTOCIEINAME)" > $(OCIEILIGHTSRC)

$(LIBOCIEI): $(FORCE_OCIEI) $(OCIEIMAI) $(LIBOCIEI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking OCI EZ Install Shared Library libociei"
	$(RMF) $@ $(OCIEILOG)
	$(LIBOCIEI_LINKLINE)
	$(LIBOCIEI_POPULATE)

$(LIBLIGHTOCIEI): $(FORCE_OCIEI) $(OCIEILIGHTMAI) $(LIBLIGHTOCIEI_DEPS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking OCI EZ Install Light Weight Shared Library"
	$(RMF) $@ $(OCIEILIGHTLOG)
	$(MKDIRP) $(OCIEILIGHTDIR)
	$(LIBLIGHTOCIEI_LINKLINE)
	$(LIBLIGHTOCIEI_POPULATE)

$(PACKAGE_BASIC): $(FORCE_OCIEI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging Basic"
	$(BUILD_LIBOCIEI_BASIC_ZIP)
	$(BUILD_LIBOCIEI_BASIC_RPM)

$(PACKAGE_BASICLITE): $(FORCE_OCIEI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging BasicLite"
	$(BUILD_LIBOCIEI_BASIC_LITE_ZIP)
	$(BUILD_LIBOCIEI_BASICLITE_RPM)

$(PACKAGE_JDBC): $(FORCE_OCIEI) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging JDBC"
	$(BUILD_LIBOCIEI_JDBC_ZIP)
	$(BUILD_LIBOCIEI_JDBC_RPM)

$(PACKAGE_ODBC): $(FORCE_OCIEI) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging ODBC"
	$(BUILD_LIBOCIEI_ODBC_ZIP)
	$(BUILD_LIBOCIEI_ODBC_RPM)

$(PACKAGE_PRECOMP): $(FORCE_OCIEI) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging PRECOMP"
	$(BUILD_LIBOCIEI_PRECOMP_ZIP)
	$(BUILD_LIBOCIEI_PRECOMP_RPM)

$(PACKAGE_SDK): $(FORCE_OCIEI) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging SDK"
	$(BUILD_LIBOCIEI_SDK_ZIP)
	$(BUILD_LIBOCIEI_SDK_RPM)

$(PACKAGE_SQLPLUS): $(FORCE_OCIEI) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging SQLPLUS"
	$(BUILD_LIBOCIEI_SQLPLUS_ZIP)
	$(BUILD_LIBOCIEI_SQLPLUS_RPM)

$(PACKAGE_TOOLS): $(FORCE_OCIEI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Packaging TOOLS"
	$(BUILD_LIBOCIEI_TOOLS_ZIP)
	$(BUILD_LIBOCIEI_TOOLS_RPM)

force_ociei:

$(OSBWSMAI): $(OSBWSSRC)
$(OSBWSSRC): $(FORCE_OSBWSIC)
	$(RMF) $(OSBWSSRC)
	$(CD) $(ORACLE_HOME); \
	$(EXEC_GENEZI) -c "$(GENEZI_OSBWS_DIRS)" "$(GENEZI_OSBWS_PATS)" "$(LIBOSBWSNAME)" > $(OSBWSSRC)


$(LIBOSBWSSO): $(ALWAYS) $(OSBWSMAI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking OSB Web Services Shared Library"
	$(RMF) $@ $(OSBWSLOG)
	$(LIBOSBWSSO_LINKLINE)
	$(LIBOSBWSSO_POPULATE)

force_osbwsic:

$(RAMAI): $(RASRC)
$(RASRC): $(FORCE_RAIC)
	$(RMF) $(RASRC)
	$(CD) $(ORACLE_HOME); \
	$(EXEC_GENEZI) -c "$(GENEZI_OSBWS_DIRS)" "$(GENEZI_OSBWS_PATS)" "$(LIBOSBWSNAME)" > $(RASRC)

$(LIBRASO): $(ALWAYS) $(RAMAI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Recovery Appliance Shared Library"
	$(RMF) $@ $(RALOG)
	$(LIBRASO_LINKLINE)
	$(LIBRASO_POPULATE)

force_raic:

$(OPCMAI): $(OPCSRC)
$(OPCSRC): $(FORCE_OPCIC)
	$(RMF) $(OPCSRC)
	$(CD) $(ORACLE_HOME); \
	$(EXEC_GENEZI) -c "$(GENEZI_OSBWS_DIRS)" "$(GENEZI_OSBWS_PATS)" "$(LIBOSBWSNAME)" > $(OPCSRC)

$(LIBOPCSO): $(ALWAYS) $(OPCMAI)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle Public Cloud Shared Library"
	$(RMF) $@ $(OPCLOG)
	$(LIBOPCSO_LINKLINE)
	$(LIBOPCSO_POPULATE)

force_opcic:

no_opts: $(NO_OPTS) jox_off
	$(RMF) $(LIBKNLOPT)
	$(ARCREATE) $(LIBKNLOPT) $(NO_OPTS) $(RANLIBL)


# Exiting link.mk
# Entering s_link.mk

$(PSTACK_SEARCH): $(ALWAYS) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle utility to search for call chains"
	$(RMF) $@
	$(PSTACK_SEARCH_LINKLINE)


$(ORATOP): $(ALWAYS)
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking oratop "
	$(RMF) $@
	$(ORATOP_LINKLINE)


$(TRANS_TRC): $(ALWAYS) 
	$(SILENT)$(ECHO)
	$(SILENT)$(ECHO) " - Linking Oracle utility translate hex short stacks"
	$(RMF) $@
	$(TRANS_TRC_LINKLINE)

# Exiting s_link.mk
