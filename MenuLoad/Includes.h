#pragma once

#include "AppState.h"
#include "../utils/KPatch.hpp"

#include <unistd.h>
#include <substrate.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// Compatibility helpers for existing feature modules.
#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height
#define SCREEN_SCALE UIScreen.mainScreen.scale
