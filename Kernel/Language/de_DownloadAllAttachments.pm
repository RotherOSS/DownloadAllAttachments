# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.io/
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

    # Template: ArticleAttachments
    $Self->{Translation}->{'Download all \(zip\)'} = '';

    # Perl Module: Kernel/Output/HTML/TicketMenu/DownloadAllAttachments.pm
    $Self->{Translation}->{'Download ticket attachments'} = '';
    $Self->{Translation}->{'Download all attachments as one zip file'} = '';

    # SysConfig
    $Self->{Translation}->{'Autoloading of DownloadAttachment extensions.'} = '';
    $Self->{Translation}->{'This configuration registers a link in the ticket menu to download all ticket attachments.'} =
        '';
    $Self->{Translation}->{'This configuration registers a link in the ticket menu to the ticket overviews of the agent interface to download all ticket attachments.'} =
        '';


    push @{ $Self->{JavaScriptStrings} // [] }, (
    );

}

1;
