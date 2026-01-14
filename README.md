
A5 Camera Development Tool By FaisalAlY_

A comprehensive camera development tool for FiveM that provides full control over camera positioning, rotation, field of view, depth of field, and effects.

A comprehensive camera development tool for FiveM that provides full control over camera positioning, rotation, field of view, depth of field, and effects with real-time code generation.

## Features

- **Complete Camera Control**: Move freely with WASD, Q/E for vertical movement
- **Dynamic Speed Control**: Scroll wheel to adjust movement speed, Shift+Scroll for faster increments
- **Depth of Field (DOF)**: Full DOF control with adjustable strength, near/far distances
- **Field of View (FOV)**: Precise FOV adjustment from 10 to 120 degrees
- **Camera Effects**: Motion blur with adjustable strength
- **Real-time Debug UI**: Live display of all camera parameters using DrawText2D
- **Code Generation**: The tool generates a complete Lua code snippet that includes:
- **Mouse & Keyboard Controls**: Smooth mouse rotation with arrow key fine-tuning

## Installation

1. Download or clone this repository
2. Place the `a5-camdevtool` folder in your FiveM resources directory
3. Add `ensure a5-camdevtool` to your `server.cfg`
4. Restart your server

## Commands

| Command | Description |
|---------|-------------|
| `/cam` | Toggle camera tool on/off |
| `/camtool` | Toggle camera tool on/off (alternative) |
| `/camera` | Toggle camera tool on/off (alternative) |
| `/camdebug` | Toggle debug UI visibility |
| `/camreset` | Reset camera position to player location |

## Controls

### Movement Controls
| Key | Action |
|-----|--------|
| **W** | Move forward |
| **S** | Move backward |
| **A** | Move left |
| **D** | Move right |
| **Q** | Move up |
| **E** | Move down |
| **Mouse** | Rotate camera (look around) |
| **Arrow Keys** | Fine rotation adjustment |

### Speed Controls
| Key | Action |
|-----|--------|
| **Scroll Up** | Increase movement speed (+0.05) |
| **Scroll Down** | Decrease movement speed (-0.05) |
| **Shift + Scroll Up** | Fast increase (+0.5) |
| **Shift + Scroll Down** | Fast decrease (-0.5) |

### Field of View (FOV)
| Key | Action |
|-----|--------|
| **Numpad +** | Increase FOV (+5.0) |
| **Numpad -** | Decrease FOV (-5.0) |
| **Numpad 8** | Fine increase FOV (+1.0) |
| **Numpad 5** | Fine decrease FOV (-1.0) |

### Depth of Field (DOF)
| Key | Action |
|-----|--------|
| **F1** | Toggle DOF on/off |
| **F2** | Decrease DOF strength |
| **F3** | Increase DOF strength |
| **F4** | Decrease near DOF distance |
| **F5** | Increase near DOF distance |
| **F6** | Decrease far DOF distance |
| **F7** | Increase far DOF distance |

A5 Camera Development Tool By FaisalAlY_

A comprehensive camera development tool for FiveM that provides full control over camera positioning, rotation, field of view, depth of field, and real-time code generation.

## Summary of recent edits

- DOF controls remapped to number keys (1-7) instead of function keys.
- FOV controls now use NUMPAD9/6 (large +/-) and NUMPAD8/5 (small +/-).
- Setting DOF focus spawns a small prop (beachball) at the focus point for visual feedback.
- Left Mouse Button (LMB) toggles pan lock (lock/unlock mouse panning).
- Motion blur handling was removed from the camera update logic.
- Added key mapping to reset tilts: `I` (RegisterKeyMapping bound to `cam_resettilt`).
- Press `Enter` to generate a Lua code snippet (printed to console / F8).

## Features

- Complete Camera Control: Move freely with WASD, Q/E for vertical movement
- Dynamic Speed Control: Scroll wheel to adjust movement speed; Shift+Scroll for larger increments
- Depth of Field (DOF): Toggle and finely adjust strength, near/far distances; spawn visual focus marker
- Field of View (FOV): Precise FOV adjustment from 10 to 120 degrees using numpad bindings
- Real-time Debug UI: Live display of all camera parameters using DrawText2D
- Code Generation: Generate a ready-to-use Lua camera snippet and print it to the client console

