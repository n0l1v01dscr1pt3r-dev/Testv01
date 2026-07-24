local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Test",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WallPainterConfig",
        FileName = "WallColorTextureSettings"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

local PaintButton = MainTab:CreateButton({
    Name = "🎨 Paint with Exact Color + Detect Textures/Decals Behind Me",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({
                Title = "Error",
                Content = "No character or HRP found. Stand properly!",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end

        local root = character.HumanoidRootPart
        local origin = root.Position
        local direction = -root.CFrame.LookVector * 50

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.IgnoreWater = true

        local result = workspace:Raycast(origin, direction, raycastParams)

        if result and result.Instance and result.Instance:IsA("BasePart") then
            local part = result.Instance
            local wallColor = part.Color

            local textureInfo = "None detected"
            local decalTexture = nil
            local surfaceTexture = nil

            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    decalTexture = child.Texture
                    textureInfo = "Decal/Texture ID: " .. tostring(decalTexture)
                    break
                end
            end

            local surfaceApp = part:FindFirstChildOfClass("SurfaceAppearance")
            if surfaceApp then
                surfaceTexture = surfaceApp.ColorMap or surfaceApp.Texture or "Unknown"
                textureInfo = "SurfaceAppearance: " .. tostring(surfaceTexture)
            end

            local args = {
                [1] = {
                    ["color"] = wallColor,
                    ["op"] = "fill"
                }
            }

            game:GetService("ReplicatedStorage").PaintRemotes.PaintOpEvent:FireServer(unpack(args))

            Rayfield:Notify({
                Title = "Successful",
                Content = "Colored",
                Duration = 5,
                Image = 4483362458,
            })

            if decalTexture or surfaceTexture then
                Rayfield:Notify({
                    Title = "Texture/Decal Detected",
                    Content = "WALLS WILL DOMINATE",
                    Duration = 6,
                })
            end
        else
            Rayfield:Notify({
                Title = "No Wall Detected",
                Content = "WALLS WILL RULE",
                Duration = 4,
            })
        end
    end
})

Rayfield:LoadConfiguration()
