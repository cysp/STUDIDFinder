//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <UIKit/UIKit.h>

#import <sys/sysctl.h>
#import <objc/runtime.h>


static BOOL STIsBeingDebugged(void) {
	int mib[4] = {
		CTL_KERN,
		KERN_PROC,
		KERN_PROC_PID,
		getpid(),
	};

	struct kinfo_proc info;
	info.kp_proc.p_flag = 0; // we only care about this field

	size_t infosz = sizeof(info);

	if (!sysctl(mib, sizeof(mib)/sizeof(*mib), &info, &infosz, NULL, 0)) {
		return !!(info.kp_proc.p_flag & P_TRACED);
	}

	return NO;
}


typedef NSString *(*fn_UIDevice_uniqueIdentifier)(id, SEL);

static fn_UIDevice_uniqueIdentifier UIDevice_uniqueIdentifier;

static NSString *STUIDevice_uniqueIdentifier(id self, SEL _cmd) {
	NSLog(@"-[UIDevice uniqueIdentifier] invoked!", nil);
	if (STIsBeingDebugged()) {
		raise(SIGINT);
	}
	return UIDevice_uniqueIdentifier(self, _cmd);
}


static void __attribute__((constructor)) replaceUDID()  {
	Class const UIDeviceClass = [UIDevice class];
	Method uniqueIdentifier = class_getInstanceMethod(UIDeviceClass, @selector(uniqueIdentifier));
	UIDevice_uniqueIdentifier = (fn_UIDevice_uniqueIdentifier)method_getImplementation(uniqueIdentifier);
	if (UIDevice_uniqueIdentifier) {
		method_setImplementation(uniqueIdentifier, (IMP)STUIDevice_uniqueIdentifier);
	}
}
