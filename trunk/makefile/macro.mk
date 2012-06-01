# OS dependent part
ifeq (,$(findstring Windows,$(OS)))

rm = rm -rf
cp = cp

define clean-rule  # $1: LaTeX top
clean-$1 :
	$(rm) $(foreach d,$(dust),$1_build/$d)

clean-pdf-$1 : clean-$1
	$(rm) $1_build/$1.pdf 

clean-all-$1: 
	$(rm) $1_build $1.pdf
endef

else

rm = del /F /Q
cp = copy

define clean-rule  # $1: LaTeX top
clean-$1: 
	$(foreach d,$(dust),$(rm) $1_build\$(d)
	)

clean-pdf-$1 : clean-$1
	$(rm) $1_build/$1.pdf

clean-all-$1: 
	$(rm) $1_build 
	$(rm) $1.pdf
endef
endif




mkdir = mkdir 

latex      = xelatex
bibtex     = bibtex

epstopdf   = epstopdf
makeindex  = makeindex
powershell = powershell
perl       = perl
dot        = dot
dia        = dia

makeglossaries = perl $(TEXLIVE)/texmf-dist/scripts/glossaries/makeglossaries

vsd2pdf    = $(TEXMFHOME)/scripts/vsd2pdf/vsd2pdf.ps1
gencodetex      = $(perl) $(TEXMFHOME)/scripts/gencodetex/gencodetex.pl
chkmd5_enc      = $(perl) $(TEXMFHOME)/scripts/chkmd5_enc/chkmd5_enc.pl
gencbdiff       = $(perl) $(TEXMFHOME)/scripts/genchangebar/gencbdiff.pl
getdiffbaseinfo = $(perl) $(TEXMFHOME)/scripts/genchangebar/getdiffbaseinfo.pl
diff2cb         = $(perl) $(TEXMFHOME)/scripts/genchangebar/diff2cb.pl



latexopt      = -proctime
gencodetexopt = -l metahdl -t section
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

glossaryfile = 
shortcutfile = 
refdocfile   = 

DRAFT =
CHANGBAR =  

revision = BASE


echo_var = 


.phony : dummy-rule
ifeq ($(echo_var),)
dummy-rule:
	@echo You can make following targets:
	@echo -e " "$(foreach t,$(__latex_top__),$t : $(__latex_top_dir_$t__)"\n")
else 
dummy-rule :
	@echo $($(echo_var))
endif


# $1: LaTeX top
# $2: base dir
# $3: dependent sub LaTeX top list
define register-doc
$(if $(strip $(findstring $1,$(__latex_top__))),$(error LaTeX top '$1' has already been defined!))
$(foreach s,$3,$(if $(strip $(findstring $s,$(__latex_top__))),,$(error Sub dependent LaTeX top '$s' is not defined!)))
export TEXINPUTS = $(realpath $2):$(abspath $1_build):$(TEXINPUTS)
$(eval __latex_top__ := $(__latex_top__) $1)
$(eval __latex_top_dir_$1__ := $(realpath $2))
$(eval __latex_submod_$1__ := $3)
endef


# $1: LaTeX top list
define get-all-submod
$(sort $(foreach m,$1,$(__latex_submod_$m__) $(foreach s,$(__latex_submod_$m__),$(call get-all-submod,$s))))
endef




# $1: LaTeX top file
# $2: code file
define generate-codetex
$1_build/$(notdir $2).codetex : $2
	$(gencodetex) -f $$< $(gencodetexopt) -o $$@
endef


# $1: LaTeX Top
# $2: source code file list 
define code-rule
$(foreach c,$2,$(eval $(call generate-codetex,$1,$(c))))
endef


# $1: LaTeX top 
# $2: code file list
define use-code
$(eval $1_code = $2)
$(eval $1_codetex = $(addprefix $1_build/,$(addsuffix .codetex,$(notdir $2))))
$(eval $(call code-rule,$1,$2))
endef


