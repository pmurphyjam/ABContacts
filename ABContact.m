//
//  ABContact.h
//  AppInfastructure
//
//  Created by Pat Murphy on 4/13/11.
//  Copyright (c) 2013 Fitamatic All rights reserved.
//

#import "ABContact.h"
#import "ABContactsHelper.h"

@implementation ABContact

@synthesize record;

- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init])
        record =  CFRetain(aRecord);

	return self;
}

+ (id) contactWithRecord: (ABRecordRef) person
{
    ABContact *contact = [[ABContact alloc] initWithRecord:person];
    return contact;
}

+ (ABAddressBookRef) addressBook
{
    return ABAddressBookCreateWithOptions(NULL, NULL);
}

+ (id) contactWithRecordID: (NSNumber*) recordID
{
    ABAddressBookRef addressBook = (ABAddressBookCreateWithOptions(NULL, NULL));
	ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(addressBook, [recordID intValue]);
    CFRelease(addressBook);
	ABContact *contact = nil;
	if(contactrec != nil)
    {
		contact = [self contactWithRecord:contactrec];
	}
	return contact;
}

+ (id) contact
{
	ABRecordRef person = ABPersonCreate();
	id contact = [ABContact contactWithRecord:person];
	CFRelease(person);
	return contact;
}

#pragma mark utilities
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty
{
    NSString* propertyName = CFBridgingRelease(ABPersonCopyLocalizedPropertyName(aProperty));
    return propertyName;
}

+ (ABPropertyType) propertyType: (ABPropertyID) aProperty
{
	return ABPersonGetTypeOfProperty(aProperty);
}

+ (NSString *) propertyTypeString: (ABPropertyID) aProperty
{
	switch (ABPersonGetTypeOfProperty(aProperty))
	{
		case kABInvalidPropertyType: return @"Invalid Property";
		case kABStringPropertyType: return @"String";
		case kABIntegerPropertyType: return @"Integer";
		case kABRealPropertyType: return @"Float";
		case kABDateTimePropertyType: return @"Date";
		case kABDictionaryPropertyType: return @"Dictionary";
		case kABMultiStringPropertyType: return @"Multi String";
		case kABMultiIntegerPropertyType: return @"Multi Integer";
		case kABMultiRealPropertyType: return @"Multi Float";
		case kABMultiDateTimePropertyType: return @"Multi Date";
		case kABMultiDictionaryPropertyType: return @"Multi Dictionary";
		default: return @"Invalid Property";
	}
}

+ (NSString *) propertyString: (ABPropertyID) aProperty
{
	if (aProperty == kABPersonFirstNameProperty) return @"First Name";
	if (aProperty == kABPersonLastNameProperty) return @"Last Name";
	if (aProperty == kABPersonMiddleNameProperty) return @"Middle Name";
	if (aProperty == kABPersonPrefixProperty) return @"Prefix";
	if (aProperty == kABPersonSuffixProperty) return @"Suffix";
	if (aProperty == kABPersonNicknameProperty) return @"Nickname";
	if (aProperty == kABPersonFirstNamePhoneticProperty) return @"Phonetic First Name";
	if (aProperty == kABPersonLastNamePhoneticProperty) return @"Phonetic Last Name";
	if (aProperty == kABPersonMiddleNamePhoneticProperty) return @"Phonetic Middle Name";
	if (aProperty == kABPersonOrganizationProperty) return @"Organization";
	if (aProperty == kABPersonJobTitleProperty) return @"Job Title";
	if (aProperty == kABPersonDepartmentProperty) return @"Department";
	if (aProperty == kABPersonEmailProperty) return @"Email";
	if (aProperty == kABPersonBirthdayProperty) return @"Birthday";
	if (aProperty == kABPersonNoteProperty) return @"Note";
	if (aProperty == kABPersonCreationDateProperty) return @"Creation Date";
	if (aProperty == kABPersonModificationDateProperty) return @"Modification Date";
	if (aProperty == kABPersonAddressProperty) return @"Address";
	if (aProperty == kABPersonDateProperty) return @"Date";
	if (aProperty == kABPersonKindProperty) return @"Kind";
	if (aProperty == kABPersonPhoneProperty) return @"Phone";
	if (aProperty == kABPersonInstantMessageProperty) return @"Instant Message";
	if (aProperty == kABPersonURLProperty) return @"URL";
	if (aProperty == kABPersonRelatedNamesProperty) return @"Related Name";
	return nil;
}

