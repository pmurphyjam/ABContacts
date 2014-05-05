//
//  ABGroup.h
//  AppInfastructure
//
//  Created by Pat Murphy on 8/23/13.
//  Copyright (c) 2013 Fitamatic All rights reserved.
//

#import "ABGroup.h"
#import "ABContactsHelper.h"


@implementation ABGroup
@synthesize record;

- (id) initWithRecord: (ABRecordRef) aRecord
{
	if (self = [super init])
        record = CFRetain(aRecord);
	return self;
}

+ (id) groupWithRecord: (ABRecordRef) grouprec
{
	return [[ABGroup alloc] initWithRecord:grouprec];
}

+ (ABAddressBookRef) addressBook
{
	return ABAddressBookCreateWithOptions(NULL, NULL);
}

+ (id) groupWithRecordID: (ABRecordID) recordID
{
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	ABRecordRef grouprec = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
	ABGroup *group = [self groupWithRecord:grouprec];
	return group;
}

+ (id) group
{
	ABRecordRef grouprec = ABGroupCreate();
	id group = [ABGroup groupWithRecord:grouprec];
	CFRelease(grouprec);
	return group;
}

- (BOOL) removeSelfFromAddressBook: (NSError **) error
{
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFErrorRef cfError = nil;
    BOOL status = ABAddressBookRemoveRecord(addressBook, self.record, &cfError);
    if (status)
    {
        status = ABAddressBookSave(addressBook,  &cfError);
        CFRelease(addressBook);
    }
    
	return status;
}

#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark management
- (NSArray *) members
{
	NSArray *contacts = (__bridge NSArray *)ABGroupCopyArrayOfAllMembers(self.record);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
	for (id contact in contacts)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
	return array;
}

// kABPersonSortByFirstName = 0, kABPersonSortByLastName  = 1
- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering
{
	NSArray *contacts = (__bridge NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(self.record, ordering);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
	for (id contact in contacts)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
	return array;
}

- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef cfError = nil;
	return ABGroupAddMember(self.record, contact.record, &cfError);
}

- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef cfError = nil;
	return ABGroupRemoveMember(self.record, contact.record, &cfError);
}

#pragma mark name

- (NSString *) getRecordString:(ABPropertyID) anID
{
	return (__bridge NSString *) ABRecordCopyValue(record, anID);
}

- (NSString *) name
{
	NSString *string = (__bridge NSString *)ABRecordCopyCompositeName(record);
	return string;
}

- (void) setName: (NSString *) aString
{
	CFErrorRef error = nil;
    CFStringRef stringRef = (__bridge CFStringRef) aString;
	BOOL success = ABRecordSetValue(record, kABGroupNameProperty, stringRef, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
}
@end
