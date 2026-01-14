local CamDevTool = {
    -- Dev: core state tabletweak defaults as needed
    
    active = false,
    camera = nil,

    
    position = vector3(0.0, 0.0, 0.0),
    rotation = vector3(0.0, 0.0, 0.0),

    
    fov = 50.0,
    moveSpeed = 0.5,
    rotSpeed = 0.5,

    
    dof = {
        enabled = false,
        strength = 0.0,
        nearStart = 0.0,
        nearEnd = 1.0,
        farStart = 100.0,
        farEnd = 200.0
    },

    
    effects = {
        shake = false,
        shakeAmplitude = 0.0,
        motionBlur = false,
        motionBlurStrength = 0.0
    },

    
    minSpeed = 0.01,
    maxSpeed = 10.0,
    speedIncrement = 0.05,
    speedIncrementFast = 0.5,

    
    fovAdjustMode = false,
    rotationAdjustMode = false,
    dofAdjustMode = false,

    
    showDebug = true,
    debugColor = {r = 0, g = 255, b = 255, a = 255}
}

-- Utility Functions
local function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )

    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )

    return direction
end

local function DrawText2D(text, x, y, scale, font)
    SetTextFont(font or 4)
    SetTextProportional(1)
    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextColour(CamDevTool.debugColor.r, CamDevTool.debugColor.g, CamDevTool.debugColor.b, CamDevTool.debugColor.a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Small rectangle helper for debug ui...
local function DrawDebugBox(x, y, width, height, r, g, b, a)
    DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end


function CamDevTool:Initialize()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    self.position = coords
    self.rotation = vector3(0.0, 0.0, heading)

    -- TODO: Create camera
    self.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(self.camera, self.position.x, self.position.y, self.position.z)
    SetCamRot(self.camera, self.rotation.x, self.rotation.y, self.rotation.z, 2)
    SetCamFov(self.camera, self.fov)
    SetCamActive(self.camera, true)
    RenderScriptCams(true, false, 0, true, true)

    self.active = true
    FreezeEntityPosition(ped, true)
    print("^2[A5 Camera Tool]^7 Camera activated! Use controls to adjust.")
end

function CamDevTool:Shutdown()
    if self.camera then
        RenderScriptCams(false, false, 0, true, true)
        SetCamActive(self.camera, false)
        DestroyCam(self.camera, true)
        self.camera = nil
    end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)

    self.active = false
    print("^2[A5 Camera Tool]^7 Camera deactivated!")
end

function CamDevTool:UpdateCamera()
    if not self.camera then return end

    -- TODO: sync cam transform wit store data
    SetCamCoord(self.camera, self.position.x, self.position.y, self.position.z)
    SetCamRot(self.camera, self.rotation.x, self.rotation.y, self.rotation.z, 2)
    SetCamFov(self.camera, self.fov)

    
    if self.dof.enabled then
        SetCamUseShallowDofMode(self.camera, true)
        SetCamNearDof(self.camera, self.dof.nearStart)
        SetCamFarDof(self.camera, self.dof.farStart)
        SetCamDofStrength(self.camera, self.dof.strength)
        SetCamDofFnumberOfRings(self.camera, 8)
    else
        SetCamUseShallowDofMode(self.camera, false)
    end

    
    if self.effects.motionBlur then
        -- motion blur
        SetCamMotionBlurStrength(self.camera, self.effects.motionBlurStrength)
    end
end

function CamDevTool:HandleMovement(deltaTime)
    local direction = RotationToDirection(self.rotation)
    local right = vector3(-direction.y, direction.x, 0.0)
    local speed = self.moveSpeed * deltaTime * 100

    if IsControlPressed(0, 32) then
        self.position = self.position + (direction * speed)
    end
    if IsControlPressed(0, 33) then
        self.position = self.position - (direction * speed)
    end

    if IsControlPressed(0, 34) then
        self.position = self.position - (right * speed)
    end
    if IsControlPressed(0, 35) then
        self.position = self.position + (right * speed)
    end

    if IsControlPressed(0, 44) then
        self.position = vector3(self.position.x, self.position.y, self.position.z + speed)
    end
    if IsControlPressed(0, 38) then
        self.position = vector3(self.position.x, self.position.y, self.position.z - speed)
    end
