//
//  ABContactsHelper.h
//  AppInfastructure
//
//  Created by Pat Murphy on 4/13/11.
//  Copyright (c) 2013 Fitamatic All rights reserved.
//
#import "ABContactsHelper.h"

@implementation ABContactsHelper

+ (ABAddressBookRef) addressBook
{
    return ABAddressBookCreateWithOptions(NULL, NULL);
}

+ (BOOL)getAccessToContacts
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        // iOS 5 or older
        accessGranted = YES;
    }
    if(!(addressBookRef == NULL))
        CFRelease(addressBookRef);
    
    return accessGranted;
}

+ (NSArray *) contacts
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    NSArray *thePeople = (NSArray *)CFBridgingRelease(arrayRef);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
	for(int contactIndex = 0; contactIndex < [thePeople count]; contactIndex++)
    {
        ABRecordRef person = (__bridge ABRecordRef)([thePeople objectAtIndex:contactIndex]);
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
    }
    //CFRelease(addressBookRef);
	return array;
}

+ (int) validContactsCountOld
{
    //This leaks because ABContact leaks
    int intValue = 0;
    NSArray *contacts = [ABContactsHelper contacts];
    for (ABContact *contact in contacts)
    {
        intValue+=[[contact phoneArray] count];
        intValue+=[[contact emailArray] count];
    }
    return intValue;
}

+ (int) validContactsCount
{
    int intValue = 0;
    @autoreleasepool
    {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        NSArray *contacts = (NSArray *)CFBridgingRelease(arrayRef);
        for(int contactIndex = 0; contactIndex < [contacts count]; contactIndex++)
        {
            ABRecordRef person = (__bridge ABRecordRef)([contacts objectAtIndex:contactIndex]);
            CFTypeRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSArray* phoneArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneProperty));
            CFRelease(phoneProperty);
            CFTypeRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSArray* emailArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailProperty));
            CFRelease(emailProperty);
            intValue += [phoneArray count];
            intValue += [emailArray count];
        }
        if(!(addressBookRef == NULL))
            CFRelease(addressBookRef);
    }
    return intValue;
}

+ (int) contactsCount
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    int intValue = ABAddressBookGetPersonCount(addressBookRef);
    CFRelease(addressBookRef);
    return intValue;
}

+ (int) contactsWithImageCount
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(arrayRef);
	int ncount = 0;
    for(int contactIndex = 0; contactIndex < [peopleArray count]; contactIndex++)
    {
        ABRecordRef person = (__bridge ABRecordRef)([peopleArray objectAtIndex:contactIndex]);
        BOOL contactImageHasData = ABPersonHasImageData(person);
        if(contactImageHasData)
        {
            CFDataRef imageDataRef = ABPersonCopyImageData(person);
            if (!(imageDataRef == NULL))
            {
                ncount++;
                CFRelease(imageDataRef);
            }
        }
    }
    CFRelease(addressBookRef);
	return ncount;
}

+ (int) contactsWithoutImageCount
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(arrayRef);
	int ncount = 0;
    for(int contactIndex = 0; contactIndex < [peopleArray count]; contactIndex++)
    {
        ABRecordRef person = (__bridge ABRecordRef)([peopleArray objectAtIndex:contactIndex]);
        BOOL contactImageHasData = ABPersonHasImageData(person);
        if(!contactImageHasData)
        {
            ncount++;
        }
    }
    CFRelease(addressBookRef);
	return ncount;
}

// Groups
+ (int) numberOfGroups
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllGroups(addressBookRef);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(arrayRef);
	int ncount = peopleArray.count;
    CFRelease(addressBookRef);
	return ncount;
}

+ (NSArray *) groups
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllGroups(addressBookRef);
    NSArray *peopleArray = (NSArray *)CFBridgingRelease(arrayRef);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:peopleArray.count];
    for(int contactIndex = 0; contactIndex < [peopleArray count]; contactIndex++)
    {
        ABRecordRef person = (__bridge ABRecordRef)([peopleArray objectAtIndex:contactIndex]);
		//[array addObject:(__bridge id)((ABRecordRef)person)];
        [array addObject:[ABGroup groupWithRecord:(ABRecordRef)person]];
    }
    CFRelease(addressBookRef);
	return array;
}

// Sorting
+ (BOOL) firstNameSorting
{
	return (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst);
}

#pragma mark Contact Management
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error
{
    CFErrorRef cfError;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    BOOL status = ABAddressBookAddRecord(addressBookRef, aContact.record, &cfError);
    if (status)
    {
        status = ABAddressBookSave(addressBookRef, &cfError);
    }
    CFRelease(addressBookRef);
	return status;
}

