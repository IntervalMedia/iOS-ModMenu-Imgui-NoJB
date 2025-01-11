# iOS-Theos-ModMenuTemp-NoJB

## Komaru ModMenu Template
**Note**: A substantial portion of this project was **NOT** created by me.

This template is designed for **non-jailbroken (jailed) iOS devices** and was originally created for **ARK: Ultimate Mobile Edition**.  
This was created due to a lack iOS ModMenu templates.

---

### Features
- **Simple Offset Patching**: Straightforward coding style for easy understanding and modification.
- **Floating Menu Button**: Easily accessible interface for in-game mod controls.
- **UE4 Usage Examples**: Reference implementations for Unreal Engine 4.
- **ImGui menu**: Easily modified ImGui menu for iOS

---

### Usage

#### 1. Getting the Base Address

```cpp
uintptr_t BaseAddr = (uintptr_t)_dyld_get_image_header(0);
```

**Explanation**:  
_dyld_get_image_header(0) gives you the base address of the first loaded file in the app, usually the main program itself.

#### 2. Simple offset patching

**Reading memory:**  

```cpp
uintptr_t EX = KomaruPatch::ReadMem(Ptr + Ptr);
```

**Writing memory:**  

```cpp
KomaruPatch::WriteMem<Type>(Ptr + Offset, Value);
``` 

#### 3. Compilation
For details on compiling, please refer to Theos:

[Theos Installation Guide](https://theos.dev/docs/installation)  

Use **WSL (Windows Sub Linux)** if compiling on windows.  

#### 4. ImGui
For ImGui usage, please refer to the
[Official ImGui Wiki](https://github.com/ocornut/imgui/wiki)


**Example Image:** 
![Example Image](https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB/blob/main/FovChanger.png)  

  ---  
  ###UPDATES  

  ####1-10-25
  updated [KomaruPatch.hpp]([https://theos.dev/docs/installation](https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB/blob/main/TheosMMTempKomaru/utils/KPatch.hpp))  
  automatically checks pointer validity now.  