end

function CamDevTool:HandleRotation(deltaTime)
    local speed = self.rotSpeed * deltaTime * 100

    local mouseX = GetDisabledControlNormal(0, 1) * speed
    local mouseY = GetDisabledControlNormal(0, 2) * speed

    self.rotation = vector3(
        math.max(-89.0, math.min(89.0, self.rotation.x - mouseY)),
        self.rotation.y,
        self.rotation.z - mouseX
    )

    if IsControlPressed(0, 172) then
        self.rotation = vector3(
            math.max(-89.0, math.min(89.0, self.rotation.x + speed * 0.5)),
            self.rotation.y,
            self.rotation.z
        )
    end
    if IsControlPressed(0, 173) then
        self.rotation = vector3(
            math.max(-89.0, math.min(89.0, self.rotation.x - speed * 0.5)),
            self.rotation.y,
            self.rotation.z
        )
    end
    if IsControlPressed(0, 174) then
        self.rotation = vector3(self.rotation.x, self.rotation.y, self.rotation.z + speed * 0.5)
    end
    if IsControlPressed(0, 175) then
        self.rotation = vector3(self.rotation.x, self.rotation.y, self.rotation.z - speed * 0.5)
    end
end

function CamDevTool:HandleFOVAdjustment()
    if IsControlJustPressed(0, 111) then
        self.fov = math.min(120.0, self.fov + 1.0)
    end
    if IsControlJustPressed(0, 110) then
        self.fov = math.max(10.0, self.fov - 1.0)
    end

    if IsControlJustPressed(0, 96) then
        self.fov = math.min(120.0, self.fov + 5.0)
    end
    if IsControlJustPressed(0, 97) then
        self.fov = math.max(10.0, self.fov - 5.0)
    end
end

function CamDevTool:HandleDOFAdjustment()
    if IsControlJustPressed(0, 288) then
        self.dof.enabled = not self.dof.enabled
        print(string.format("^2[A5 Camera Tool]^7 DOF %s", self.dof.enabled and "enabled" or "disabled"))
    end

    if not self.dof.enabled then return end

    if IsControlPressed(0, 289) then
        self.dof.strength = math.max(0.0, self.dof.strength - 0.01)
    end
    if IsControlPressed(0, 170) then
        self.dof.strength = math.min(1.0, self.dof.strength + 0.01)
    end

    if IsControlPressed(0, 166) then
        self.dof.nearStart = math.max(0.0, self.dof.nearStart - 0.1)
    end
    if IsControlPressed(0, 167) then
        self.dof.nearStart = math.min(self.dof.farStart, self.dof.nearStart + 0.1)
    end

    if IsControlPressed(0, 168) then
        self.dof.farStart = math.max(self.dof.nearStart, self.dof.farStart - 1.0)
    end
    if IsControlPressed(0, 169) then
        self.dof.farStart = math.min(500.0, self.dof.farStart + 1.0)
    end
end

function CamDevTool:HandleEffects()
    if IsControlJustPressed(0, 168) then
        self.effects.motionBlur = not self.effects.motionBlur
        print(string.format("^2[A5 Camera Tool]^7 Motion Blur %s", self.effects.motionBlur and "enabled" or "disabled"))
    end

    if self.effects.motionBlur then
        if IsControlPressed(0, 56) then
            self.effects.motionBlurStrength = math.max(0.0, self.effects.motionBlurStrength - 0.01)
        end
        if IsControlPressed(0, 57) then
            self.effects.motionBlurStrength = math.min(1.0, self.effects.motionBlurStrength + 0.01)
        end
    end
end

