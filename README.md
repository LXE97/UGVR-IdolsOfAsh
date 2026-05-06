# Idols of Ash VR
##### Unofficial mod to play **[Idols of Ash](https://idolsofash.com/)** in OpenXR. This is a fork of Universal Godot VR Injector with some changes to enable the grappling hook to be used with motion controllers. Tested on Quest with Virtual Desktop, with roomscale movement enabled.

Working game versions:
* 1.32
* 1.31
* 1.30

## Installation
1. Download the [release zip](https://github.com/LXE97/UGVR-IdolsOfAsh/releases/tag/v2.0.0)
2. Extract it to your IdolsOfAsh directory (next to idols_of_ash.exe)
    - **If you have installed other mods** that came with their own override.cfg, you'll need to merge those manually. For example:
        ````
        [autoload_prepend]
        XRInjector="*res://xr_injector/xr_injector.gd"
        ModLoader="*res://addons/mod_loader/mod_loader.gd"
        ModLoaderStore="*res://addons/mod_loader/mod_loader_store.gd"
        ````
3. Make sure your headset and controllers are connected and ready before launching the game exe

###
#### Uninstallation
To disable VR, comment out this line in override.cfg:
`;XRInjector="*res://xr_injector/xr_injector.gd"`

To uninstall, delete the `xr_injector/` folder



## Controls
The VR controller is mapped to Xbox gamepad buttons by `control_map.cfg`, and the game keybindings are configured in `action_map.cfg`. 

![Control map](control_map.png)

#### Joystick direction
Use `movement_direction_device` in `game_options.cfg` to change the reference for the joystick direction. By default it's set to Head (HMD).
````
0 = HMD
1 = Primary Controller
2 = Secondary Controller
````

#### In-game height adjustment
Hold the right controller over your head and click the joystick to set your height to be the same as the unmodded game. Press again to reset it.

## Options
All of the options are located in the XRConfigs folder:
````
idols of ash_xr_game_options.cfg            - Mod settings
idols of ash_xr_game_action_map.cfg         - game keybindings
idols of ash_xr_game_control_map.cfg        - misc controller settings
````

Misc options in `game_options.cfg`:
* `use_physics_hands` **Default: true**
  * Enables collision on the floating hands, recommended in order to keep the rope from getting tangled inside terrain.
* `physics_hand_drag` **Default: 0.06**
  * Slows down the player when swinging from a rope and touching the wall, set to 0 to disable.
* `use_palm_healthbar` **Default: true**
  * Disable or resize the floating healthbar
* `roomscale_height_adjustment`
* `xr_world_scale` **Default: 0.85**
  * Adjust camera height and VR world scale
* `xr_hand_material_choice` **Default: 6**
  * Coose a different hand model:

        0 Transparent hand
        1 Full blue glove            
        2 Half glove dark skinned
        3 No glove light skinned
        4 No glove dark skinned
        5 Full yellow glove
        6 half glove light skinned
* `terrain_collision_fade` **Default: true**
  * Disable the fade-to-black effect when the VR camera goes into a wall
* `ignore_sprint` **Default: true**
  * If this is enabled, the joystick will vary between the slowest walking speed and the fastest sprinting speed, so you don't need the sprint button
* `player_light_multiplier` **Default: 0.8**
  * Change the intensity of the light emitted by the grappling hook and the player
* `enable_hook_haptics` **Default: false**
* `enable_hand_haptics` **Default: false**
  * Controller vibration on hook attach / hand collision with walls
## Known Issues
* none yet :)

## Credits
Thanks to [ElKameleon](https://github.com/ElKameleon/DescentWithoutDread/tree/main) for the detailed guide on how to set up Godot mods.

Thanks to the creators of UGVR for all their hard work
### [Original UGVR readme](https://github.com/teddybear082/UGVR)

### [The UGVR wiki](https://github.com/teddybear082/UGVR/wiki/1.-Getting-Started) may be helpful for customization and troubleshooting
