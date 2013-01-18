.phony : all draft
all : $(top).pdf

textarget = $(top)

# code rules
$(eval $(call code_rule,$(code)))

draft: textarget = "\def\draftworkbook{}\input{$(top).tex}"
draft: $(top).pdf 


# tex building
$(top).pdf : $(my_tex) $(my_sty) $(my_epspdf) $(my_dotpdf) $(my_vsdpdf) $(my_pdf) $(my_jpg) 	\
             $(glossaryfile) $(shortcutfile) $(refdocfile) 					\
             $(codetex) 									
	$(latex)            $(latexopt)  $(textarget)
	$(makeindex)                     $(top)
	$(makeglossaries)                $(top)
	$(latex)            $(latexopt)  $(textarget)
	$(bibtex)           $(bibtexopt) $(top)
	$(makeglossaries)                $(top)
	$(makeindex)                     $(top)
	$(latex)            $(latexopt)  $(textarget)
	$(latex)            $(latexopt)  $(textarget)

%.pdf : %.eps
	$(epstopdf) $<

%.pdf : %.dot
	$(dotexe) $(dotopt) -Tpdf $< -o $@

%.pdf : %.vsd
	$(powershell) -ExecutionPolicy RemoteSigned -file $(vsd2pdf) $< $@

%.tex : %.mhdl
	$(perl) $(gencodetex) -f $^ $(gencodetexopt)

.phony: clean clean_all clean_top

clean: 
	rm -f $(dust) 

clean_top : clean
	rm -f $(top).pdf 

clean_all: clean clean_top
	rm -f $(foreach f,$(codetex) $(my_epspdf) $(my_dotpdf) $(my_vsdpdf),"$(f)")

