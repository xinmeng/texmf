texbuild = texbuild

rm = rm -rf
cp = cp

.PHONY : $(texbuild)/clean $(texbuild)/clean-all
define clean-rule  # $1: LaTeX top
.PHONY : $(texbuild)/clean-$1 $(texbuild)/clean-all-$1
$(texbuild)/clean     : $(texbuild)/clean/$1
$(texbuild)/clean-all : $(texbuild)/clean-all/$1

$(texbuild)/clean/$1 :
	$(rm) $(foreach d,$(dust),$1/$d) $1/$1.pdf 

$(texbuild)/clean-all/$1: 
	$(rm) $1 $1.pdf
endef



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

glossaryfile = 
shortcutfile = 
refdocfile   = 

DRAFT =
CHANGBAR =  

revision = BASE


echo_var = 


define new-line


endef

.PHONY : $(texbuild)
$(texbuild):
	@echo You can make following targets:
	@echo "  "$(foreach t,$(__latex_top__),$(texbuild)/$t : $(__latex_top_dir_$t__)${new-line}@echo " ")


# $1: LaTeX top
# $2: base dir
# $3: dependent sub LaTeX top list
define register-doc
$(if $(strip $(findstring $1,$(__latex_top__))),$(error LaTeX top '$1' has already been defined!))
$(foreach s,$3,$(if $(strip $(findstring $s,$(__latex_top__))),,$(error Sub dependent LaTeX top '$s' is not defined!)))
$(eval __latex_top__ := $(__latex_top__) $1)
$(eval __latex_top_dir_$1__ := $(abspath $2))
$(eval __latex_submod_$1__ := $3)
endef

# $1: LaTeX top
define add-texinputs-dir
$(eval export TEXINPUTS = $(abspath $(__latex_top_dir_$1__)):$1:$(TEXINPUTS))
$(foreach s,$(call get-all-submod,$1),$(eval export TEXINPUTS = $(abspath $(__latex_top_dir_$s__)):$(abspath $s):$(TEXINPUTS)))
$(TEXINPUTS)
endef


# $1: LaTeX top list
define get-all-submod
$(sort $(foreach m,$1,$(__latex_submod_$m__) $(foreach s,$(__latex_submod_$m__),$(call get-all-submod,$s))))
endef




# $1: LaTeX top file
# $2: code file
define generate-codetex
$1/$(notdir $2).tex : $2
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
$(eval $1_codetex = $(addprefix $1/,$(addsuffix .tex,$(notdir $2))))
$(eval $(call code-rule,$1,$2))
endef


