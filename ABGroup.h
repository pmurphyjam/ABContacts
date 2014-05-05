//
//  ABGroup.h
//  AppInfastructure
//
//  Created by Pat Murphy on 4/13/11.
//  Copyright (c) 2013 Fitamatic All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ABContact.h"

@interface ABGroup : NSObject 
{
	ABRecordRef record;
}

+ (ABAddressBookRef) addressBook;
+ (id) group;
+ (id) groupWithRecord: (ABRecordRef) record;
+ (id) groupWithRecordID: (ABRecordID) recordID;
- (BOOL) removeSelfFromAddressBook: (NSError **) error;

@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering;
- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error;
- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error;

@property (nonatomic, assign) NSString *name;
@property (nonatomic, readonly) NSArray *members; 

@end
