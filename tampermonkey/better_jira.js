// ==UserScript==
//
// @name           Better Jira
// @description    Updates the JIRA UI to improve its usability
// @namespace      https://greasyfork.org/users/3766-thangtran
// @author         Ofir Gal (https://github.com/ofirgall)
// @license        GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)
// @version        1.0
// @include        https://*jira*/*
// @run-at document-start
// @grant          GM_addStyle
//
// ==/UserScript==

GM_addStyle ( `
    .jira-dialog {
  width: 95% !important;
  margin-left: 0px !important;
  left: 2.5% !important;
  top: 2.5% !important;
  margin-top: 0px !important;
  height: 95% !important;
    }
` );