# $1: LaTeX top
# $2: base dir
define set-variable
$(eval $1_tex = $(wildcard $2/*.tex))

$(eval $1_dot = $(wildcard $2/*.dot))
$(eval $1_dotpdf = $(addprefix $1/,$(subst .dot,.pdf,$(notdir $($1_dot)))))

$(eval $1_dia = $(wildcard $2/*.dia))
$(eval $1_diaeps = $(addprefix $1/,$(subst .dia,.eps,$(notdir $($1_dia)))))

$(eval $1_eps = $(wildcard $2/*.eps) $($1_diaeps))
$(eval $1_epspdf = $(addprefix $1/,$(subst .eps,.pdf,$(notdir $($1_eps)))))

$(eval $1_svg = $(wildcard $2/*.svg))
$(eval $1_svgpdf = $(addprefix $1/,$(subst .svg,.pdf,$(notdir $($1_svg)))))

$(eval $1_odg = $(wildcard $2/*.odg))
$(eval $1_odgpdf = $(addprefix $1/,$(subst .odg,.pdf,$(notdir $($1_odg)))))


#$(eval $1_pdf = $(filter-out $1.pdf $($1_epspdf) $($1_dotpdf) $($1_vsdpdf),$(wildcard $2/*.pdf)))
$(eval $1_pdf = $(wildcard $2/*.pdf))

$(eval $1_jpg = $(wildcard $2/*.jpg))

$(eval $1_sty = $(wildcard $2/*.sty))

$(eval $1_doc = $($1_tex) $($1_dot) $($1_vsd) $($1_eps) $($1_pdf) $($1_svg) $($1_jpg) $($1_sty))
endef
## moved out from `set-variable', it still take
## effects even when it is commented out. 
## $(eval $1_vsd = $(wildcard $2/*.vsd))
## $(eval $1_vsdpdf = $(addprefix $1/,$(subst .vsd,.pdf,$(notdir $($1_vsd)))))




# $1: LaTeX top
# $2: dependent sub LaTeX top list
define aggregate-variable
$(eval $1_tex += $(foreach s,$2,$($s_tex)))

$(eval $1_dot += $(foreach s,$2,$($s_dot)))
$(eval $1_dotpdf += $(foreach s,$2,$($s_dotpdf)))

$(eval $1_dia += $(foreach s,$2,$($s_dia)))
$(eval $1_diaeps += $(foreach s,$2,$($s_diaeps)))

# $(eval $1_vsd += $(foreach s,$2,$($s_vsd)))
# $(eval $1_vsdpdf += $(foreach s,$2,$($s_vsdpdf)))

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





define build-pdf-xetex
$(eval $(call build-pdf,$1,$2,$3,$4,$5))

$1 : latex=xelatex
endef




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
$(if $5,$(eval $1 : $(foreach s,$(call get-all-submod,$1),$s $($s_codetex) $($s_tex) $($s_pdf) $($s_jpg) $($s_odbpdf) $($s_dotpdf) $($s_epspdf) $($s_svgpdf) $($s_sty))))
#$(eval $(call aggregate-variable,$1,$(call get-all-submod,$1)))

.PHONY : $(texbuild)/$1 draft-$1 quick-$1 changebar-$1 create-changebar-$1

$(texbuild)/$1 : $1 $1.pdf 


changebar-$1 : CHANGEBAR = 1 
changebar-$1 : $1 create-changebar-$1 $1.pdf


create-changebar-$1 :
	$(rm) $1/$1.pdf $1.pdf
	$(foreach f,$($1_tex) $($1_sty),svn diff -r $(revision) $(diffopt) $f > $1/$(notdir $f).cbdiff
	)
	$(foreach f,$($1_tex) $($1_sty),$(diff2cb) -dirfile $f -cbdiff $1/$(notdir $f).cbdiff
	)



draft-$1: DRAFT = 1
draft-$1: $1 $1.pdf 


$$(if $$(or $$(and $$findstring($$(MAKECMDGOALS),$1),$$(findstring $1,$$(MAKECMDGOALS))),			\
            $$(and $$findstring($$(MAKECMDGOALS),quick-$1),$$(findstring quick-$1,$$(MAKECMDGOALS))),		\
            $$(and $$findstring($$(MAKECMDGOALS),changebar-$1),$$(findstring changebar-$1,$$(MAKECMDGOALS)))	\
        ),													\
      $$(info $$(strip $$(call add-texinputs-dir,$1))))

# tex building
$1.pdf : $1/$1.pdf
	$(cp) $$< $$@
$1/$1.pdf : $($1_tex) $($1_sty) $($1_epspdf) $($1_dotpdf) $($1_vsdpdf) $($1_svgpdf) $($1_odgpdf) $($1_pdf) $($1_jpg) $($1_codetex)	\
                    $(glossaryfile) $(shortcutfile) $(refdocfile) 
	env
	cd $1; $$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	cd $1; $(makeindex)        $1
	$(if $3,cd $1; $(makeglossaries)  $1)
	cd $1; $$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	$(if $4,cd $1; $(bibtex)           $(bibtexopt) $1)
	$(if $3,cd $1; $(makeglossaries)  $1)
	cd $1; $(makeindex)        $1
	cd $1; $$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	cd $1; $$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

quick-$1 : $1 $($1_epspdf) $($1_dotpdf) $($1_vsdpdf) $($1_codetex)
	cd $1; $$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

$1/%.eps : $2/%.dia
	$(dia) -t eps -e $$@ $$<

$1/%.pdf : $1/%.eps
	$(epstopdf) $$< --outfile=$$@

$1/%.pdf : $(realpath $2)/%.eps
	$(epstopdf) $$< --outfile=$$@

$1/%.pdf : $2/%.dot
	$(dot) $(dotopt) -Tpdf $$< -o $$@

$1/%.pdf : $2/%.svg
	$(svgtopdf) -f pdf -o $$@ $$<

$1/%.pdf : $1/%.eps 
	$(inkscape) -D -A $$@ $$<

$1/%.eps : $2/%.odg
	$(soffice) --headless --convert-to eps --outdir $$(@D) $$<

$1/%.pdf : $2/%.vsd
	cd $1; $(powershell) -ExecutionPolicy RemoteSigned -file $(vsd2pdf) $$< $$(@F)

$1 :
	$(mkdir) -p $$@

$(eval $(call clean-rule,$1))

endef