# $1: LaTeX top
# $2: base dir
define set-variable
$(eval $1_tex = $(wildcard $2/*.tex))

$(eval $1_dot = $(wildcard $2/*.dot))
$(eval $1_dotpdf = $(addprefix $1_build/,$(subst .dot,.pdf,$(notdir $($1_dot)))))

$(eval $1_dia = $(wildcard $2/*.dia))
$(eval $1_diaeps = $(addprefix $1_build/,$(subst .dia,.eps,$(notdir $($1_dia)))))

$(eval $1_vsd = $(wildcard $2/*.vsd))
$(eval $1_vsdpdf = $(addprefix $1_build/,$(subst .vsd,.pdf,$(notdir $($1_vsd)))))

$(eval $1_eps = $(wildcard $2/*.eps) $($1_diaeps))
$(eval $1_epspdf = $(addprefix $1_build/,$(subst .eps,.pdf,$(notdir $($1_eps)))))

#$(eval $1_pdf = $(filter-out $1.pdf $($1_epspdf) $($1_dotpdf) $($1_vsdpdf),$(wildcard $2/*.pdf)))
$(eval $1_pdf = $(wildcard $2/*.pdf))

$(eval $1_jpg = $(wildcard $2/*.jpg))

$(eval $1_sty = $(wildcard $2/*.sty))

$(eval $1_doc = $($1_tex) $($1_dot) $($1_vsd) $($1_eps) $($1_pdf) $($1_jpg) $($1_sty))
endef


# $1: LaTeX top
# $2: dependent sub LaTeX top list
define aggregate-variable
$(eval $1_tex += $(foreach s,$2,$($s_tex)))

$(eval $1_dot += $(foreach s,$2,$($s_dot)))
$(eval $1_dotpdf += $(foreach s,$2,$($s_dotpdf)))

$(eval $1_dia += $(foreach s,$2,$($s_dia)))
$(eval $1_diaeps += $(foreach s,$2,$($s_diaeps)))

$(eval $1_vsd += $(foreach s,$2,$($s_vsd)))
$(eval $1_vsdpdf += $(foreach s,$2,$($s_vsdpdf)))

$(eval $1_eps += $(foreach s,$2,$($s_eps)))
$(eval $1_epspdf += $(foreach s,$2,$($s_epspdf)))

#$(eval $1_pdf += $(filter-out $1.pdf $($1_epspdf) $($1_dotpdf) $($1_vsdpdf),$(wildcard $2/*.pdf)))
$(eval $1_pdf += $(foreach s,$2,$($s_pdf)))

$(eval $1_jpg += $(foreach s,$2,$($s_jpg)))

$(eval $1_sty += $(foreach s,$2,$($s_sty)))

$(eval $1_code += $(foreach s,$2,$($s_code)))
$(eval $1_codetex += $(foreach s,$2,$($s_codetex)))

$(eval $1_doc += $($1_tex) $($1_dot) $($1_vsd) $($1_eps) $($1_pdf) $($1_jpg) $($1_sty))
endef




.phony : all clean clean-pdf clean-all

# $1: LaTeX doc top. As a rule, the $(top).tex should be put in
#     a directory named `$(top)'. e.g., lshort.tex should be put
#     inside lshort/
# $2: base dir
# $3: with or without glossary in compilation
# $4: with or without bib
# $5: dependent sub LaTeX top list
define build-pdf
$(eval $(call register-doc,$1,$2,$5))
$(eval $(call set-variable,$1,$2))

$(foreach s,$5,$(if $(findstring $s,$(__latex_top__)),,$(error Dependent sub LaTeX top '$s' is not defined!)))
$(if $5,$(eval $1 : $(foreach s,$(call get-all-submod,$1),$s_build)))
$(eval $(call aggregate-variable,$1,$(call get-all-submod,$1)))

.phony : $1 draft-$1 quick-$1 changebar-$1 create-changebar-$1 clean-$1 clean-pdf-$1 clean-all-$1
all : $1
clean: clean-$1
clean-pdf : clean-pdf-$1
clean-all : clean-all-$1
$1 : $1_build $1.pdf

changebar-$1 : CHANGEBAR = 1
changebar-$1 : $1_build create-changebar-$1 $1.pdf


create-changebar-$1 :
	$(rm) $1.pdf
	$(gencbdiff) -r $(revision) $(diffopt) $(my_tex) $(my_sty)
#	$(foreach f,$(my_tex),svn diff -r $(revision) $(diffopt) $(f) > $(f).cbdiff
#	)
	$(foreach f,$(my_tex) $(my_sty),$(diff2cb) $(f)
	)
#	$(genchangebar) -r $(revision)



draft-$1: DRAFT = 1
draft-$1: $1_build $1.pdf 

# tex building
$1.pdf : $1_build/$1.pdf
	$(cp) $$< $$@
$1_build/$1.pdf : $($1_tex) $($1_sty) $($1_epspdf) $($1_dotpdf) $($1_vsdpdf) $($1_pdf) $($1_jpg) $($1_codetex)	\
                    $(glossaryfile) $(shortcutfile) $(refdocfile) 
	cd $1_build; $(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	cd $1_build; $(makeindex)        $1
	$(if $3,cd $1_build; $(makeglossaries)  $1)
	cd $1_build; $(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	$(if $4,cd $1_build; $(bibtex)           $(bibtexopt) $1)
	$(if $3,cd $1_build; $(makeglossaries)  $1)
	cd $1_build; $(makeindex)        $1
	cd $1_build; $(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	cd $1_build; $(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

quick-$1 : $1_build 
	cd $1_build; $(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

$1_build/%.eps : $2/%.dia
	$(dia) -t eps -e $$@ $$<

$1_build/%.pdf : $1_build/%.eps
	$(epstopdf) $$< --outfile=$$@

$1_build/%.pdf : $(realpath $2)/%.eps
	$(epstopdf) $$< --outfile=$$@

$1_build/%.pdf : $2/%.dot
	$(dot) $(dotopt) -Tpdf $$< -o $$@

$1_build/%.pdf : $2/%.vsd
	cd $1_build; $(powershell) -ExecutionPolicy RemoteSigned -file $(vsd2pdf) $$< $$(@F)

$1_build :
	$(mkdir) -p $$@

$(eval $(call clean-rule,$1))

endef

