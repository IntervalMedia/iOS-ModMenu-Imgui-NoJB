#pragma once

#include "ImGuiDrawView.h"
#include "MenuLoad.h"

#include "../ImGui/imgui.h"
#include "../ImGui/imgui_internal.h"
#include "../ImGui/imgui_impl_metal.h"

#include <vector>
#include <map>
#include <unistd.h>
#include <string.h>
#include <vector>
#include <functional>
#include <iostream>
#include <queue>
#include <pthread/pthread.h>
#include <substrate.h>

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>

#import <os/log.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <stdio.h>
#import <mach/mach.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SCALE [UIScreen mainScreen].scale
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

extern MenuInteraction* menuTouchView;
extern UIButton* InvisibleMenuButton;
extern UIButton* VisibleMenuButton;
extern UITextField* hideRecordTextfield;
extern UIView* hideRecordView;
extern ImFont* Font;

struct GlobalVariables
{
    static GlobalVariables& GetInstance() 
    {
        static GlobalVariables Instance;
        return Instance;
    }

    ImFont* Font;
    ImVec2 MenuSize   = ImVec2(0, 0);
    ImVec2 MenuOrigin = ImVec2(0, 0);

    bool StreamerMode = false; //Hide the menu during recording
    bool MoveMenu = false; //Move the menu


    float FloatModExample = 0.0f; //slider in MenuLoad -> UserMenu.mm

};

static GlobalVariables& KTempVars = GlobalVariables::GetInstance();
