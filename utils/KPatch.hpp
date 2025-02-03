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

    // Attempt to make the memory handling more robust, with minimal use of mach api's to reduce any extra entitlements

#pragma once

#include <mach/mach.h>   // Required for task and memory operations
#include <cstring>       // For memcpy
#include <sys/sysctl.h>  // For memory region checks

class KomaruPatch {
public:
    // Validate if the address is readable and within a valid memory region
    static bool IsValidPointer(uintptr_t address) {
        if (address == 0) return false;

        mach_port_t task = mach_task_self();
        mach_vm_address_t region_address = (mach_vm_address_t)address;
        mach_vm_size_t region_size = 0;
        mach_vm_region_basic_info_data_t info;
        mach_msg_type_number_t info_count = MACH_VM_REGION_BASIC_INFO_COUNT;
        mach_port_t object_name;

        kern_return_t kr = mach_vm_region(task, &region_address, &region_size, VM_REGION_BASIC_INFO,
                                          reinterpret_cast<vm_region_info_t>(&info), &info_count, &object_name);

        if (kr != KERN_SUCCESS) {
            return false; // Invalid memory region
        }

        // Ensure the address falls within the mapped region
        return address >= region_address && address < (region_address + region_size);
    }

    // Read memory safely using vm_read_overwrite
    template <typename T>
    static T ReadMem(uintptr_t address) {
        if (!IsValidPointer(address)) {
            return T(); // Return default value on failure
        }

        mach_port_t task = mach_task_self();
        T value = {};
        mach_vm_size_t size = sizeof(T);
        kern_return_t kr = vm_read_overwrite(task, address, size, reinterpret_cast<vm_address_t>(&value), &size);

        if (kr != KERN_SUCCESS || size != sizeof(T)) {
            return T(); // Return default value on failure
        }

        return value;
    }

    // Write memory safely, using vm_protect to ensure memory is writable
    template <typename T>
    static bool WriteMem(uintptr_t address, const T& value) {
        if (!IsValidPointer(address)) {
            return false;
        }

        mach_port_t task = mach_task_self();

        // Check memory protection
        vm_prot_t currentProtection;
        mach_vm_address_t region_address = address;
        mach_vm_size_t region_size = 0;
        mach_vm_region_basic_info_data_t info;
        mach_msg_type_number_t info_count = MACH_VM_REGION_BASIC_INFO_COUNT;
        mach_port_t object_name;

        kern_return_t kr = mach_vm_region(task, &region_address, &region_size, VM_REGION_BASIC_INFO,
                                          reinterpret_cast<vm_region_info_t>(&info), &info_count, &object_name);

        if (kr != KERN_SUCCESS || !(info.protection & VM_PROT_WRITE)) {
            // Attempt to change protection if it's not writable
            kr = vm_protect(task, address, sizeof(T), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
            if (kr != KERN_SUCCESS) {
                return false; // Cannot modify protection
            }
        }

        // Perform the write operation
        memcpy(reinterpret_cast<void*>(address), &value, sizeof(T));

        // Restore original protection if needed
        if (!(info.protection & VM_PROT_WRITE)) {
            vm_protect(task, address, sizeof(T), false, info.protection);
        }

        return true;
    }
};
 
