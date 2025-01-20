/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB
#pragma once

#include <iostream>

class KomaruPatch {
public:
    static bool IsValidPointer(uintptr_t address) {
        return address > 0x100000000 && address < 0x3000000000;
    }

    static uintptr_t ReadMem(uintptr_t address) {
        if (!IsValidPointer(address)) {
            return 0;
        }
        return *reinterpret_cast<uintptr_t*>(address);
    }

    template <typename T>
    static void WriteMem(uintptr_t address, const T& value) {
        if (!IsValidPointer(address)) {
            return;
        }
        *reinterpret_cast<T*>(address) = value;
    }
};
*/
#pragma once

#include <sys/sysctl.h> // For memory region checks (iOS)
#include <mach/mach.h> // For vm_protect
#include <cstring> // For memcpy

class KomaruPatch {
public:
    // More robust pointer validation for iOS
    static bool IsValidPointer(uintptr_t address) {
        if (address == 0) return false;

        // Get task info
        mach_port_t task = mach_task_self();
        mach_vm_address_t region_address = (mach_vm_address_t)address;
        mach_vm_size_t region_size = 0;
        mach_vm_address_t region_end = 0;
        mach_vm_region_basic_info_data_t info;
        mach_msg_type_number_t info_count = MACH_VM_REGION_BASIC_INFO_COUNT;
        mach_port_t object_name;

        kern_return_t kr = mach_vm_region(task, &region_address, &region_size, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &info_count, &object_name);

        if (kr != KERN_SUCCESS) {
            return false; // Not a valid region
        }

        region_end = region_address + region_size;

        return address >= region_address && address < region_end;
    }

    static uintptr_t ReadMem(uintptr_t address) {
        if (!IsValidPointer(address)) {
            return 0;
        }

        uintptr_t value;
        // Use memcpy for safety (especially with potentially misaligned pointers)
        memcpy(&value, reinterpret_cast<void*>(address), sizeof(uintptr_t));
        return value;
    }

    template <typename T>
    static bool WriteMem(uintptr_t address, const T& value) {
        if (!IsValidPointer(address)) {
            return false;
        }

        //Attempt to make the page writable.
        mach_port_t task = mach_task_self();
        mach_vm_address_t page_address = (mach_vm_address_t)(address & ~(vm_page_size - 1));
        kern_return_t kr = vm_protect(task, page_address, vm_page_size, false, VM_PROT_READ | VM_PROT_WRITE);

        if (kr != KERN_p) {
            return false;
        }

        // Use memcpy for safety and to handle potential misaligned pointers
        memcpy(reinterpret_cast<void*>(address), &value, sizeof(T));

        //Attempt to restore the original protection. This is very important.
        kr = vm_protect(task, page_address, vm_page_size, false, VM_PROT_READ);
        if (kr != KERN_SUCCESS) {
           return false;
        }
        return true;
    }
};
