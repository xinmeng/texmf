bibtex         = "bibtex.exe"

epstopdf   = "epstopdf.exe"
makeindex  = "makeindex.exe"
powershell = "powershell.exe"
perl       = "perl.exe"
dotexe     = "c:/tools/Graphviz2.26.3/bin/dot.exe"
makeglossaries = perl "D:/texlive/2010/texmf-dist/scripts/glossaries/makeglossaries"

vsd2pdf    = "$(mxscripts_dir)/powershell/vsd2pdf/vsd2pdf.ps1"
gencodetex = "$(mxscripts_dir)/perl/gencodetex/gencodetex.pl"
chkmd5_enc = "$(mxscripts_dir)/perl/chkmd5_enc/chkmd5_enc.pl"


dust = *.aux *.ilg *.ind *.idx *.toc		\
       *.log *.out *.lot *.lol *.lof		\
       *.tmp *.ist *.glg *.gls *.glo		\
       *.blg *.bbl				\
       *.reglog *.reggls *.regglo		\
       *.iolog  *.iogls  *.ioglo		\
       *.dslog  *.dsgls  *.dsglo		\
       *~

# MXfiles = $(common_dir)/latex/MXCommon.sty	\
# 	  $(common_dir)/latex/MXBookEN.sty	\
# 	  $(common_dir)/latex/MXBookCN.sty	\
# 	  $(common_dir)/latex/MXNote.sty	\
# 	  $(common_dir)/latex/MXCover.sty

# exar_template = $(common_dir)/latex/ExarFrontCover.tex		\
#                 $(common_dir)/latex/ExarBackCover.tex		\
# 	        $(common_dir)/latex/ExarLegalDisclaimer.tex	\
#                 $(common_dir)/latex/ExarWB.sty			\
#                 $(common_dir)/latex/exar_logo.JPG		\
#                 $(common_dir)/latex/wallpaper_internal_doc.pdf


