define decrypt_gpg_file
$(basename $1) : $1
	gpg -d -r "xin meng" --output $$@ --yes $$<
endef

define decrypt_code_convert_to_tex
$1.tex : $(subst .,../,$(suffix $1))/$1
	$(gencodetex) $(gencodetexopt) $$<

$(subst .,../,$(suffix $1))/$1 : $(subst .,../,$(suffix $1))/$1.gpg
	gpg -d -r "xin meng" --output $$@ --yes $$<

endef



gpg_files = $(wildcard *.gpg)

tex = $(basename $(wildcard *.tex.gpg))

dot = $(basename $(wildcard *.dot.gpg))
dotpdf = $(subst dot,pdf,$(dot))

vsd = $(basename $(wildcard *.vsd.gpg))
vsdpdf = $(subst vsd,pdf,$(vsd))

eps = $(basename $(wildcard *.eps.gpg))
epspdf = $(subst eps,pdf,$(eps))

pdf = $(filter-out $(top).pdf $(epspdf) $(dotpdf) $(vsdpdf), $(basename $(wildcard *.pdf.gpg)))
jpg = $(basename $(wildcard *.jpg.gpg))

sty = $(basename $(wildcard *.sty.gpg))


$(top).pdf : $(tex) $(addsuffix .tex,$(code)) $(sty) $(epspdf) $(dotpdf) $(vsdpdf) $(pdf) $(jpg) $(glossaryfile) $(shortcutfile) $(refdocfile) $(MXfiles) $(exar_template)
	$(latex)   $(latexopt) $(top)
	$(makeindex) $(top)
	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).gls $(top).glo 
# 	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).reggls $(top).regglo 
# 	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).iogls $(top).ioglo 
	$(latex)   $(latexopt) $(top)
	$(bibtex) $(bibtexopt)   $(top)
	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).gls $(top).glo 
# 	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).reggls $(top).regglo 
# 	$(makeindex) -s $(top).ist -t $(top).glg -o $(top).iogls $(top).ioglo 
	$(makeindex) $(top)
	$(latex)   $(latexopt) $(top)
	$(latex)   $(latexopt) $(top)


%.pdf : %.eps
	$(epstopdf) $<

%.pdf : %.dot
	$(dotexe) $(dotopt) -Tpdf $< -o $@

%.pdf : %.vsd
	$(powershell) -ExecutionPolicy RemoteSigned -file $(vsd2pdf) $< $@


$(foreach g,$(gpg_files),$(eval $(call decrypt_gpg_file,$(g))))
$(foreach c,$(code),$(eval $(call decrypt_code_convert_to_tex,$(c))))


.phone : publish clean clean_all


publish : $(publish_file)

$(publish_file) : $(top).pdf
	copy $< $@ /Y

clean: 
	del $(dust) 

clean_all:
	del $(dust) $(codetex) $(epspdf) $(dotpdf) $(vsdpdf) $(top).pdf 

echo: 
	@echo $(tex)
