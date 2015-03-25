include pure_mapi.mk
types = mod					\
        dir					\
        tex sty gls bib				\
        pdf jpeg				\
        svg svgpdf				\
        eps epspdf				\
        dia diaeps diapdf			\
        dot dotpdf				\
        odg odgeps odgpdf			\
        code codetex
$(call mapi-setup,$(types),mod)

src_types = tex sty gls bib pdf jpeg 
gen_types = svgpdf epspdf diapdf dotpdf odgpdf codetex

texbuild = texbuild

rm = rm -rf
cp = cp

mkdir = mkdir 

latex      = pdflatex
bibtex     = bibtex

svgtopdf   = rsvg-convert
epstopdf   = epstopdf
makeindex  = makeindex
powershell = powershell
perl       = perl
dot        = dot
dia        = dia
inkscape   = inkscape
soffice    = soffice # LibreOffice

makeglossaries = perl $(TEXLIVE)/texmf-dist/scripts/glossaries/makeglossaries

vsd2pdf    = $(TEXMFHOME)/scripts/vsd2pdf/vsd2pdf.ps1
gencodetex      = $(perl) $(TEXMFHOME)/scripts/gencodetex/gencodetex.pl
chkmd5_enc      = $(perl) $(TEXMFHOME)/scripts/chkmd5_enc/chkmd5_enc.pl
gencbdiff       = $(perl) $(TEXMFHOME)/scripts/genchangebar/gencbdiff.pl
getdiffbaseinfo = $(perl) $(TEXMFHOME)/scripts/genchangebar/getdiffbaseinfo.pl
diff2cb         = $(perl) $(TEXMFHOME)/scripts/genchangebar/diff2cb.pl



latexopt      = 
gencodetexopt = -t section
dotopt        = 
bibtexopt     = 
diffopt       = #--diffopt 'diff -x "-U 0"' 


dust = *.aux *.ilg *.ind *.idx *.toc		\
       *.xdy					\
       *.loa					\
       *.log *.out *.lot *.lol *.lof		\
       *.tmp *.ist *.glg *.gls *.glo		\
       *.blg *.bbl				\
       *.reglog *.reggls *.regglo		\
       *.iolog  *.iogls  *.ioglo		\
       *.dslog  *.dsgls  *.dsglo		\
       *.cbdiff *.changebar			\
       *~


# --------------------------------------------------
#   $1: module names
#   $2: type
define derive-variables
$(foreach m,$(modules),																		\
   $(call add-dir,$m,$(sort $(dir $(foreach t,tex pdf jpeg sty gls bib,$(call shallow-get-$t,$m)))))								\
   $(call add-codetex,$m,$(addprefix $(abspath $m)/,$(addsuffix .tex,$(notdir $(call shallow-get-code,$m)))))					\
   $(foreach t,dia odg,$(call add-$(t)eps,$m,$(addprefix $(abspath $m)/,$(addsuffix .eps,$(basename $(notdir $(call shallow-get-$t,$m)))))))			\
   $(foreach t,svg eps dia dot odg,$(call add-$(t)pdf,$m,$(addprefix $(abspath $m)/,$(addsuffix .pdf,$(basename $(notdir $(call shallow-get-$t,$m))))))))
endef


.PHONY : $(texbuild)
$(texbuild):
	@echo You can make following targets:
	@$(foreach m,$(modules),echo -n "  $(texbuild)/$m : $(call get-dir,$m)";echo;)

.PHONY : $(texbuild)/clean $(texbuild)/clean-all

define clean-rule
.PHONY : $(texbuild)/clean-$1 $(texbuild)/clean-all-$1
$(texbuild)/clean     : $(texbuild)/$1/clean
$(texbuild)/clean-all : $(texbuild)/$1/clean-all

$(texbuild)/$1/clean :
	$(rm) $(foreach d,$(dust),$1/$d) $1/$1.pdf 

$(texbuild)/$1/clean-all: 
	$(rm) $1 $1.pdf
endef

# --------------------------------------------------
#  $1: module name
#  $2: svg file
define svg-rule
$(abspath $1)/$(basename $(notdir $2)).pdf : $2
	$(svgtopdf) -f pdf -o $$@ $$<

endef

