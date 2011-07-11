.phony: copy_enc local_enc copy_dec local_dec

copy_enc:
	$(foreach f,$(src_doc),$(call encrypt_file,$(f)))
	$(foreach c,$(code),$(call encrypt_code,$(c),$(src_dir)))

copy_dec: 
	$(foreach f,$(wildcard *.gpg),$(call decrypt_file,$(f),$(src_dir)/doc/$(basename $(f))))
	$(foreach c,$(code),$(call decrypt_code,$(c),$(src_dir)))


local_enc: 
	$(foreach f,$(my_doc),$(call encrypt_file,$(f)))
	$(foreach c,$(code),$(call encrypt_code,$(c),..))

local_dec: 
	$(foreach f,$(wildcard *.gpg),$(call decrypt_file,$(f),$(basename $(f))))
	$(foreach c,$(code),$(call decrypt_code,$(c),..))