+ (BOOL) addGroup: (ABGroup *) aGroup withError: (NSError **) error
{
    CFErrorRef cfError;
    ABAddressBookRef addressBookRef = (ABAddressBookCreateWithOptions(NULL, NULL));
    BOOL status = ABAddressBookAddRecord(addressBookRef, aGroup.record,  &cfError);
    if (status)
    {
        status = ABAddressBookSave(addressBookRef,  &cfError);
    }
    CFRelease(addressBookRef);
	return status;
}

+ (BOOL) addContactToGroup: (ABContact *) aContact toGroup:(ABGroup *) aGroup withError: (NSError **) error
{
    CFErrorRef cfError;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    BOOL status = ABAddressBookAddRecord(addressBookRef, aGroup.record, &cfError);
	if (status)
    {
        status = ABAddressBookSave(addressBookRef, &cfError);
		if (status)
        {
			ABAddressBookAddRecord(addressBookRef, aContact.record, &cfError);
			ABAddressBookSave(addressBookRef,&cfError);
			status = ABGroupAddMember(aGroup.record, aContact.record, &cfError);
			if (status)
            {
		        status = ABAddressBookSave(addressBookRef, &cfError);
			}
		}
	}
    CFRelease(addressBookRef);
	return status;
}

+ (NSArray *) contactsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
	NSArray *filteredContacts  = [contacts filteredArrayUsingPredicate:pred];
	return filteredContacts;
}

+ (NSArray *) contactsMatchingNameAndSuffixWithContacts: (NSString *) fname andName: (NSString *) lname andTitle: (NSString *) title andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ AND lastname contains[cd] %@ AND prefix contains[cd] %@", fname, lname, title];
	NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:pred];
	return filteredContacts;
}

+ (BOOL) matchingNameWithAndSuffixContacts: (NSString *) fname andName: (NSString *) lname andTitle: (NSString *) title andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
    BOOL success = NO;
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ AND lastname contains[cd] %@ AND prefix contains[cd] %@", fname, lname, title];
	NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:pred];
    if([filteredContacts count] > 0)
        success = YES;
	return success;
}

+ (NSArray *) contactsMatchingNameWithContacts: (NSString *) fname andName: (NSString *) lname andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ AND lastname contains[cd] %@ ", fname, lname];
	NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:pred];
	return filteredContacts;
}

+ (BOOL) matchingNameWithContacts: (NSString *) fname andName: (NSString *) lname andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
    BOOL success = NO;
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ AND lastname contains[cd] %@ ", fname, lname];
	NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:pred];
    if([filteredContacts count] > 0)
        success = YES;
	return success;
}

+ (BOOL) matchingOrganizationWithContacts: (NSString *) orgName andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
    BOOL success = NO;
	pred = [NSPredicate predicateWithFormat:@"organization contains[cd] %@", orgName];
	NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:pred];
    if([filteredContacts count] > 0)
        success = YES;
	return success;
}

+ (NSArray *) contactsMatchingOrganizationWithContacts: (NSString *) orgName andContacts:(NSArray*)contacts
{
	NSPredicate *pred;
	pred = [NSPredicate predicateWithFormat:@"organization contains[cd] %@", orgName];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingPhone: (NSString *) number
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) groupsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *groups = [ABContactsHelper groups];
	pred = [NSPredicate predicateWithFormat:@"name MATCHES %@ ", fname];
	return [groups filteredArrayUsingPredicate:pred];
}

+ (BOOL) matchingNameWithGroups: (NSString *) fname andGroups:(NSArray*)groups
{
	NSPredicate *pred;
    BOOL success = NO;
	pred = [NSPredicate predicateWithFormat:@"name MATCHES %@ ", fname];
    groups = [groups filteredArrayUsingPredicate:pred];
    if([groups count] > 0)
        success = YES;
	return success;
}

+(NSString*)randomPhoneNumber
{
    NSString *randomPhoneCountry = @"+1-";
    NSString *randomAreaCodeStr = [[NSNumber numberWithInt:(int)(arc4random() % 800-1) + 200] stringValue];
    NSString *randomPhonePrefixCodeStr = [[NSNumber numberWithInt:(int)(arc4random() % 800-1) + 200] stringValue];
    NSString *randomPhonePostFixCodeStr = [[NSNumber numberWithInt:(int)(arc4random() % 8000-1) + 2000] stringValue];
    NSString *randomPhone = [NSString stringWithFormat:@"%@(%@)-%@-%@",randomPhoneCountry,randomAreaCodeStr,randomPhonePrefixCodeStr,randomPhonePostFixCodeStr];
    return randomPhone;
}

