# Idols of Ash VR
This is a fork of UGVR with some changes to enable the grappling hook to be used with motion controllers. Tested on Quest with Virtual Desktop in OpenXR mode.

## Installation
1. Download the release zip
2. Extract it to your IdolsOfAsh directory (the one with idols_of_ash.exe)
    - **If you have installed other mods** that came with override.cfg, you'll need to merge those manually. For example:
        ```
        [autoload_prepend]
        XRInjector="*res://xr_injector/xr_injector.gd"
        ModLoader="*res://addons/mod_loader/mod_loader.gd"
        ModLoaderStore="*res://addons/mod_loader/mod_loader_store.gd"
        ````
3. Folder structure should look like this:
    ```
    [DIR ] .godot
    [DIR ] XRConfigs
    [DIR ] xr_injector
    [FILE] idols_of_ash.exe
    [FILE] idols_of_ash.pck
    [FILE] libEGL.dll
    [FILE] libGLESv2.dll
    [FILE] libgodotsteam.windows.template_release.double.x86_64.dll
    [FILE] override.cfg
    [FILE] steam_api64.dll 
    ```



## Controls
The VR controller is mapped to an Xbox gamepad, so controls can be changed using the in-game menu, except for the triggers which are hardcoded to fire the grappling hook.
If you're not using Quest controllers, you may want to adjust the VR->Xbox mappings in the file `XRConfigs/idols of ash_xr_game_options.cfg`

TODO: controller bindings default image

TODO: note on dpad/menu usage

## Other changes
The healthbar size and background color are configured in the file `xr_injector/xr_scene.gd` on line 705 (ctrl+f "healthbar").

I have disabled most of the UGVR gestures such as the laser pointer and height adjustment, as these were too glitchy to bother with.

To adjust camera height or VR world scale, see `XRConfigs/idols of ash_xr_game_options.cfg`

# Credits
Thanks to [ElKameleon](https://github.com/ElKameleon/DescentWithoutDread/tree/main) for the detailed guide on how to set up Godot mods.
### [Original UGVR readme](https://github.com/teddybear082/UGVR)

### [The UGVR wiki](https://github.com/teddybear082/UGVR) may be helpful for customization
