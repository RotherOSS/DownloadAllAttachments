# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
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

package Kernel::Output::HTML::TicketMenu::DownloadAllAttachments;

use parent 'Kernel::Output::HTML::Base';

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    # check needed stuff
    if ( !$Param{Ticket} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need Ticket!'
        );
        return;
    }

    # check Lock permission
    my $AccessOk = $TicketObject->TicketPermission(
        Type     => 'ro',
        TicketID => $Param{Ticket}->{TicketID},
        UserID   => $Self->{UserID},
        LogNo    => 1,
    );
    return if !$AccessOk;

    my $TicketID = $Param{Ticket}->{TicketID};

    my @ArticleIDs = $ArticleObject->ArticleIndex(
        TicketID => $TicketID,
    );

    return if !@ArticleIDs;

    # strip html and ascii attachments of content
    my %StripParams;
    if ( $LayoutObject->{BrowserRichText} ) {
        $StripParams{ExcludePlainText} = 1;
        $StripParams{ExcludeHTMLBody}  = 1;
        $StripParams{ExcludeInline}    = 1;
        $StripParams{OnlyHTMLBody}     = 0;
    }
    else {
        $StripParams{ExcludePlainText} = 1;
        $StripParams{ExcludeHTMLBody}  = 0;
        $StripParams{ExcludeInline}    = 0;
        $StripParams{OnlyHTMLBody}     = 0;
    }

    my $AttachmentExists = 0;

    ARTICLE:
    for my $ArticleID ( sort @ArticleIDs ) {

        my %Article = $ArticleObject->ArticleGet(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );

        # get attachment index (without attachments)
        my %AttachmentIndex = $ArticleObject->ArticleAttachmentIndex(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
            UserID    => $Self->{UserID},
            %StripParams,
        );

        next ARTICLE if !%AttachmentIndex;

        FILEID:
        for my $FileID ( sort keys %AttachmentIndex ) {

            # get a attachment
            my %Attachment = $ArticleObject->ArticleAttachment(
                TicketID  => $TicketID,
                ArticleID => $ArticleID,
                FileID    => $FileID,
                UserID    => $Self->{UserID},
            );

            next FILEID if !%Attachment;
            $AttachmentExists = 1;
            last ARTICLE if $AttachmentExists;
        }
    }

    # at least one attachment must be present
    return if !$AttachmentExists;

    return {
        %{ $Param{Config} },
        %{ $Param{Ticket} },
        %Param,
        Name        => Translatable('Download ticket attachments'),
        Description => Translatable('Download all attachments as one zip file'),
        Link        =>
            'Action=AgentTicketDownloadAllAttachments;TicketID=[% Data.TicketID | html %];RedirectToSearch=1;[% Env("ChallengeTokenParam") | html %]',
    };
}

1;
