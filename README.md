# iOS-Theos-ModMenuTemp-NoJB

## Komaru ModMenu Template
**Note**: The majority of this project was **NOT** created by me; I have contributed only minimal modifications.

This template is designed for **non-jailbroken (jailed) iOS devices** and was originally created for **ARK**.  
This was created due to the lack of readily available iOS ModMenu templates.

---

### Features
- **Floating Menu Button**: Easily accessible interface for in-game mod controls.
- **Simple C-Style Casting**: Straightforward coding style for easy understanding and modification.
- **UE4 Usage Examples**: Reference implementations for Unreal Engine 4.
- **ImGui menu**: Easily modified ImGui menu for iOS

---

### Usage

#### 1. Getting the Base Address

```cpp
uintptr_t BaseAddr = (uintptr_t)_dyld_get_image_header(0);
```

**explanation**:  
_dyld_get_image_header(0) gives you the base address of the first loaded file in the app, usually the main program itself.

#### 2. Compilation
For details on compiling, please refer to Theos:

[Theos Installation Guide](https://theos.dev/docs/installation)  

Use **WSL (Windows Sub Linux)** if compiling on windows.  

#### 3. ImGui usage
For ImGui usage, please refer to the
[Official ImGui Wiki](https://github.com/ocornut/imgui/wiki)
