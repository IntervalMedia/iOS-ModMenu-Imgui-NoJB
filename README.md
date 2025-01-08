# iOS-Theos-ModMenuTemp-NoJB

## Komaru ModMenu (Temporary Version)
**Note**: The majority of this project was **NOT** created by me; I have contributed only minimal modifications.

This ModMenu is designed for **non-jailbroken (jailed) iOS devices** and was originally created for **ARK**. It provides a **floating menu button** and uses **simple C-style casting**, ensuring it is **easy to understand** and modify.

It is posted here due to the lack of iOS ModMenu templates.

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

#### 2. Compilation
For details on compiling, please refer to Theos:

[Theos Installation Guide](https://theos.dev/docs/installation)
