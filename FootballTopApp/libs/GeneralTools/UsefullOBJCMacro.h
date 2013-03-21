/*
 *  UsefullOBJCMacro.h
 *  AgileFifteens
 *
 *  Created by destman on 1/28/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */


#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#define HAVE_ARC 1
#else
#define HAVE_ARC 0
#endif


#if HAVE_ARC
#define AUTORELEASE(x) x
#define RELEASE(x)
#define RETAIN(x) x
#else
#define AUTORELEASE(x)[x autorelease]
#define RELEASE(x) [x release]
#define RETAIN(x) [x retain]
#endif

#define APPDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define ViewWithID(ID)					((UIView *)[self.view viewWithTag:ID])
#define ViewInViewWithID(view,ID)		((UIView *)[view viewWithTag:ID])

#define LabelWithID(ID)					((UILabel *)[self.view viewWithTag:ID])
#define LabelInViewWithID(view,ID)		((UILabel *)[view viewWithTag:ID])

#define LabelWithID(ID)					((UILabel *)[self.view viewWithTag:ID])
#define LabelInViewWithID(view,ID)		((UILabel *)[view viewWithTag:ID])

#define ButtonWithID(ID)			((UIButton *)[self.view viewWithTag:ID])
#define ButtonInViewWithID(view,ID) ((UIButton *)[view viewWithTag:ID])

#define ImageViewWithID(ID)             ((UIImageView *)[self.view viewWithTag:ID])
#define ImageViewInViewWithID(view,ID)  ((UIImageView *)[view viewWithTag:ID])

#define TextFieldWithID(ID)             ((UITextField *)[self.view viewWithTag:ID])
#define TextFieldInViewWithID(view,ID)       ((UITextField *)[view viewWithTag:ID])

#define TextViewWithID(ID)             ((UITextView *)[self.view viewWithTag:ID])
#define TextViewInViewWithID(view,ID)       ((UITextView *)[view viewWithTag:ID])

#define WebViewWithID(ID)					((UIWebView *)[self.view viewWithTag:ID])
#define WebViewInViewWithID(view,ID)		((UIWebView *)[view viewWithTag:ID])

#define colCv(v) ((double)(v)/255.0)
#define RGBAColor(r,g,b,a) [UIColor colorWithRed:colCv(r) green:colCv(g) blue:colCv(b) alpha:colCv(a)]
