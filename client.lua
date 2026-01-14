local CamDevTool = {


    active = false,
    camera = nil,


    position = vector3(0.0, 0.0, 0.0),
    rotation = vector3(0.0, 0.0, 0.0),


    fov = 50.0,
    moveSpeed = 0.5,
    rotSpeed = 0.5,
    mouseSensitivity = 5.0,
    panLocked = false,


    dof = {
        enabled = false,
        strength = 0.0,
        nearStart = 0.0,
        nearEnd = 1.0,
        farStart = 100.0,
        farEnd = 200.0
        ,
        focusDistance = 50.0
        ,
        focusPoint = nil,
        focusAdjusting = false,
        spawnedFocusEntity = nil
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
    SetTextProportional(true)
    SetTextCentre(false)
    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextColour(CamDevTool.debugColor.r, CamDevTool.debugColor.g, CamDevTool.debugColor.b, CamDevTool.debugColor.a)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

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

    if self.dof and self.dof.spawnedFocusEntity then
        if DoesEntityExist(self.dof.spawnedFocusEntity) then
            DeleteObject(self.dof.spawnedFocusEntity)
        end
        self.dof.spawnedFocusEntity = nil
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
        SetCamDofFnumberOfLens(self.camera, math.max(1.2, 1.2 + (1.0 - self.dof.strength) * 23.0))
        SetCamDofFocalLengthMultiplier(self.camera, math.max(1.0, 50.0 * (1.0 - self.dof.strength) + 1.0))

        local dir = RotationToDirection(self.rotation)
        local focusDist = math.max(0.5, self.dof.focusDistance or ((self.dof.nearStart + self.dof.farStart) * 0.5))
        SetFocusPosAndVel(self.position.x + dir.x * focusDist, self.position.y + dir.y * focusDist, self.position.z + dir.z * focusDist, 0.0, 0.0, 0.0)
    else
        SetCamUseShallowDofMode(self.camera, false)
        SetFocusPosAndVel(self.position.x, self.position.y, self.position.z, 0.0, 0.0, 0.0)
    end


    -- motion blur removed
end

function CamDevTool:HandleMovement(deltaTime)
    local direction = RotationToDirection(self.rotation)
    local right = vector3(direction.y, -direction.x, 0.0)
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

    if IsControlJustPressed(0, 24) then -- 24 = INPUT_ATTACK (Left Mouse)
        self.panLocked = not self.panLocked
        print(string.format("^2[A5 Camera Tool]^7 Pan %s", self.panLocked and "locked" or "unlocked"))
    end

    local mouseX = 0
    local mouseY = 0
    if not self.panLocked then
        mouseX = GetDisabledControlNormal(0, 1) * speed * self.mouseSensitivity
        mouseY = GetDisabledControlNormal(0, 2) * speed * self.mouseSensitivity
    end

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
        self.rotation = vector3(self.rotation.x, self.rotation.y - speed * 0.5, self.rotation.z)
    end
    if IsControlPressed(0, 175) then
        self.rotation = vector3(self.rotation.x, self.rotation.y + speed * 0.5, self.rotation.z)
    end
end

function CamDevTool:HandleFOVAdjustment()
    if IsControlPressed(0, 21) then return end
    local now = GetGameTimer()
    if self._lastScrollTick and (now - self._lastScrollTick) < 150 then
        return
    end
end

function CamDevTool:HandleDOFAdjustment()
    if IsControlJustPressed(0, 157) then -- 1
        self.dof.enabled = not self.dof.enabled
        print(string.format("^2[A5 Camera Tool]^7 DOF %s", self.dof.enabled and "enabled" or "disabled"))
    end

    if not self.dof.enabled then return end

    if IsControlPressed(0, 158) then -- 2
        self.dof.strength = math.max(0.0, self.dof.strength - 0.01)
    end
    if IsControlPressed(0, 160) then -- 3
        self.dof.strength = math.min(1.0, self.dof.strength + 0.01)
    end

    if IsControlPressed(0, 164) then -- 4
        self.dof.nearStart = math.max(0.0, self.dof.nearStart - 0.1)
        self.dof.focusDistance = math.max(0.5, (self.dof.nearStart + self.dof.farStart) * 0.5)
        local dir = RotationToDirection(self.rotation)
        SetFocusPosAndVel(self.position.x + dir.x * self.dof.focusDistance, self.position.y + dir.y * self.dof.focusDistance, self.position.z + dir.z * self.dof.focusDistance, 0.0, 0.0, 0.0)
    end
    if IsControlPressed(0, 165) then -- 5
        self.dof.nearStart = math.min(self.dof.farStart, self.dof.nearStart + 0.1)
        self.dof.focusDistance = math.max(0.5, (self.dof.nearStart + self.dof.farStart) * 0.5)
        local dir = RotationToDirection(self.rotation)
        SetFocusPosAndVel(self.position.x + dir.x * self.dof.focusDistance, self.position.y + dir.y * self.dof.focusDistance, self.position.z + dir.z * self.dof.focusDistance, 0.0, 0.0, 0.0)
    end

    if IsControlPressed(0, 159) then -- 6
        self.dof.farStart = math.max(self.dof.nearStart, self.dof.farStart - 1.0)
        self.dof.focusDistance = math.max(0.5, (self.dof.nearStart + self.dof.farStart) * 0.5)
        local dir = RotationToDirection(self.rotation)
        SetFocusPosAndVel(self.position.x + dir.x * self.dof.focusDistance, self.position.y + dir.y * self.dof.focusDistance, self.position.z + dir.z * self.dof.focusDistance, 0.0, 0.0, 0.0)
    end
    if IsControlPressed(0, 161) then -- 7
        self.dof.farStart = math.min(500.0, self.dof.farStart + 1.0)
        self.dof.focusDistance = math.max(0.5, (self.dof.nearStart + self.dof.farStart) * 0.5)
        local dir = RotationToDirection(self.rotation)
        SetFocusPosAndVel(self.position.x + dir.x * self.dof.focusDistance, self.position.y + dir.y * self.dof.focusDistance, self.position.z + dir.z * self.dof.focusDistance, 0.0, 0.0, 0.0)
    end

        if IsControlJustPressed(0, 163) then -- '9' key
            local shift = IsControlPressed(0, 21)
            local camCoords = GetCamCoord(self.camera)
            local dir = RotationToDirection(self.rotation)
            local rayLen = 2000.0
            local endPos = vector3(camCoords.x + dir.x * rayLen, camCoords.y + dir.y * rayLen, camCoords.z + dir.z * rayLen)
            local handle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endPos.x, endPos.y, endPos.z, 1 + 16 + 32, PlayerPedId(), 0)
            local _, hit, hitCoords, surfaceNormal, entity = GetShapeTestResult(handle)

            if self.dof.spawnedFocusEntity then
                if DoesEntityExist(self.dof.spawnedFocusEntity) then
                    DeleteObject(self.dof.spawnedFocusEntity)
                end
                self.dof.spawnedFocusEntity = nil
            end

            if hit then
   
                local offset = 0.06
                local px = hitCoords.x + (surfaceNormal.x * offset)
                local py = hitCoords.y + (surfaceNormal.y * offset)
                local pz = hitCoords.z + (surfaceNormal.z * offset)
                self.dof.focusPoint = vector3(px, py, pz)
                self.dof.focusDistance = #(vector3(hitCoords.x, hitCoords.y, hitCoords.z) - camCoords)

                local modelHash = GetHashKey("prop_beachball_02")
                RequestModel(modelHash)
                local t0 = GetGameTimer()
                while not HasModelLoaded(modelHash) and (GetGameTimer() - t0) < 2000 do
                    Wait(0)
                end
                if HasModelLoaded(modelHash) then
                    local ent = CreateObject(modelHash, px, py, pz, true, true, true)
                    if DoesEntityExist(ent) then
                        SetEntityAsMissionEntity(ent, true, true)
                        SetEntityCollision(ent, true, true)
                        PlaceObjectOnGroundProperly(ent)
                            SetEntityVelocity(ent, 0.0, 0.0, 0.0)
                            FreezeEntityPosition(ent, true)
                        self.dof.spawnedFocusEntity = ent
                        SetModelAsNoLongerNeeded(modelHash)
                    end
                else
                    print("^1[A5 Camera Tool]^7 Failed to load beachball model")
                end
            else
                local px = camCoords.x + dir.x * self.dof.focusDistance
                local py = camCoords.y + dir.y * self.dof.focusDistance
                local pz = camCoords.z + dir.z * self.dof.focusDistance
                self.dof.focusPoint = vector3(px, py, pz)

                local modelHash = GetHashKey("prop_beachball_02")
                RequestModel(modelHash)
                local t0 = GetGameTimer()
                while not HasModelLoaded(modelHash) and (GetGameTimer() - t0) < 2000 do
                    Wait(0)
                end
                if HasModelLoaded(modelHash) then
                    local ent = CreateObject(modelHash, px, py, pz, true, true, true)
                    if DoesEntityExist(ent) then
                        SetEntityAsMissionEntity(ent, true, true)
                        SetEntityCollision(ent, true, true)
                        PlaceObjectOnGroundProperly(ent)
                        SetEntityVelocity(ent, 0.0, 0.0, 0.0)
                        FreezeEntityPosition(ent, true)
                        self.dof.spawnedFocusEntity = ent
                        SetModelAsNoLongerNeeded(modelHash)
                    end
                else
                    print("^1[A5 Camera Tool]^7 Failed to load beachball model")
                end
            end

            if shift then
                self.dof.focusAdjusting = true
                print("^2[A5 Camera Tool]^7 DOF focus adjust mode: ON")
            else
                self.dof.focusAdjusting = false
                print("^2[A5 Camera Tool]^7 DOF focus point set and ball spawned")
            end
        end

        if IsControlJustReleased(0, 163) then
            if self.dof.focusAdjusting then
                self.dof.focusAdjusting = false
                print("^2[A5 Camera Tool]^7 DOF focus adjust mode: OFF")
            end
        end
end

function CamDevTool:ScrollUp()
    if not self.active then return end

    if self.dof.focusAdjusting then
        self.dof.focusDistance = math.max(0.1, self.dof.focusDistance - 0.5)
        local camCoords = GetCamCoord(self.camera)
        local dir = RotationToDirection(self.rotation)
        self.dof.focusPoint = vector3(camCoords.x + dir.x * self.dof.focusDistance, camCoords.y + dir.y * self.dof.focusDistance, camCoords.z + dir.z * self.dof.focusDistance)
        if self.dof.spawnedFocusEntity and DoesEntityExist(self.dof.spawnedFocusEntity) then
            local ent = self.dof.spawnedFocusEntity
            local targetPos = self.dof.focusPoint
            if ent and targetPos and targetPos.x then
                SetEntityCoordsNoOffset(ent, targetPos.x, targetPos.y, targetPos.z, false, false, false)
                FreezeEntityPosition(ent, true)
            end
        end
        print(string.format("^2[A5 Camera Tool]^7 DOF focus distance: %.2f", self.dof.focusDistance))
        self._lastScrollTick = GetGameTimer()
    else
        local shiftPressed = IsControlPressed(0, 21)
        local increment = shiftPressed and self.speedIncrementFast or self.speedIncrement
        self.moveSpeed = math.min(self.maxSpeed, self.moveSpeed + increment)
        print(string.format("^2[A5 Camera Tool]^7 Speed: %.3f", self.moveSpeed))
    end
end

function CamDevTool:ScrollDown()
    if not self.active then return end

    if self.dof.focusAdjusting then
        self.dof.focusDistance = math.min(1000.0, self.dof.focusDistance + 0.5)
        local camCoords = GetCamCoord(self.camera)
        local dir = RotationToDirection(self.rotation)
        self.dof.focusPoint = vector3(camCoords.x + dir.x * self.dof.focusDistance, camCoords.y + dir.y * self.dof.focusDistance, camCoords.z + dir.z * self.dof.focusDistance)
        if self.dof.spawnedFocusEntity and DoesEntityExist(self.dof.spawnedFocusEntity) then
            local ent = self.dof.spawnedFocusEntity
            local targetPos = self.dof.focusPoint
            if ent and targetPos and targetPos.x then
                SetEntityCoordsNoOffset(ent, targetPos.x, targetPos.y, targetPos.z, false, false, false)
                FreezeEntityPosition(ent, true)
            end
        end
        print(string.format("^2[A5 Camera Tool]^7 DOF focus distance: %.2f", self.dof.focusDistance))
        self._lastScrollTick = GetGameTimer()
    else
        local shiftPressed = IsControlPressed(0, 21)
        local increment = shiftPressed and self.speedIncrementFast or self.speedIncrement
        self.moveSpeed = math.max(self.minSpeed, self.moveSpeed - increment)
        print(string.format("^2[A5 Camera Tool]^7 Speed: %.3f", self.moveSpeed))
    end
end

function CamDevTool:DrawDebugUI()
    if not self.showDebug then return end

    local y = 0.02
    local lineHeight = 0.025

        DrawDebugBox(0.01, 0.01, 0.35, 0.45, 0, 0, 0, 0)
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

    DrawText2D("~b~CONTROLS:", 0.025, y, 0.35, 4)
    y = y + lineHeight
    DrawText2D("WASD - Move Camera | Q/E - Up/Down", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Mouse - Rotate | Arrows - Fine Rotate | LMB - Lock/Unlock Pan", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Scroll - Speed | Shift+Scroll - Fast Speed", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("Numpad 9/6 - FOV +/-5 | Numpad 8/5 - FOV +/-1", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("9 - Set DOF focus point | Shift+9 - Set and enter adjust mode", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("While adjusting: Use Scroll to move focus near/far", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("1 - Toggle DOF | 2/3 - DOF Strength", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("4/5 - Near DOF | 6/7 - Far DOF", 0.025, y, 0.30, 4)
    y = y + lineHeight
    DrawText2D("~g~ENTER - Generate Code Snippet", 0.025, y, 0.35, 4)
    y = y + lineHeight
    DrawText2D("~r~ESC/Backspace - Exit Camera Tool | I - Reset Tilts", 0.025, y, 0.35, 4)
    y = y + lineHeight

    -- Show DOF focus distance and adjust state when available
    if self.dof and self.dof.enabled then
        if self.dof.focusPoint then
            DrawText2D(string.format("Focus Dist: %.2f | Adjusting: %s", (self.dof.focusDistance or 0.0), (self.dof.focusAdjusting and "~g~YES~s~" or "~r~NO~s~")), 0.025, y, 0.32, 4)
            y = y + lineHeight
        else
            DrawText2D(string.format("Focus Dist: %.2f (no point set)", (self.dof.focusDistance or 0.0)), 0.025, y, 0.32, 4)
            y = y + lineHeight
        end

        DrawText2D(string.format("Spawned Ball: %s", (self.dof.spawnedFocusEntity and DoesEntityExist(self.dof.spawnedFocusEntity)) and "~g~YES~s~" or "~r~NO~s~"), 0.025, y, 0.32, 4)
        y = y + lineHeight
    end

    DrawText2D(string.format("Pan: %s", self.panLocked and "~r~LOCKED~s~" or "~g~UNLOCKED~s~"), 0.025, y, 0.32, 4)
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
        local dir = RotationToDirection(self.rotation)
        local fx = self.position.x + dir.x * ((self.dof.nearStart + self.dof.farStart) * 0.5)
        local fy = self.position.y + dir.y * ((self.dof.nearStart + self.dof.farStart) * 0.5)
        local fz = self.position.z + dir.z * ((self.dof.nearStart + self.dof.farStart) * 0.5)

        code = code .. [[

-- Depth of Field (DOF)
SetCamUseShallowDofMode(camera, true)
SetCamNearDof(camera, ]] .. string.format("%.2f", self.dof.nearStart) .. [[)
SetCamFarDof(camera, ]] .. string.format("%.2f", self.dof.farStart) .. [[)
SetCamDofStrength(camera, ]] .. string.format("%.2f", self.dof.strength) .. [[)
SetCamDofFnumberOfLens(camera, ]] .. string.format("%.2f", math.max(1.2, 1.2 + (1.0 - self.dof.strength) * 23.0)) .. [[)
SetCamDofFocalLengthMultiplier(camera, ]] .. string.format("%.2f", math.max(1.0, 50.0 * (1.0 - self.dof.strength) + 1.0)) .. [[)
SetFocusPosAndVel(]] .. string.format("%.2f, %.2f, %.2f, 0.0, 0.0, 0.0", fx, fy, fz) .. [[)
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
            EnableControlAction(0, 21, true)
            EnableControlAction(0, 32, true)
            EnableControlAction(0, 33, true)
            EnableControlAction(0, 34, true)
            EnableControlAction(0, 35, true)
            EnableControlAction(0, 44, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 24, true)
            EnableControlAction(0, 25, true)
            EnableControlAction(0, 191, true)
            EnableControlAction(0, 322, true)
            EnableControlAction(0, 177, true)
            EnableControlAction(0, 241, true)
            EnableControlAction(0, 242, true)
            -- FOV controls intentionally not enabled here (mapped via key bindings)
            -- Number keys (for DOF remap)
            EnableControlAction(0, 157, true)
            EnableControlAction(0, 158, true)
            EnableControlAction(0, 159, true)
            EnableControlAction(0, 160, true)
            EnableControlAction(0, 161, true)
            EnableControlAction(0, 164, true)
            EnableControlAction(0, 165, true)
            -- Arrow keys
            EnableControlAction(0, 172, true)
            EnableControlAction(0, 173, true)
            EnableControlAction(0, 174, true)
            EnableControlAction(0, 175, true)

            -- Handle movement
            CamDevTool:HandleMovement(deltaTime)

            -- Handle rotation
            CamDevTool:HandleRotation(deltaTime)

            -- Handle FOV
            CamDevTool:HandleFOVAdjustment()

            -- Handle DOF
            CamDevTool:HandleDOFAdjustment()



            -- Update camera
            CamDevTool:UpdateCamera()

            -- Draw debug UI
            CamDevTool:DrawDebugUI()

            -- Draw DOF focus marker if present
            if CamDevTool.dof and CamDevTool.dof.focusPoint then
                local p = CamDevTool.dof.focusPoint
                if p and p.x then
                    DrawMarker(1, p.x, p.y, p.z - 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.07, 0.07, 0.07, 255, 50, 50, 200, false, true, 2, false, "", "", false)
                end
            end

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
            local shiftPressed = IsControlPressed(0, 21)
            local increment = shiftPressed and CamDevTool.speedIncrementFast or CamDevTool.speedIncrement

            if IsControlJustPressed(0, 241) then
                CamDevTool:ScrollUp()
            end

            if IsControlJustPressed(0, 242) then
                CamDevTool:ScrollDown()
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

RegisterCommand('cam_resettilt', function(source, args, rawCommand)
    if CamDevTool.active then
        CamDevTool.rotation = vector3(0.0, 0.0, CamDevTool.rotation.z)
        print("^2[A5 Camera Tool]^7 Camera tilts reset")
    end
end, false)

RegisterKeyMapping('cam_resettilt', 'Reset camera tilts', 'keyboard', 'I')

RegisterCommand('cam_fov_increase', function(source, args, rawCommand)
    if IsControlPressed(0, 21) then return end
    CamDevTool.fov = math.min(120.0, CamDevTool.fov + 5.0)
    print(string.format("^2[A5 Camera Tool]^7 FOV: %.2f", CamDevTool.fov))
end, false)
RegisterKeyMapping('cam_fov_increase', 'Increase camera FOV', 'keyboard', 'NUMPAD9')

RegisterCommand('cam_fov_decrease', function(source, args, rawCommand)
    if IsControlPressed(0, 21) then return end
    CamDevTool.fov = math.max(10.0, CamDevTool.fov - 5.0)
    print(string.format("^2[A5 Camera Tool]^7 FOV: %.2f", CamDevTool.fov))
end, false)
RegisterKeyMapping('cam_fov_decrease', 'Decrease camera FOV', 'keyboard', 'NUMPAD6')


RegisterCommand('cam_fov_increase_small', function(source, args, rawCommand)
    if IsControlPressed(0, 21) then return end
    CamDevTool.fov = math.min(120.0, CamDevTool.fov + 1.0)
    print(string.format("^2[A5 Camera Tool]^7 FOV: %.2f", CamDevTool.fov))
end, false)
RegisterKeyMapping('cam_fov_increase_small', 'Increase camera FOV (small)', 'keyboard', 'NUMPAD8')

RegisterCommand('cam_fov_decrease_small', function(source, args, rawCommand)
    if IsControlPressed(0, 21) then return end
    CamDevTool.fov = math.max(10.0, CamDevTool.fov - 1.0)
    print(string.format("^2[A5 Camera Tool]^7 FOV: %.2f", CamDevTool.fov))
end, false)
RegisterKeyMapping('cam_fov_decrease_small', 'Decrease camera FOV (small)', 'keyboard', 'NUMPAD5')

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
