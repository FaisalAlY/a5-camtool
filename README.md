
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

### Code Generation & Exit
| Key | Action |
|-----|--------|
| **Enter** | Generate code snippet (outputs to console F8) |
| **ESC** | Exit camera tool |
| **Backspace** | Exit camera tool (alternative) |

## Debug UI Information

The on-screen debug display shows:
- **Position**: Current X, Y, Z coordinates
- **Rotation**: Current X, Y, Z rotation values
- **FOV**: Current field of view
- **Move Speed**: Current movement speed
- **DOF Status**: Enabled/disabled with strength and distance values
- **Motion Blur**: Status and strength
- **Controls Reference**: Quick reference for all controls

## Technical Details


### Camera Parameters

- **Movement Speed**: 0.01 to 10.0 (adjustable)
- **FOV Range**: 10.0 to 120.0 degrees
- **DOF Strength**: 0.0 to 1.0
- **Rotation**: Pitch limited to -89° to +89° (prevents gimbal lock)

### Camera Parameters

- **Movement Speed**: 0.01 to 10.0 (adjustable)
- **FOV Range**: 10.0 to 120.0 degrees
- **DOF Strength**: 0.0 to 1.0
- **Rotation**: Pitch limited to -89° to +89° (prevents gimbal lock)

### Features Included

1. **Smooth Movement**: Frame-rate independent movement using delta time
2. **Precise Controls**: Multiple control schemes for different precision levels
3. **Visual Feedback**: Real-time on-screen display of all parameters
4. **Professional Output**: Production-ready code generation
5. **Player Safety**: Automatically freezes player character while in camera mode
6. **Clean Exit**: Properly destroys camera and restores normal view on exit

## Use Cases

- **Cinematic Scene Setup**: Position cameras for cutscenes and cinematics
- **Screenshot Positioning**: Get perfect angles for promotional screenshots
- **Development Testing**: Quickly test different camera angles and effects
- **Code Generation**: Generate camera code without manual coordinate writing
- **DOF Experimentation**: Test different depth of field settings visually

## Tips

1. **Start Slow**: Begin with low movement speed and increase as needed
2. **Use Shift+Scroll**: For rapid speed adjustments during long-distance travel
3. **Fine-tune with Arrows**: Use arrow keys for precise rotation adjustments
4. **Save Positions**: Use the code generation frequently to save positions you like
5. **Toggle Debug**: Use `/camdebug` to hide UI for clean screenshots
6. **Reset Position**: Use `/camreset` if you get lost or want to start from your player location

## Troubleshooting

**Camera won't activate:**
- Make sure you're using the correct command: `/cam`, `/camtool`, or `/camera`
- Check that the resource is started in your server

**Controls not working:**
- The tool disables most controls while active - this is intentional
- Use ESC or Backspace to exit if you need normal controls back

**Code not appearing:**
- Press F8 to open the console where the code snippet is printed
- Make sure you pressed Enter (Control 191)

## Credits

**Developer**: FaisalAlY_
**Version**: 1.0.0
**License**: Open Source

## Support

For issues, suggestions, or contributions, please visit the repository issues page.

---

**Enjoy creating amazing camera setups!**