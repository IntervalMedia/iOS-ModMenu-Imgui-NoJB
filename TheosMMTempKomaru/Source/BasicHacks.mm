#include "BasicHacks.h"
#include "../MenuLoad/Includes.h"

bool BasicHacks::IsValidPointer(long Offset) {
    return Offset > 0x100000000 && (uint64_t)Offset < 0x3000000000;
}

constexpr uintptr_t OFFSET_Example = 0x000;
constexpr uintptr_t OFFSET_Example1 = 0x001;

void* BasicHacks::HacksThread(void* arg)
{

    while(true)
    {
        usleep(100);

        uintptr_t BaseAddr  =  (uintptr_t)_dyld_get_image_header(0);
        uintptr_t GWorld    = *(uintptr_t*)(BaseAddr + OFFSET_Example   );     if (!IsValidPointer(GWorld))     continue; 
        uintptr_t ExPtr     = *(uintptr_t*)(GWorld   + OFFSET_Example1  );     if (!IsValidPointer(ExPtr))      continue; 

        *(float*)(ExPtr + 0x33a0) = KTempVars.FloatModExample; // MenuLoad -> Includes.h

    } return NULL; }


void BasicHacks::Initialize()
{
    pthread_t BasicHacksThread;
    pthread_create(&BasicHacksThread, nullptr, HacksThread, nullptr);
}
