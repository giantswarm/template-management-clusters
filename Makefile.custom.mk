FLEET_MAKEFILE=https://raw.githubusercontent.com/giantswarm/management-cluster-bases/main/bases/tools/Makefile.custom.mk

.EXPORT_ALL_VARIABLES:
customer_codename = CUSTOMER_CODENAME

%::
	curl -sL $(FLEET_MAKEFILE) | $(MAKE) -f - $@
