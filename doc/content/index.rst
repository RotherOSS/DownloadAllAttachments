.. image:: ../images/otobo-logo.png
   :align: center
|

.. toctree::
    :maxdepth: 2
    :caption: Contents

Sacrifice to Sphinx
===================

Description
===========
Enables download of all ticket or article attachments as a single zip file.

Functionality
=============

Download multiple attachments as single zip file
________________________________________________

This package extends Znuny with the functionality to download all attachments of a ticket or article as a single zip file.

Ticket attachments can be downloaded via the new link 'Download ticket attachments' in the ticket menu of the ticket zoom view. The filename will have the following pattern: 'Attachments Ticket *TicketNummer*.zip'.

To download all attachments of an article as a single zip file the new link 'Download all (zip)' was added on top of the attachment list in the article attachments box. The filename will have the following pattern: 'Attachments Ticket *TicketNummer* ArticleID *ArticleID*.zip'.

System requirements
===================

Framework
---------
OTOBO 10.1.x

Packages
--------
\-

Third-party software
--------------------
- Archive::Zip

Configuration Reference
=======================

Core::Autoload
------------------------------------------------------------------------------------------------------------------------------

AutoloadPerlPackages###200-DownloadAttachment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Autoloading of DownloadAttachment extensions.

Frontend::Agent::ModuleRegistration
------------------------------------------------------------------------------------------------------------------------------

Frontend::Module###AgentTicketDownloadAllAttachments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Frontend module registration for the agent interface.

Frontend::Agent::TicketOverview::MenuModule
------------------------------------------------------------------------------------------------------------------------------

Ticket::Frontend::PreMenuModule###990-DownloadAllAttachments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This configuration registers a link in the ticket menu to the ticket overviews of the agent interface to download all ticket attachments.

Frontend::Agent::View::TicketZoom::MenuModule
------------------------------------------------------------------------------------------------------------------------------

Ticket::Frontend::MenuModule###001-DownloadAllAttachments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This configuration registers a link in the ticket menu to download all ticket attachments.

About
=======

Contact
-------
| Rother OSS GmbH
| Email: hello@otobo.de
| Web: https://otobo.de

Version
-------
Author: |doc-vendor| / Version: |doc-version| / Date of release: |doc-datestamp|