function CamDevTool:DrawDebugUI()
    if not self.showDebug then return end

    local y = 0.02
    local lineHeight = 0.025

    DrawDebugBox(0.01, 0.01, 0.35, 0.45, 0, 0, 0, 150)
    DrawText2D("~b~A5 CAMERA DEV TOOL", 0.025, y, 0.45, 4)
    y = y + lineHeight + 0.01

    DrawText2D(string.format("Position: X: %.2f | Y: %.2f | Z: %.2f",
        self.position.x, self.position.y, self.position.z), 0.025, y, 0.35, 4)
    y = y + lineHeight

    DrawText2D(string.format("Rotation: X: %.2f | Y: %.2f | Z: %.2f",
        self.rotation.x, self.rotation.y, self.rotation.z), 0.025, y, 0.35, 4)
    y = y + lineHeight

    DrawText2D(string.format("FOV: %.2f", self.fov), 0.025, y, 0.35, 4)
    y = y + lineHeight

    DrawText2D(string.format("Move Speed: %.3f", self.moveSpeed), 0.025, y, 0.35, 4)
    y = y + lineHeight + 0.01

    DrawText2D(string.format("~b~DOF:~s~ %s", self.dof.enabled and "~g~ENABLED" or "~r~DISABLED"), 0.025, y, 0.35, 4)
    y = y + lineHeight

    if self.dof.enabled then
        DrawText2D(string.format("  Strength: %.2f | Near: %.1f | Far: %.1f",
            self.dof.strength, self.dof.nearStart, self.dof.farStart), 0.025, y, 0.32, 4)
        y = y + lineHeight
    end

    y = y + 0.005

    -- effects...
    DrawText2D(string.format("~b~Motion Blur:~s~ %s",
        self.effects.motionBlur and string.format("~g~ON (%.2f)", self.effects.motionBlurStrength) or "~r~OFF"),
        0.025, y, 0.35, 4)
    y = y + lineHeight + 0.01

    DrawText2D("~b~CONTROLS:", 0.025, y, 0.35, 4)
    y = y + lineHeight
    DrawText2D("WASD - Move Camera | Q/E - Up/Down", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Mouse - Rotate | Arrows - Fine Rotate", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Scroll - Speed | Shift+Scroll - Fast Speed", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Numpad +/- - FOV (8/5 for fine)", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("F1 - Toggle DOF | F2/F3 - DOF Strength", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("F4/F5 - Near DOF | F6/F7 - Far DOF", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("~g~ENTER - Generate Code Snippet", 0.025, y, 0.35, 4)
    y = y + lineHeight
    DrawText2D("~r~ESC/Backspace - Exit Camera Tool", 0.025, y, 0.35, 4)
end

function CamDevTool:GenerateCodeSnippet()
    local direction = RotationToDirection(self.rotation)

    -- TODO:Build snippet string for clipboard
    local code = [[

local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

-- Position
SetCamCoord(camera, ]] .. string.format("%.2f, %.2f, %.2f", self.position.x, self.position.y, self.position.z) .. [[)

-- Rotation
SetCamRot(camera, ]] .. string.format("%.2f, %.2f, %.2f", self.rotation.x, self.rotation.y, self.rotation.z) .. [[, 2)

-- Field of View
SetCamFov(camera, ]] .. string.format("%.2f", self.fov) .. [[)
]]

    if self.dof.enabled then
        code = code .. [[

-- Depth of Field (DOF)
SetCamUseShallowDofMode(camera, true)
SetCamNearDof(camera, ]] .. string.format("%.2f", self.dof.nearStart) .. [[)
SetCamFarDof(camera, ]] .. string.format("%.2f", self.dof.farStart) .. [[)
SetCamDofStrength(camera, ]] .. string.format("%.2f", self.dof.strength) .. [[)
SetCamDofFnumberOfRings(camera, 8)
]]
    end

    if self.effects.motionBlur then
        code = code .. [[

-- Motion Blur
SetCamMotionBlurStrength(camera, ]] .. string.format("%.2f", self.effects.motionBlurStrength) .. [[)
]]
    end

    code = code .. [[

-- Activate Camera
SetCamActive(camera, true)
RenderScriptCams(true, false, 0, true, true)

-- Direction Vector (for reference)
-- Direction: ]] .. string.format("vector3(%.4f, %.4f, %.4f)", direction.x, direction.y, direction.z) .. [[
]]

    print("^2[A5 Camera Tool]^7 Code snippet generated!")
    print(code)

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 255},
        multiline = true,
        args = {"Camera Tool", "Code snippet printed to console (F8)!"}
    })

    return code