## Installation

1. Download or clone this repository
2. Place the `a5-camtool` folder in your FiveM resources directory
3. Add `ensure a5-camtool` to your `server.cfg`
4. Restart your server

## Commands

| Command | Description |
|---------|-------------|
| `/cam` | Toggle camera tool on/off |
| `/camtool` | Toggle camera tool on/off (alternative) |
| `/camera` | Toggle camera tool on/off (alternative) |
| `/camdebug` | Toggle debug UI visibility |
| `/camreset` | Reset camera position to player location |

## Controls

### Movement Controls
| Key | Action |
|-----|--------|
| **W** | Move forward |
| **S** | Move backward |
| **A** | Move left |
| **D** | Move right |
| **Q** | Move up |
| **E** | Move down |
| **Mouse** | Rotate camera (look around) |
| **Arrow Keys** | Fine rotation adjustment |

### Speed Controls
| Key | Action |
|-----|--------|
| **Scroll Up** | Increase movement speed (+0.05) |
| **Scroll Down** | Decrease movement speed (-0.05) |
| **Shift + Scroll Up** | Fast increase (+0.5) |
| **Shift + Scroll Down** | Fast decrease (-0.5) |

### Field of View (FOV)
| Key | Action |
|-----|--------|
| **NUMPAD9** | Increase FOV (+5.0) |
| **NUMPAD6** | Decrease FOV (-5.0) |
| **NUMPAD8** | Fine increase FOV (+1.0) |
| **NUMPAD5** | Fine decrease FOV (-1.0) |

### Depth of Field (DOF)
DOF controls are remapped to the number keys for quick access:

| Key | Action |
|-----|--------|
| **1** | Toggle DOF on/off |
| **2** | Decrease DOF strength |
| **3** | Increase DOF strength |
| **4** | Decrease near DOF distance |
| **5** | Increase near DOF distance |
| **6** | Decrease far DOF distance |
| **7** | Increase far DOF distance |

Setting a DOF focus point (Number key `9` behavior in code) will raycast from the camera and, if it hits a surface, place a small visual prop (a beachball) at the focus point. Hold Shift while setting to enter focus-adjust mode.

### Other Controls
| Key | Action |
|-----|--------|
| **Left Mouse Button (LMB)** | Toggle pan lock (lock/unlock camera panning) |
| **Enter** | Generate code snippet and print it to console (F8) |
| **ESC / Backspace** | Exit camera tool |
| **I** | Reset camera tilts (registered key mapping `cam_resettilt`) |

## Debug UI Information

The on-screen debug display shows:
- Position: Current X, Y, Z coordinates
- Rotation: Current X, Y, Z rotation values
- FOV: Current field of view
- Move Speed: Current movement speed
- DOF Status: Enabled/disabled with strength and distance values
- Spawned Focus Ball: Whether a visual focus prop exists
- Controls Reference: Quick reference for commonly used controls

## Technical Details

### Camera Parameters

- Movement Speed: 0.01 to 10.0 (adjustable)
- FOV Range: 10.0 to 120.0 degrees
- DOF Strength: 0.0 to 1.0
- Rotation: Pitch limited to -89° to +89° (prevents gimbal lock)

### Notes

- Motion blur handling was intentionally removed from the camera update logic.
- DOF focus spawns a small prop to help position and visualize the focal point; spawned props are cleaned up when the camera shuts down.

## Troubleshooting

**Camera won't activate:**
- Make sure you're using the correct command: `/cam`, `/camtool`, or `/camera`
- Check that the resource is started in your server

**Controls not working:**
- The tool disables most controls while active; this is intentional to prevent conflicts.
- Use ESC or Backspace to exit if you need normal controls back

**Code not appearing:**
- Press F8 to open the console where the code snippet is printed
- The code generation is triggered by pressing `Enter` (control 191)

## Credits

**Developer**: FaisalAlY_
**Version**: 1.0.0
**License**: Open Source

## Support

For issues, suggestions, or contributions, please visit the repository issues page.

---

Enjoy creating amazing camera setups!
