# Lingua: Translation Catalog

Lingua is an app for developers who need to manage translated strings.

## Release Planning

Multiple iterations are already planned for Lingua, but a MVP is needed to determine feature viability. The base feature set includes:
* [ ] _Project_, _Expression_, and _Translation_ management.
* [ ] Sandbox db
* [ ] CloudKit syncing
* [ ] Filesystem url (macOS-only)
* [ ] Generate Apple & Android strings files
* [ ] Import Apple & Android strings files

Additional Features are planned:
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
* [ ] Link/Unlink Expression to Project
* [ ] Import Files (non-linked/project-linked)
* [ ] Export Files (all-expressions/project-expressions)
* [ ] Select Catalog (filesystem-macOS)
* [ ] Select Catalog (CloudKit)
