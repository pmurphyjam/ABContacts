//
//  ABContactsHelper.h
//  AppInfastructure
//
//  Created by Pat Murphy on 4/13/11.
//  Copyright (c) 2013 Fitamatic All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ABContact.h"
#import "ABGroup.h"

@interface ABContactsHelper : NSObject

+ (ABAddressBookRef) addressBook;
// Address Book Contacts and Groups
+ (NSArray *) contacts; // people
+ (NSArray *) groups; // groups

+ (BOOL)getAccessToContacts;

// Counting
+ (int) validContactsCount;
+ (int) contactsCount;
+ (int) contactsWithImageCount;
+ (int) contactsWithoutImageCount;
+ (int) numberOfGroups;

// Sorting
+ (BOOL) firstNameSorting;

// Add contacts and groups
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error;
+ (BOOL) addGroup: (ABGroup *) aGroup withError: (NSError **) error;
+ (BOOL) addContactToGroup: (ABContact *) aContact toGroup:(ABGroup *) aGroup withError: (NSError **) error;

// Find contacts
+ (NSArray *) contactsMatchingName: (NSString *) fname;
+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname;
+ (BOOL) matchingNameWithContacts: (NSString *) fname andName: (NSString *) lname andContacts:(NSArray*)contacts;
+ (NSArray *) contactsMatchingNameWithContacts: (NSString *) fname andName: (NSString *) lname andContacts:(NSArray*)contacts;
+ (BOOL) matchingNameWithAndSuffixContacts: (NSString *) fname andName: (NSString *) lname andTitle: (NSString *) title andContacts:(NSArray*)contacts;
+ (NSArray *) contactsMatchingNameAndSuffixWithContacts: (NSString *) fname andName: (NSString *) lname andTitle: (NSString *) title andContacts:(NSArray*)contacts;
+ (BOOL) matchingOrganizationWithContacts: (NSString *) orgName andContacts:(NSArray*)contacts;
+ (NSArray *) contactsMatchingOrganizationWithContacts: (NSString *) orgName andContacts:(NSArray*)contacts;
+ (NSArray *) contactsMatchingPhone: (NSString *) number;

// Find groups
+ (NSArray *) groupsMatchingName: (NSString *) fname;
+ (BOOL) matchingNameWithGroups: (NSString *) fname andGroups:(NSArray*)groups;

+(void)createRandomContacts;
+(void)deleteAllContacts;

@end

@interface NSString (cstring)
@property (readonly) char *UTF8String;
@end