+ (BOOL) propertyIsMultivalue: (ABPropertyID) aProperty;
{
	if (aProperty == kABPersonFirstNameProperty) return NO;
	if (aProperty == kABPersonLastNameProperty) return NO;
	if (aProperty == kABPersonMiddleNameProperty) return NO;
	if (aProperty == kABPersonPrefixProperty) return NO;
	if (aProperty == kABPersonSuffixProperty) return NO;
	if (aProperty == kABPersonNicknameProperty) return NO;
	if (aProperty == kABPersonFirstNamePhoneticProperty) return NO;
	if (aProperty == kABPersonLastNamePhoneticProperty) return NO;
	if (aProperty == kABPersonMiddleNamePhoneticProperty) return NO;
	if (aProperty == kABPersonOrganizationProperty) return NO;
	if (aProperty == kABPersonJobTitleProperty) return NO;
	if (aProperty == kABPersonDepartmentProperty) return NO;
	if (aProperty == kABPersonBirthdayProperty) return NO;
	if (aProperty == kABPersonNoteProperty) return NO;
	if (aProperty == kABPersonCreationDateProperty) return NO;
	if (aProperty == kABPersonModificationDateProperty) return NO;
	
	
	if (aProperty == kABPersonEmailProperty) return YES;
	if (aProperty == kABPersonAddressProperty) return YES;
	if (aProperty == kABPersonDateProperty) return YES;
	if (aProperty == kABPersonPhoneProperty) return YES;
	if (aProperty == kABPersonInstantMessageProperty) return YES;
	if (aProperty == kABPersonURLProperty) return YES;
	if (aProperty == kABPersonRelatedNamesProperty) return YES;
    
    return YES;
}

+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
	// Recover the property for a given record
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSArray *items = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(theProperty));
	CFRelease(theProperty);
	return items;
}

+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    return CFBridgingRelease(ABRecordCopyValue(record, anID));
}

+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (value) [dict setObject:value forKey:@"value"];
	if (label) [dict setObject:(__bridge NSString *)label forKey:@"label"];
	return dict;
}

+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code
{
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
	if (street) [md setObject:street forKey:(NSString *) kABPersonAddressStreetKey];
	if (city) [md setObject:city forKey:(NSString *) kABPersonAddressCityKey];
	if (state) [md setObject:state forKey:(NSString *) kABPersonAddressStateKey];
	if (zip) [md setObject:zip forKey:(NSString *) kABPersonAddressZIPKey];
	if (country) [md setObject:country forKey:(NSString *) kABPersonAddressCountryKey];
	if (code) [md setObject:code forKey:(NSString *) kABPersonAddressCountryCodeKey];
	return md;
}

+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) smugName
{
	NSMutableDictionary *sms = [NSMutableDictionary dictionary];
	if (service) [sms setObject:(__bridge NSString *) service forKey:(NSString *) kABPersonInstantMessageServiceKey];
	if (smugName) [sms setObject:smugName forKey:(NSString *) kABPersonInstantMessageUsernameKey];
	return sms;
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
- (BOOL) isCompany {
	BOOL status = NO;
	CFNumberRef recordTypeRef = ABRecordCopyValue(self.record, kABPersonKindProperty);
	if (recordTypeRef == kABPersonKindOrganization)
		status = YES;
	CFRelease(recordTypeRef);
	return status;
}

#pragma mark Getting Single Value Strings
- (NSString *) getRecordString:(ABPropertyID) anID
{
    return CFBridgingRelease(ABRecordCopyValue(record, anID));
}

- (NSString *) firstname {return [self getRecordString:kABPersonFirstNameProperty];}
- (NSString *) lastname {return [self getRecordString:kABPersonLastNameProperty];}
- (NSString *) middlename {return [self getRecordString:kABPersonMiddleNameProperty];}
- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}
- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) organization {return [self getRecordString:kABPersonOrganizationProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}
- (NSString *) company {return [self getRecordString:kABPersonKindProperty];}


#pragma mark Contact Name Utility
- (NSString *) contactName
{
	NSMutableString *string = [NSMutableString string];
	
	if (self.firstname || self.lastname)
	{
		if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
		if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
		if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
		if (self.lastname) [string appendFormat:@"%@", self.lastname];
		
		if (self.suffix && string.length)
			[string appendFormat:@", %@ ", self.suffix];
		else
			[string appendFormat:@" "];
	}
	
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) compositeName
{
    NSString* string = CFBridgingRelease(ABRecordCopyCompositeName(record));
	return string;
}

#pragma mark Dates
- (NSDate *) getRecordDate:(ABPropertyID) anID
{
    NSDate* date = CFBridgingRelease(ABRecordCopyValue(record,anID));
    return date;
}

- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}

#pragma mark Getting MultiValue Elements
- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSArray* items = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(theProperty));
	CFRelease(theProperty);
	return items;
}

- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
	CFTypeRef theProperty = ABRecordCopyValue(record, anID);
	NSMutableArray *labels = [NSMutableArray array];
	for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
	{
        NSString* label = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(theProperty,i));
		[labels addObject:label];
	}
	CFRelease(theProperty);
	return labels;
}

- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}
- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}
- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}
- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}
- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}
- (NSArray *) smsArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) smsLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}

