define external_pdf_rule
$(subst vsd,pdf,$(notdir $1)) : $1
	$$(powershell) -ExecutionPolicy RemoteSigned -file $$(vsd2pdf) $$< $$@
endef

define external_pdf_name
external_vsdpdf += $(subst vsd,pdf,$(notdir $1))
endef

# # accumulate all external pdf figures
# external_vsd = ../strategy/inbound-only.vsd
# $(foreach extvsd,$(external_vsd),$(eval $(call external_pdf_name,$(extvsd))))

# # External PDF figure building rules
# $(foreach extvsd,$(external_vsd),$(eval $(call external_pdf_rule,$(extvsd))))

