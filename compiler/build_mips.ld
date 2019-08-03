/*
 * Linker script for a simple MIPS assembly build.
 * I don't know what to do about exception handlers yet.
 *
 */



/* Entry point defined as a linker parameter. */
SECTIONS
{
  . = ALIGN(4);
  
  /*
   * Begin the read-only code section here.
   */
  .text      :
  {
    *(.text)
    *(.text.*)
    *(.gnu.linkonce.t*)


    /* all this junk keeps getting in my way. What is it for?
       what is the right thing to do with it? I shove it here
       for now. bleah. monday!
       dvb 2003.11.03
    */

    *(.jcr)
    *(.text.prefix) /* Force prefix to be first */
    *(.init)
    *(.init.*)
    *(.fini)
    *(.fini.*)
  } =0

  . = ALIGN(4);
 
  /*
   * --------------------------------------------------
   * the .data section contains initialized and writeable
   * variables. Data section is loaded at the specified address
   * (data NOT loaded in code section).
   */
  
  .data :
  {
    _data = .;
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d*)
    SORT(CONSTRUCTORS)

    . = ALIGN(4);
  }

  /*
   * "_end" is used as the start of the mallocable memoryarea
   */

  _end = .;
  PROVIDE (end = .);
  
  . = 0x80000000;
  .ktext :
  {
    *(.ktext)
    . = ALIGN(4);
  }
  
  .kdata :
  {
    *(.kdata)
    . = ALIGN(4);
  }



  /*
   * To see if you've exceeded memory, you can
   * check the symbols "_end" for the end of all static
   * data memory, and "_etext" for the end of the code,
   * against your memory map. -- dvb
   */

  /*
   * ------------------------------------------------------------
   * dvb say: "I'll leave all this stuff down here exactly
   * as I found it, for debugging info, without
   * understanding it."
   */

  /* Stabs debugging sections.  */
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .stab.excl 0 : { *(.stab.excl) }
  .stab.exclstr 0 : { *(.stab.exclstr) }
  .stab.index 0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment 0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
  /* These must appear regardless of  .  */
}



