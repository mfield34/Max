/*
 *  $Id$
 *
 *  Copyright (C) 2005, 2006 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "FLACEncoderTask.h"
#import "FLACEncoder.h"
#import "IOException.h"

#include "flacfile.h"					// TagLib::FLAC::File
#include "tag.h"						// TagLib::Tag

@implementation FLACEncoderTask

- (id) initWithTask:(PCMGeneratingTask *)task
{
	if((self = [super initWithTask:task])) {
		_encoderClass = [FLACEncoder class];
		return self;
	}
	return nil;
}

- (void) writeTags
{
	AudioMetadata								*metadata				= [_task metadata];
	NSNumber									*trackNumber			= nil;
	NSString									*album					= nil;
	NSString									*artist					= nil;
	NSString									*title					= nil;
	NSNumber									*year					= nil;
	NSString									*genre					= nil;
	NSString									*comment				= nil;
	TagLib::FLAC::File							f						([_outputFilename UTF8String], false);


	if(NO == f.isValid()) {
		@throw [IOException exceptionWithReason:NSLocalizedStringFromTable(@"Unable to open the output file for tagging", @"Exceptions", @"") userInfo:nil];
	}
	
	// Album title
	album = [metadata valueForKey:@"albumTitle"];
	if(nil != album) {
		f.tag()->setAlbum(TagLib::String([album UTF8String], TagLib::String::UTF8));
	}
	
	// Artist
	artist = [metadata valueForKey:@"trackArtist"];
	if(nil == artist) {
		artist = [metadata valueForKey:@"albumArtist"];
	}
	if(nil != artist) {
		f.tag()->setArtist(TagLib::String([artist UTF8String], TagLib::String::UTF8));
	}
	
	// Genre
	genre = [metadata valueForKey:@"trackGenre"];
	if(nil == genre) {
		genre = [metadata valueForKey:@"albumGenre"];
	}
	if(nil != genre) {
		f.tag()->setGenre(TagLib::String([genre UTF8String], TagLib::String::UTF8));
	}
	
	// Year
	year = [metadata valueForKey:@"trackYear"];
	if(nil == year) {
		year = [metadata valueForKey:@"albumYear"];
	}
	if(nil != year) {
		f.tag()->setYear([year intValue]);
	}
	
	// Comment
	comment = [metadata valueForKey:@"albumComment"];
	if(_writeSettingsToComment) {
		comment = (nil == comment ? [self settings] : [comment stringByAppendingString:[NSString stringWithFormat:@"\n%@", [self settings]]]);
	}
	if(nil != comment) {
		f.tag()->setComment(TagLib::String([comment UTF8String], TagLib::String::UTF8));
	}
	
	// Track title
	title = [metadata valueForKey:@"trackTitle"];
	if(nil != title) {
		f.tag()->setTitle(TagLib::String([title UTF8String], TagLib::String::UTF8));
	}
	
	// Track number
	trackNumber = [metadata valueForKey:@"trackNumber"];
	if(nil != trackNumber) {
		f.tag()->setTrack([trackNumber unsignedIntValue]);
	}
	
	f.save();
}

- (NSString *)		extension						{ return @"flac"; }
- (NSString *)		outputFormat					{ return NSLocalizedStringFromTable(@"FLAC", @"General", @""); }

@end
