vsd = $(wildcard *.vsd)
pdf = $(addsuffix .pdf,$(basename $(vsd)))

TEXMFHOME = Z:\mxmf\projects\texmf

vsd2pdf = $(TEXMFHOME)\scripts\vsd2pdf\vsd2pdf.ps1

# windows could not be able to
# run a remote powershell script
local_vsd2pdf = d:\tools\vsd2pdf.ps1 

powershell = powershell


.phony : all echo clean

all : $(local_vsd2pdf) $(pdf)

$(local_vsd2pdf) : $(vsd2pdf)
	copy $< $@

%.pdf : %.vsd
	$(powershell) -ExecutionPolicy RemoteSigned -file $(local_vsd2pdf) $< $@

clean: 
	del $(pdf)


echo:
	echo $(pdf)
