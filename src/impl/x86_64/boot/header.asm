section .multiboot_header
header_start:
  ; magic number
  dd 0xe85250d6 ; multiboot2
  ;architecture
  dd 0
  ;header lenght
  dd header_start - header_end
  ;checksum
  dd 0x100000000 - (0xe85250d6 + 0 + (header_start - header_end))
  ;end tag
  dw 0
  dw 0
  dd 8
header_end: