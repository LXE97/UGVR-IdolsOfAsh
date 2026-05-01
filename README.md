# Idols of Ash VR
This is a fork of UGVR with some changes to enable the grappling hook to be used with motion controllers. Tested on Quest with Virtual Desktop, with roomscale movement enabled.

## Installation
1. Download the release zip
2. Extract it to your IdolsOfAsh directory (next to idols_of_ash.exe)
    - **If you have installed other mods** that came with their own override.cfg, you'll need to merge those manually. For example:
        ````
        [autoload_prepend]
        XRInjector="*res://xr_injector/xr_injector.gd"
        ModLoader="*res://addons/mod_loader/mod_loader.gd"
        ModLoaderStore="*res://addons/mod_loader/mod_loader_store.gd"
        ````
All of the options are located in the XRConfigs folder:
````
idols of ash_xr_game_action_map.cfg         - game keybindings
idols of ash_xr_game_options.cfg            - VR settings
idols of ash_xr_game_control_map.cfg        - misc controller settings
````
## Controls
The VR controller is mapped to Xbox gamepad buttons by `control_map.cfg`, and the game keybindings are configured in `action_map.cfg`. The triggers are hardcoded to fire the grappling hook, but everything else should be configurable.

#### Joystick direction
Use `movement_direction_device` in `game_options.cfg` to change the reference for the joystick direction. By default it's set to Head (HMD).
````
0 = HMD
1 = Primary Controller
2 = Secondary Controller
````

#### Menus


## Other Options
* Healthbar size and background color can be configured in the file `xr_injector/xr_scene.gd` on line 705 (ctrl+f "healthbar").
* To adjust camera height or VR world scale, see `game_options.cfg`

* Hand model: `xr_hand_material_choice` in `game_options.cfg`
        0# Default - transparent hand
        1# Full blue glove            
        2# Half glove dark skinned
        3# No glove light skinned
        4# No glove dark skinned
        5# Full yellow glove
        6# Ghost hand - half glove light skinned



I disabled the UGVR gestures such as the laser pointer and height adjustment, as these were too glitchy to deal  with.

## Known Issues
* While grappling, the camera can clip into objects, sometimes turning the screen black, usually ascending the rope will pull you out of it

## Credits
Thanks to [ElKameleon](https://github.com/ElKameleon/DescentWithoutDread/tree/main) for the detailed guide on how to set up Godot mods.
### [Original UGVR readme](https://github.com/teddybear082/UGVR)

### [The UGVR wiki](https://github.com/teddybear082/UGVR) may be helpful for customization and troubleshooting