- (NSString *) phonenumbers {return [self.phoneArray componentsJoinedByString:@" "];}
- (NSString *) emailaddresses {return [self.emailArray componentsJoinedByString:@" "];}
- (NSString *) urls {return [self.urlArray componentsJoinedByString:@" "];}

- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
	NSArray *valueArray = [self arrayForProperty:aProperty];
	NSArray *labelArray = [self labelsForProperty:aProperty];
	
	int num = MIN(valueArray.count, labelArray.count);
	NSMutableArray *items = [NSMutableArray array];
	for (int i = 0; i < num; i++)
	{
		NSMutableDictionary *md = [NSMutableDictionary dictionary];
		[md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
		[md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
		[items addObject:md];
	}
	return items;
}

- (NSMutableDictionary *) dictionaryForProperty: (ABPropertyID) aProperty
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    return md;
}

- (NSArray *) emailDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}

- (NSArray *) phoneDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}

- (NSArray *) relatedNameDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}

- (NSArray *) urlDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonURLProperty];
}

- (NSArray *) dateDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonDateProperty];
}

- (NSArray *) smsDictionaries
{
	return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}

#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
	CFErrorRef error = nil;
    CFStringRef stringRef = (__bridge CFStringRef) aString;
    BOOL success = ABRecordSetValue(record, anID, stringRef, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
	return success;
}

- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}
- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}
- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}

- (void) setCompany: (NSString *) aString {[self setString: aString forProperty: kABPersonKindProperty];}

#pragma mark Setting Dates

- (BOOL) setDate: (NSDate *) aDate forProperty:(ABPropertyID) anID
{
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, anID, (__bridge CFDateRef) aDate, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
	return success;
}

- (void) setBirthday: (NSDate *) aDate {[self setDate: aDate forProperty: kABPersonBirthdayProperty];}

#pragma mark Setting MultiValue

- (BOOL) setMulti: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, anID, multi, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
	return success;
}

- (void) setAddressDictionaries: (NSMutableDictionary *) dictionaries andMulti:(ABMutableMultiValueRef)multi
{
    CFStringRef propertyType = (__bridge CFTypeRef)[dictionaries objectForKey:@"PropertyLabel"];
    [dictionaries removeObjectForKey:@"PropertyLabel"];
    // PropertyLabel : kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
	// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
    //ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(dictionaries), propertyType, NULL);
	[self setMulti:multi forProperty:kABPersonAddressProperty];
}

- (void) setEmailDictionaries: (NSMutableDictionary *) dictionaries andMulti:(ABMutableMultiValueRef)multi;
{
	// kABPersonEmailProperty
	ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dictionaries objectForKey:@"value"], (__bridge CFTypeRef) [dictionaries objectForKey:@"label"], NULL);
	[self setMulti:multi forProperty:kABPersonEmailProperty];
}

- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
	// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in dictionaries) {
		ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
	}
	[self setMulti:multi forProperty:kABPersonPhoneProperty];
	CFRelease(multi);
}

- (void) setUrlDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonHomePageLabel
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in dictionaries) {
		ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
	}
	[self setMulti:multi forProperty:kABPersonURLProperty];
	CFRelease(multi);
}

// Not used/shown on iPhone
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel,
	// kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel,
	// kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel,
	// kABPersonManagerLabel, kABPersonAssistantLabel
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in dictionaries) {
		ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
	}
	[self setMulti:multi forProperty:kABPersonRelatedNamesProperty];
	CFRelease(multi);
}

- (void) setDateDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel
	// kABPersonAnniversaryLabel
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in dictionaries) {
		ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
	}
	[self setMulti:multi forProperty:kABPersonDateProperty];
	CFRelease(multi);
}

- (void) setSmsDictionaries: (NSArray *) dictionaries
{
	// kABWorkLabel, kABHomeLabel, kABOtherLabel,
	// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
	// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
	// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
	// kABPersonInstantMessageServiceAIM,
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in dictionaries) {
		ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
	}
	[self setMulti:multi forProperty:kABPersonInstantMessageProperty];
	CFRelease(multi);
}

#pragma mark Images
- (NSData *) imageData
{
	if (!ABPersonHasImageData(record)) return nil;
	CFDataRef imageDataRef = ABPersonCopyImageData(record);
    if (imageDataRef == NULL) return nil;
    NSData *imageData = [NSData dataWithData:(__bridge NSData *) imageDataRef];
	CFRelease(imageDataRef);
	return imageData;
}

- (void) setImage: (UIImage *) image
{
	CFErrorRef error;
	BOOL success;
	
	if (image == nil) // remove
	{
		if (!ABPersonHasImageData(record)) return; // no image to remove
		success = ABPersonRemoveImageData(record, &error);
		if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
		return;
	}
	
	NSData *data = UIImagePNGRepresentation(image);
	success = ABPersonSetImageData(record, (__bridge CFDataRef) data, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
}

@end