end

CreateThread(function()
    while true do
        Wait(0)

        if CamDevTool.active then
            local deltaTime = GetFrameTime()
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true)

            -- Handle movement
            CamDevTool:HandleMovement(deltaTime)

            -- Handle rotation
            CamDevTool:HandleRotation(deltaTime)

            -- Handle FOV
            CamDevTool:HandleFOVAdjustment()

            -- Handle DOF
            CamDevTool:HandleDOFAdjustment()

            -- Handle effects
            CamDevTool:HandleEffects()

            -- Update camera
            CamDevTool:UpdateCamera()

            -- Draw debug UI
            CamDevTool:DrawDebugUI()

            if IsControlJustPressed(0, 191) then -- ENTER
                CamDevTool:GenerateCodeSnippet()
            end

            if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 177) then -- ESC or Backspace
                CamDevTool:Shutdown()
            end
        else
            Wait(500)
        end
    end
end)


CreateThread(function()
    while true do
        Wait(0)

        if CamDevTool.active then
            -- TODO:hold shift for turbo
            local shiftPressed = IsControlPressed(0, 21)
            local increment = shiftPressed and CamDevTool.speedIncrementFast or CamDevTool.speedIncrement

            if IsControlJustPressed(0, 241) then
                CamDevTool.moveSpeed = math.min(CamDevTool.maxSpeed, CamDevTool.moveSpeed + increment)
                print(string.format("^2[A5 Camera Tool]^7 Speed: %.3f", CamDevTool.moveSpeed))
            end

            
            if IsControlJustPressed(0, 242) then
                CamDevTool.moveSpeed = math.max(CamDevTool.minSpeed, CamDevTool.moveSpeed - increment)
                print(string.format("^2[A5 Camera Tool]^7 Speed: %.3f", CamDevTool.moveSpeed))
            end
        else
            Wait(500)
        end
    end
end)

RegisterCommand('cam', function(source, args, rawCommand)
    if not CamDevTool.active then
        CamDevTool:Initialize()
    else
        CamDevTool:Shutdown()
    end
end, false)

RegisterCommand('camtool', function(source, args, rawCommand)
    if not CamDevTool.active then
        CamDevTool:Initialize()
    else
        CamDevTool:Shutdown()
    end
end, false)

RegisterCommand('camera', function(source, args, rawCommand)
    if not CamDevTool.active then
        CamDevTool:Initialize()
    else
        CamDevTool:Shutdown()
    end
end, false)

RegisterCommand('camdebug', function(source, args, rawCommand)
    CamDevTool.showDebug = not CamDevTool.showDebug
    print(string.format("^2[A5 Camera Tool]^7 Debug UI %s", CamDevTool.showDebug and "enabled" or "disabled"))
end, false)

-- TODO: Reset camera position to player
RegisterCommand('camreset', function(source, args, rawCommand)
    if CamDevTool.active then
        local ped = PlayerPedId()
        CamDevTool.position = GetEntityCoords(ped)
        CamDevTool.rotation = vector3(0.0, 0.0, GetEntityHeading(ped))
        print("^2[A5 Camera Tool]^7 Camera position reset to player location")
    end
end, false)

print("^2[A5 Camera Tool]^7 Loaded! Use /cam, /camtool, or /camera to start")
