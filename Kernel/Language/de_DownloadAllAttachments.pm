# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# Copyright (C) 2021-2024 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::Language::de_DownloadAllAttachments;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    # SysConfigs
    $Self->{Translation}->{"This configuration registers a link in the ticket menu to download all ticket attachments."}
        = "Diese Konfiguration registriert einen Link im Ticket-Menü, um alle Ticket-Anhänge herunterzuladen.";
    $Self->{Translation}
        ->{"This configuration registers a link in the ticket menu to the ticket overviews of the agent interface to download all ticket attachments."}
        = "Diese Konfiguration registriert einen Link im Ticket-Menü in den Ticket-Übersichten, um alle Ticket-Anhänge herunterzuladen.";

    $Self->{Translation}->{"Download all (zip)"}                            = "Alle herunterladen (Zip)";
    $Self->{Translation}->{"Download ticket attachments"}                   = "Ticket-Anhänge herunterladen";
    $Self->{Translation}->{"Download all attachments as one zip file"}      = "Alle Ticket-Anhänge in einer Zip-Datei herunterladen";
    $Self->{Translation}->{"Download multiple attachments as one zip file"} = "Mehrere Ticket-Anhänge in einer Zip-Datei herunterladen";

    return 1;
}

1;