define eps-rule
$(abspath $1)/$(basename $(notdir $2)).pdf : $2
	$(epstopdf) $$< --outfile=$$@

endef

define dot-rule
$(abspath $1)/$(basename $(notdir $2)).pdf : $2
	$(dot) $(dotopt) -Tpdf $$< -o $$@

endef

define dia-rule
$(mapi-debug-enter)
$(abspath $1)/$(basename $(notdir $2)).pdf : $(abspath $1)/$(basename $(notdir $2)).eps
	$(epstopdf) $$< --outfile=$$@
$(abspath $1)/$(basename $(notdir $2)).eps : $2
	$(dia) -t eps -e $$@ $$<

endef

define odg-rule
$(abspath $1)/$(basename $(notdir $2)).pdf : $(abspath $1)/$(basename $(notdir $2)).eps
	$(inkscape) -D -A $$@ $$<
$(abspath $1)/$(basename $(notdir $2)).eps : $2
	$(soffice) --headless --convert-to eps --outdir $$(@D) $$<

endef

define code-rule
$(abspath $1)/$(notdir $2).tex : $2
	$(gencodetex) $(gencodetexopt) -f $$< -o $$@

endef


define add-texinputs-dir
$(eval export TEXINPUTS := $(call replace-space,:,$(call get-dir,$1)):$(abspath $1):$(TEXINPUTS))
$(foreach m,$(call get-mod,$1),											\
            $(eval export TEXINPUTS := $(call replace-space,:,$(call get-dir,$m)):$(abspath $m):$(TEXINPUTS)))
$(info $(TEXINPUTS))
endef


define build-pdf
$(call build-pdf-internal,$(strip $1))
endef


define build-pdf-internal
$$(if $$(or $$(and $$findstring($$(MAKECMDGOALS),$1),			\
                   $$(findstring $1,$$(MAKECMDGOALS))),			\
            $$(and $$findstring($$(MAKECMDGOALS),quick-$1),		\
                   $$(findstring quick-$1,$$(MAKECMDGOALS))),		\
            $$(and $$findstring($$(MAKECMDGOALS),changebar-$1),		\
                   $$(findstring changebar-$1,$$(MAKECMDGOALS)))),	\
      $$(info $$(strip $$(call add-texinputs-dir,$1))))


.PHONY : $(texbuild)/$1
$(texbuild)/$1 : $1.pdf

$1.pdf: $1/$1.pdf 
	cp $$< $$@

.PHONY : $(texbuild)/$1/src $(texbuild)/$1/gen
$1/$1.pdf : $(texbuild)/$1/src $(texbuild)/$1/gen $(foreach m,$(call get-mod,$1),$(texbuild)/$m/src $(texbuild)/$m/gen)
	env
	cd $1; $$(latex) $(latexopt)  $1 
	cd $1; $(makeindex)        $1
	$$(if $$(strip $$(call get-gls,$1)),cd $1; $(makeglossaries)  $1)
	cd $1; $$(latex) $(latexopt)  $1 
	$$(if $$(strip $$(call get-bib,$1)),cd $1; $(bibtex) $(bibtexopt) $1)
	$$(if $$(strip $$(call get-gls,$1)),cd $1; $(makeglossaries)  $1)
	cd $1; $(makeindex)        $1
	cd $1; $$(latex) $(latexopt)  $1 
	cd $1; $$(latex) $(latexopt)  $1 

$(texbuild)/$1/src : $(foreach t,$(src_types),$(call shallow-get-$t,$1))
$(texbuild)/$1/gen : $1 $(foreach t,$(gen_types),$(call shallow-get-$t,$1))

$1 : 
	mkdir -p $$@


$(foreach f,$(call shallow-get-svg,$1),$(call svg-rule,$1,$f))
$(foreach f,$(call shallow-get-eps,$1),$(call eps-rule,$1,$f))
$(foreach f,$(call shallow-get-dot,$1),$(call dot-rule,$1,$f))
$(foreach f,$(call shallow-get-dia,$1),$(call dia-rule,$1,$f))
$(foreach f,$(call shallow-get-odg,$1),$(call odg-rule,$1,$f))
$(foreach f,$(call shallow-get-code,$1),$(call code-rule,$1,$f))

$(call clean-rule,$1)
endef

