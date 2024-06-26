# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.de/
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

package Kernel::Modules::AgentTicketDownloadAllAttachments;

use strict;
use warnings;

use Encode;
use Archive::Zip qw( :ERROR_CODES );

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Encode',
    'Kernel::System::FileTemp',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ArticleObject  = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $EncodeObject   = $Kernel::OM->Get('Kernel::System::Encode');
    my $FileTempObject = $Kernel::OM->Get('Kernel::System::FileTemp');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject      = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject   = $Kernel::OM->Get('Kernel::System::Ticket');

    my %GetParam;
    for my $Param (qw(TicketID ArticleID Subaction)) {

        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param );
    }

    if (
        !$GetParam{TicketID}
        && !$GetParam{ArticleID}
        )
    {
        $LayoutObject->FatalError(
            Message => "Need TicketID or ArticleID!",
        );
    }

    my $TicketID = $GetParam{TicketID};

    # Found no Article ID and no Ticket ID was passed to the Method.
    # Throw an error.
    if ( !$TicketID ) {
        $LogObject->Log(
            Message  => "No TicketID for ArticleID ($Self->{ArticleID})!",
            Priority => 'error',
        );
        return $LayoutObject->ErrorScreen();
    }

    # Check permissions
    my $TicketPermission = $TicketObject->TicketPermission(
        Type     => 'ro',
        TicketID => $TicketID,
        UserID   => $Self->{UserID},
    );
    if ( !$TicketPermission ) {
        return $LayoutObject->NoPermission( WithHeader => 'yes' );
    }

    my @ArticleIDs = $ArticleObject->ArticleIndex(
        TicketID => $TicketID,
    );

    my $TicketNumber = $TicketObject->TicketNumberLookup(
        TicketID => $TicketID,
        UserID   => $Self->{UserID},
    );

    my $ZipFilename = 'Attachments Ticket ' . $TicketNumber;

    # validate ArticleID parameter
    if ( $GetParam{ArticleID} ) {

        if ( !scalar grep { $GetParam{ArticleID} eq $_ } @ArticleIDs ) {

            $LayoutObject->FatalError(
                Message => "Can't find ArticleID '$GetParam{ArticleID}' of ticket with TicketID '$TicketID'!",
            );
        }

        $ZipFilename .= ' - ArticleID ' . $GetParam{ArticleID};

        # only use the article requested
        @ArticleIDs = ( $GetParam{ArticleID} );
    }

    # create zip object
    my $Zip = Archive::Zip->new();

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

    my %AttachmentNames;

    # collect attachments
    ARTICLE:
    for my $ArticleID ( sort @ArticleIDs ) {

        my %Article = $ArticleObject->ArticleGet(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );

        if ( !%Article ) {
            $LayoutObject->FatalError(
                Message => "Error while article with ArticleID '$ArticleID'!",
            );
        }

        # get attachment index (without attachments)
        my %AttachmentIndex = $ArticleObject->ArticleAttachmentIndex(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
            UserID    => $Self->{UserID},
            %StripParams,
        );

        FILEID:
        for my $FileID ( sort keys %AttachmentIndex ) {

            # get a attachment
            my %Attachment = $ArticleObject->ArticleAttachment(
                TicketID  => $TicketID,
                ArticleID => $ArticleID,
                FileID    => $FileID,
                UserID    => $Self->{UserID},
            );

            if ( !%Attachment ) {
                $LayoutObject->FatalError(
                    Message =>
                        "Error while getting attachment with FileID '$FileID' of article with ArticleID '$ArticleID'!",
                );
            }

            my $Filename = $Attachment{Filename};

            # remove bad chars like e.g. newline from filename
            $Filename =~ s{\n}{ }xmsg;
            $Filename =~ s{\r}{ }xmsg;

            # check if filename is already present in zip archive
            # to avoid conflicts add ' (*counter*)' suffix to filename
            if ( !$AttachmentNames{$Filename} ) {
                $AttachmentNames{$Filename} = 1;
            }
            else {
                # add before file extension
                $Filename =~ s{(\.)([^\.]+)\z}{ ($AttachmentNames{ $Filename })$1$2}xms;

                # check if the suffix was added correctly
                # otherwise add it to the end
                if ( $Filename eq $Attachment{Filename} ) {
                    $Filename .= " ($AttachmentNames{ $Filename })";
                }

                # increase counter for this filename
                $AttachmentNames{$Filename}++;
            }

            # encode filename and content
            # otherwise it may break the zip file
            Encode::_utf8_on($Filename);
            $EncodeObject->EncodeOutput( \$Filename );

            Encode::_utf8_on( $Attachment{Content} );
            $EncodeObject->EncodeOutput( \$Attachment{Content} );

            # add to zip file
            $Zip->addString( $Attachment{Content}, $Filename );
        }
    }

    # write tmp file
    my ( $FH, $Filename ) = $FileTempObject->TempFile();

    if ( open( my $ZipFH, '>', $Filename ) ) {    ## no critic qw(OTOBO::ProhibitOpen)

        if ( $Zip->writeToFileHandle($ZipFH) != AZ_OK ) {    ## nofilter(TidyAll::Plugin::OTOBO::Perl::SyntaxCheck)
            $LayoutObject->FatalError(
                Message => "Cant write temporary zip file '$Filename': $!!",
            );
        }
        close $ZipFH;
    }
    else {
        $LayoutObject->FatalError(
            Message => "Cant write temporary zip file '$Filename': $!!",
        );
    }

    my $Content = '';
    if ( open( my $ZipFH, "<", $Filename ) ) {    ## no critic qw(OTOBO::ProhibitOpen)
        while (<$ZipFH>) {
            $Content .= $_;
        }
        close $ZipFH;
    }
    else {
        return $LayoutObject->FatalError(
            Message => "Can't open temporary zip file '$Filename': $!",
        );
    }

    if ( !$Content ) {
        return $LayoutObject->FatalError(
            Message => "Error while reading from temporary zip file handle!",
        );
    }

    # return new page
    return $LayoutObject->Attachment(
        Filename    => $ZipFilename . '.zip',
        ContentType => 'application/zip',
        Content     => $Content,
        NoCache     => 1,
    );
}

1;
