<?xml version="1.0" encoding="iso-8859-1"?>
<!-- $Revision: 1.1 $ -->

<section xml:id="{EXT_NAME_ID}.configuration" xmlns="http://docbook.org/ns/docbook">
 &reftitle.runtime;
 &extension.runtime;
 <para>
  <table>
   <title>{EXT_NAME} &ConfigureOptions;</title>
   <tgroup cols="4">
    <thead>
     <row>
      <entry>&Name;</entry>
      <entry>&Default;</entry>
      <entry>&Changeable;</entry>
      <entry>Changelog</entry>
     </row>
    </thead>
    {INI_ENTRIES}
   </tgroup>
  </table>
 </para>

 &ini.descriptions.title;

 <para>
  <variablelist>
   {INI_ENTRIES_DESCRIPTION}
  </variablelist>
 </para>
</section>