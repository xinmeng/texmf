rm = rm -f
cp = cp

latex      = xelatex
bibtex     = bibtex

epstopdf   = epstopdf
makeindex  = makeindex
powershell = powershell
perl       = perl
dot        = dot

makeglossaries = perl $(TEXLIVE)/texmf-dist/scripts/glossaries/makeglossaries

vsd2pdf    = $(TEXMFHOME)/scripts/vsd2pdf/vsd2pdf.ps1
gencodetex      = $(perl) $(TEXMFHOME)/scripts/gencodetex/gencodetex.pl
chkmd5_enc      = $(perl) $(TEXMFHOME)/scripts/chkmd5_enc/chkmd5_enc.pl
gencbdiff       = $(perl) $(TEXMFHOME)/scripts/genchangebar/gencbdiff.pl
getdiffbaseinfo = $(perl) $(TEXMFHOME)/scripts/genchangebar/getdiffbaseinfo.pl
diff2cb         = $(perl) $(TEXMFHOME)/scripts/genchangebar/diff2cb.pl



latexopt      = -proctime
gencodetexopt = -l metahdl -t chapter
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


var_name = 

define clean-rule
clean: 
	$(foreach d,$(dust),$(rm) $(d)
	)

clean-all: clean clean-pdf
	$(foreach d,$(codetex) $(my_epspdf) $(my_dotpdf) $(my_vsdpdf),$(rm) $(d)
	)
endef

.phony : dummy-rule
ifeq ($(var_name),)
dummy-rule:
	@echo All documents:
	@echo $(foreach t,$(__latex_top__),"\n "$t @ $(__latex_top_dir_$t__))
	@echo "\n"
else 
dummy-rule :
	@echo $($(var_name))
endif

.phony : clean clean-all
clean:
	$(rm) $(dust)

clean-all : clean
	$(rm) $(foreach t,$(__latex_top__),$($t_epspdf) $($t_dotpdf) $($t_codetex) $t.pdf)


# $1: LaTeX top
# $2: base dir
define register-doc
$(eval __latex_top__ := $(__latex_top__) $1)
$(eval __latex_top_dir_$1__ := $2)
endef



define generate-codetex
$(notdir $1).codetex : $1
	$(gencodetex) -f $$< $(gencodetexopt) -o $$@
endef


# $1: source code file list 
define code-rule
$(foreach c,$1,$(eval $(call generate-codetex,$(c))))
endef


# $1: LaTeX top 
# $2: code file list
define use-code
$(eval $1_code = $2)
$(eval $1_codetex = $(addsuffix .codetex,$(notdir $2)))
$(eval $(call code-rule,$2))
endef


# $1: variable prefix
# $2: base dir
define set-variable
$(eval $1_tex = $(wildcard $2/*.tex))

$(eval $1_dot = $(wildcard $2/*.dot))
$(eval $1_dotpdf = $(subst dot,pdf,$(notdir $($1_dot))))

$(eval $1_vsd = $(wildcard $2/*.vsd))
$(eval $1_vsdpdf = $(subst vsd,pdf,$(notdir $($1_vsd))))

$(eval $1_eps = $(wildcard $2/*.eps))
$(eval $1_epspdf = $(subst eps,pdf,$(notdir $($1_eps))))

$(eval $1_pdf = $(filter-out $1.pdf $($1_epspdf) $($1_dotpdf) $($1_vsdpdf),$(wildcard $2/*.pdf)))

$(eval $1_jpg = $(wildcard $2/*.jpg))

$(eval $1_sty = $(wildcard $2/*.sty))

$(eval $1_doc = $($1_tex) $($1_dot) $($1_vsd) $($1_eps) $($1_pdf) $($1_jpg) $($1_sty))
endef




.phony : all clean clean-pdf clean-all

# $1: LaTeX doc top. As a rule, the $(top).tex should be put in
#     a directory named `$(top)'. e.g., lshort.tex should be put
#     inside lshort/
# $3: base dir
# $3: with or without glossary in compilation
# $4: with or without bib
define build-pdf
$(eval $(call register-doc,$1,$2))
$(eval $(call set-variable,$1,$2))

.phony : $1 draft-$1 quick-$1 clean-pdf-$1 create-changebar-$1
all : $1
clean-pdf : clean-pdf-$1
$1 : $1.pdf

changebar-$1 : CHANGEBAR = 1
changebar-$1 : create-changebar-$1 $1.pdf


create-changebar-$1 :
	$(rm) $1.pdf
	$(gencbdiff) -r $(revision) $(diffopt) $(my_tex) $(my_sty)
#	$(foreach f,$(my_tex),svn diff -r $(revision) $(diffopt) $(f) > $(f).cbdiff
#	)
	$(foreach f,$(my_tex) $(my_sty),$(diff2cb) $(f)
	)
#	$(genchangebar) -r $(revision)



draft-$1: DRAFT = 1
draft-$1: $1.pdf 

# tex building
$1.pdf : $($1_tex) $($1_sty) $($1_epspdf) $($1_dotpdf) $($1_vsdpdf) $($1_pdf) $($1_jpg) $($1_codetex)	\
             $(glossaryfile) $(shortcutfile) $(refdocfile) 
	$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	$(makeindex)        $1
	$(if $3,$(makeglossaries)  $1)
	$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	$(if $4,$(bibtex)           $(bibtexopt) $1)
	$(if $3,$(makeglossaries)  $1)
	$(makeindex)        $1
	$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))
	$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

quick-$1 : 
	$(latex) $(latexopt)  $$(if $$(DRAFT),"\def\draftworkbook{}\input{$1.tex}",$$(if $$(CHANGEBAR),"\def\changebarworkbook{}\newcommand{\DiffBaseVersion}{$$(shell $(getdiffbaseinfo) -r $(revision))}\input{$1.tex}",$1))

%.pdf : %.eps
	$(epstopdf) $$<

%.pdf : %.dot
	$(dot) $(dotopt) -Tpdf $$< -o $$@

%.pdf : %.vsd
	$(powershell) -ExecutionPolicy RemoteSigned -file $(vsd2pdf) $$< $$@

$(foreach c,$(code),$(call generate_codetex,$(c)))


clean-pdf-$1 : clean
	$(rm) $1.pdf 


endef