+(NSDictionary*)randomContact
{
    NSDictionary *firstNameDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Pat",@"FirstName_0",@"Paul",@"FirstName_1",@"James",@"FirstName_2",@"Karl",@"FirstName_3",@"Sheffield",@"FirstName_4",@"Ivan",@"FirstName_5",@"Craig",@"FirstName_6",@"Steve",@"FirstName_7",@"Jordon",@"FirstName_8",@"Victoria",@"FirstName_9",@"Alexandria",@"FirstName_10",@"Jacqueline",@"FirstName_11",@"Sally",@"FirstName_12",@"Milley",@"FirstName_13",@"Melissa",@"FirstName_14",@"Callie",@"FirstName_15",@"Mattey",@"FirstName_16",@"Rachael",@"FirstName_17",@"Sandy",@"FirstName_18",@"Monica",@"FirstName_19", nil];
    NSDictionary *lastNameDic = [NSDictionary dictionaryWithObjectsAndKeys:@"urphy",@"LastName_0",@"aptista",@"LastName_1",@"ansom",@"LastName_2",@"anders",@"LastName_3",@"olan",@"LastName_4",@"onald",@"LastName_5",@"abama",@"LastName_6",@"antel",@"LastName_7",@"mith",@"LastName_8",@"ones",@"LastName_9",@"ishop",@"LastName_10",@"itchel",@"LastName_11",@"unn",@"LastName_12",@"alin",@"LastName_13",@"antica",@"LastName_14",@"olly",@"LastName_15",@"ansome",@"LastName_16",@"hipmore",@"LastName_17",@"ates",@"LastName_18",@"ackson",@"LastName_19", nil];
    NSString *alphabet  = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int letter = (int)(arc4random() % [alphabet length]);
    NSRange range;
    range.location = letter;
    range.length = 1;
    NSString *firstLetter = [alphabet substringWithRange:range];
    int randomFirstNameNum = (int)(arc4random() % 19);
    int randomLastNameNum = (int)(arc4random() % 19);
    NSString *randomFirstNameKey = [NSString stringWithFormat:@"FirstName_%d",randomFirstNameNum];
    NSString *randomLastNameKey = [NSString stringWithFormat:@"LastName_%d",randomLastNameNum];
    NSString *lastNameStr = [NSString stringWithFormat:@"%@%@",firstLetter,[lastNameDic objectForKey:randomLastNameKey]];
    NSString *randomPhone = [self randomPhoneNumber];
    NSString *randomEmail = [NSString stringWithFormat:@"%@.%@@appredeem.com",[firstNameDic objectForKey:randomFirstNameKey],lastNameStr];
    NSDictionary *randomNameDic = [NSDictionary dictionaryWithObjectsAndKeys:[firstNameDic objectForKey:randomFirstNameKey],@"FirstName",lastNameStr,@"LastName",randomPhone,@"Phone",randomEmail,@"Email",@"Test",@"MiddleName",nil];
    return randomNameDic;
}

+(void)createRandomContacts
{
    NSArray *contacts = [ABContactsHelper contacts];
    NSLog(@"ABContactsHelper : CreateRandomContacts[%d] ",[contacts count]);
    int maxContacts = 1000;
    for (int index = 0; index<maxContacts; index++)
    {
        ABContact *contact = [ABContact contact];
        NSDictionary *randomContactDic = [self randomContact];
        [contact setFirstname:[randomContactDic objectForKey:@"FirstName"]];
        [contact setLastname:[randomContactDic objectForKey:@"LastName"]];
        //Use the MiddleName to delete these contacts later using deleteAllContacts
        [contact setMiddlename:[randomContactDic objectForKey:@"MiddleName"]];
        NSMutableArray *phoneDicArray = [[NSMutableArray alloc] init];
        NSDictionary *phoneMobileDic = [NSDictionary dictionaryWithObjectsAndKeys:[randomContactDic objectForKey:@"Phone"],@"value",kABPersonPhoneIPhoneLabel,@"label",nil];
        [phoneDicArray addObject:phoneMobileDic];
        [contact setPhoneDictionaries:phoneDicArray];
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        NSMutableDictionary *emailDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [randomContactDic objectForKey:@"Email"],@"value",
                                         @"Email",@"label",
                                         nil];
		[contact setEmailDictionaries:emailDic andMulti:multiEmail];
        CFRelease(multiEmail);
        NSError *error = nil;
        BOOL status = [ABContactsHelper addContact:contact withError:&error];
        NSLog(@"ABContactsHelper : CreateRandomContacts[%d] : Contact : %@ : status = %@ ",index,randomContactDic,status?@"YES":@"NO");
    }
}

+(void)deleteAllContacts
{
    NSArray *contacts = [ABContactsHelper contacts];
    NSError *error = nil;
    for (ABContact *contact in contacts)
    {
        NSString *middleName = [contact middlename];
        if([middleName length] > 0)
        {
            if([middleName isEqualToString:@"Test"])
                [contact removeSelfFromAddressBook:&error];
        }
    }
}

@end