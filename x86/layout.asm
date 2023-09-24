
;;; Note: page = 256 bytes; 16 bit address space is 64k or 256 pages

;;; The bootloader will be resident from page 124 (0x7c00)
;;; The lowest the kernel can be loaded is 0x500 (leaving 5 pages for the BIOS)

;;; A disk sector is 512 bytes

    sector_size equ 512

;;; The maximum space available for a contiguously loaded kernel is therfore 119 pages. (124-5)
;;; i.e. the space between the 5 pages reserved for the BIOS and the start of the bootloader
;;; That is 59.5 sector.

;;; We also load in embedded string data at 0x8000. So we have 128 pages here.

    kernel_load_address equ 0x500
    embedded_load_address equ 0x8000

    kernel_size_in_sectors equ 6 ; max 59
    embedded_size_in_sectors equ 55 ; max 62 ;; leaving 1k for param stack and return stack