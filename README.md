# Lingua: Translation Catalog

Lingua is an app for developers who need to manage translated strings.

## Project Details

* Project File: [Lingua.xcodeproj](Lingua.xcodeproj)
* Scheme Name: **Lingua**
* Minimum iOS SDK: **18.0**
* Minimum macOS SDK: **15.0**

| Config  | Bundle ID                | Distribution | Debug |
| ------- | ------------------------ | ------------ | ----- |
| Debug   | com.richardpiazza.lingua | Local        | TRUE  |
| Release | com.richardpiazza.lingua | App Store    | FALSE |

## Release Planning

Multiple iterations are already planned for Lingua, but a MVP is needed to determine feature viability. The base feature set includes:
* [x] _Project_, _Expression_, and _Translation_ management.
* [x] Filesystem url (macOS-only)
* [x] Generate Apple & Android strings files
* [x] Import Apple & Android strings files

Priority Next Features:
* Translation State: 'not-translated'/'translated'.
* String Catalog import/export.
* Specialty Queries:
  * Expressions without a Translation
	* Expressions without all Locales
	* Expressions with un-translated values

Additional Features are planned:
* Pluralization Support (Vary by Plural)
* Device Variants (Vary by Device)
* Document-Based App
* CloudKit Syncing
* 'Team' sharing of CloudKit containers?
* 'Team' usage through managed API
* Additional file-based _Catalog_ types for SVN

## Beta Phase

Features should be implemented in a way that allows for development to move forward quickly.
The initial implementation will use the Sandbox DB only. (After "export", an initial beta may be considered)

* [x] General Pane-Style Interface Layout
* [x] Expression List
* [x] Expression Management (create/delete)
* [x] Translation List
* [x] Translation Management (create/delete)
* [x] Project List
* [x] Project Management (create/delete)
* [x] Link/Unlink Expression to Project
* [x] Import Files (non-linked/project-linked)
* [x] Export Files (all-expressions/project-expressions)
* [x] Select Catalog (filesystem-macOS)
* ~[ ] Select Catalog (CloudKit)~
