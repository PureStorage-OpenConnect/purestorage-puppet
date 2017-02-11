(* -*- coding: utf-8 -*-
Module: Puppet_Device
  Parses /etc/puppetlabs/puppet/device.conf used by a puppet node.

Author:
  Joshua M. Keyes <joshua.michael.keyes@gmail.com>
  Frédéric Lespez <frederic.lespez@free.fr>

About: Reference
  This lens tries to keep as close as possible to the puppet documentation for this file:

    http://docs.puppetlabs.com/puppet/4.3/reference/config_file_device.html

  This lens was based heaily off of the 'PuppetFileserver' lens.

About: License
  This file is licensed under the LGPL v2+, like the rest of Augeas.

About: Lens Usage
  Nothing to see here yet.

About: Configuration Files
  This lens applies to /etc/puppetlabs/puppet/device.conf. See <filter>.
*)

module Puppet_Device =
  autoload xfm

(************************************************************************
 * Group:                 USEFUL PRIMITIVES
  *************************************************************************)

(* Group: INI File settings *)

(* Variable: eol *)
let eol = IniFile.eol

(* Variable: sep
  Only treat one space as the sep, extras are stripped by IniFile *)
let sep = Util.del_str " "

(*
Variable: comment
  Only supports "#" as commentary
  *)
let comment = IniFile.comment "#" "#"

(*
Variable: entry_re
  Regexp for possible <entry> keyword (type, url)
  *)
let entry_re = /type|url/

(************************************************************************
 * Group:                 ENTRY
 *************************************************************************)

(*
View: entry
  - It might be indented with an arbitrary amount of whitespace
  - It does not have any separator between keywords and their values
  - It can only have keywords with the following values (type, url)
*)
let entry = IniFile.indented_entry entry_re sep comment


(************************************************************************
 * Group:                      RECORD
 *************************************************************************)

(* Group: Title definition *)

(*
View: title
  Uses standard INI File title
*)
let title = IniFile.indented_title IniFile.record_re

(*
View: title
  Uses standard INI File record
*)
let record = IniFile.record title entry


(************************************************************************
 * Group:                      LENS
 *************************************************************************)

(*
View: lns
  Uses standard INI File lens
*)
let lns = IniFile.lns record comment

(* Variable: filter *)
let filter = (incl "/etc/puppet/device.conf"
             .incl "/usr/local/etc/puppet/device.conf"
	     .incl "/etc/puppetlabs/puppet/device.conf")

let xfm = transform lns filter
