# $1: code file
# $2: base dir
define locate_code
$(subst .,$2/,$(suffix $1))/$1
endef


# $1: variable prefix
# $2: base dir
define set_variable
$(eval $1_tex = $(wildcard $2/doc/*.tex))

$(eval $1_dot = $(wildcard $2/doc/*.dot))
$(eval $1_dotpdf = $(subst dot,pdf,$($1_dot)))

$(eval $1_vsd = $(wildcard $2/doc/*.vsd))
$(eval $1_vsdpdf = $(subst vsd,pdf,$($1_vsd)))

$(eval $1_eps = $(wildcard $2/doc/*.eps))
$(eval $1_epspdf = $(subst eps,pdf,$($1_eps)))

$(eval $1_pdf = $(filter-out %$(top).pdf $($1_epspdf) $($1_dotpdf) $($1_vsdpdf),$(wildcard $2/doc/*.pdf)))


$(eval $1_jpg = $(wildcard $2/doc/*.jpg))

$(eval $1_sty = $(wildcard $2/doc/*.sty))

$(eval $1_doc = $($1_tex) $($1_dot) $($1_vsd) $($1_eps) $($1_pdf) $($1_jpg) $($1_sty))

$1_code = $(foreach c,$(code),$(call locate_code,$(c),$2))
endef


define set_my_variable
$(eval my_tex = $(wildcard *.tex))

$(eval my_dot = $(wildcard *.dot))
$(eval my_dotpdf = $(subst dot,pdf,$(my_dot)))

$(eval my_vsd = $(wildcard *.vsd))
$(eval my_vsdpdf = $(subst vsd,pdf,$(my_vsd)))

$(eval my_eps = $(wildcard *.eps))
$(eval my_epspdf = $(subst eps,pdf,$(my_eps)))

$(eval my_pdf = $(filter-out %$(top).pdf $(my_epspdf) $(my_dotpdf) $(my_vsdpdf),$(wildcard *.pdf)))


$(eval my_jpg = $(wildcard *.jpg))

$(eval my_sty = $(wildcard *.sty))

$(eval my_doc = $(my_tex) $(my_dot) $(my_vsd) $(my_eps) $(my_pdf) $(my_jpg) $(my_sty))
endef




# $1: src file name  
define encrypt_file
	$(perl) $(chkmd5_enc) -r $(receipt) -g $(notdir $1).gpg -s $1

endef

define decrypt_file
	gpg -r $(receipt) -d --output $2 --yes $1

endef


# $1: code file name
# $2: base dir
define encrypt_code
	$(perl) $(chkmd5_enc) -r $(receipt) -g $(call locate_code,$1,..).gpg -s $(call locate_code,$1,$2)

endef

define decrypt_code
	gpg -r $(receipt) -d --output $(call locate_code,$1,$2) --yes $(call locate_code,$1,..).gpg

endef



define generate_codetex
$1.tex : $(call locate_code,$1,..,)
	$(perl) $(gencodetex) -f $$< $(gencodetexopt) -o $$@
endef


define code_rule
codetex = $(addsuffix .tex,$1)

$(foreach c,$1,$(eval $(call generate_codetex,$(c))))
endef